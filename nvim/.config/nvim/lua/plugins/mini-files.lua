return {
    'nvim-mini/mini.files',
    version = '*',
    config = function()
        local nsMiniFiles = vim.api.nvim_create_namespace("mini_files_git")
        local autocmd = vim.api.nvim_create_autocmd
        local ok, MiniFiles = pcall(require, "mini.files")
        if not ok then
            return
        end

        -- Cache for git status
        local gitStatusCache = {}
        local cacheTimeout = 2000 -- in milliseconds
        local uv = vim.uv or vim.loop

        -- Cache of ignored paths (per git root), used by the "show/hide gitignored" toggle
        local ignoredPathsCache = {}

        -- Toggle state for filters
        local show_dotfiles = true
        local show_gitignored = true

        local function isSymlink(path)
            local stat = uv.fs_lstat(path)
            return stat and stat.type == "link"
        end

        ---@type table<string, {symbol: string, hlGroup: string}>
        ---@param status string
        ---@return string symbol, string hlGroup
        local function mapSymbols(status, is_symlink)
            local statusMap = {
                -- stylua: ignore start
                [" M"] = { symbol = "•", hlGroup = "MiniDiffSignChange" }, -- Modified in the working directory
                ["M "] = { symbol = "✹", hlGroup = "MiniDiffSignChange" }, -- modified in index
                ["MM"] = { symbol = "≠", hlGroup = "MiniDiffSignChange" }, -- modified in both working tree and index
                ["A "] = { symbol = "+", hlGroup = "MiniDiffSignAdd" }, -- Added to the staging area, new file
                ["AA"] = { symbol = "≈", hlGroup = "MiniDiffSignAdd" }, -- file is added in both working tree and index
                ["D "] = { symbol = "-", hlGroup = "MiniDiffSignDelete" }, -- Deleted from the staging area
                ["AM"] = { symbol = "⊕", hlGroup = "MiniDiffSignChange" }, -- added in working tree, modified in index
                ["AD"] = { symbol = "-•", hlGroup = "MiniDiffSignChange" }, -- Added in the index and deleted in the working directory
                ["R "] = { symbol = "→", hlGroup = "MiniDiffSignChange" }, -- Renamed in the index
                ["U "] = { symbol = "‖", hlGroup = "MiniDiffSignChange" }, -- Unmerged path
                ["UU"] = { symbol = "⇄", hlGroup = "MiniDiffSignAdd" }, -- file is unmerged
                ["UA"] = { symbol = "⊕", hlGroup = "MiniDiffSignAdd" }, -- file is unmerged and added in working tree
                ["??"] = { symbol = "?", hlGroup = "MiniDiffSignDelete" }, -- Untracked files
                ["!!"] = { symbol = "!", hlGroup = "MiniDiffSignChange" }, -- Ignored files
                -- stylua: ignore end
            }

            local result = statusMap[status] or { symbol = "?", hlGroup = "NonText" }
            local gitSymbol = result.symbol
            local gitHlGroup = result.hlGroup

            local symlinkSymbol = is_symlink and "↩" or ""

            -- Combine symlink symbol with Git status if both exist
            local combinedSymbol = (symlinkSymbol .. gitSymbol)
                :gsub("^%s+", "")
                :gsub("%s+$", "")
            -- Change the color of the symlink icon from "MiniDiffSignDelete" to something else
            local combinedHlGroup = is_symlink and "MiniDiffSignDelete" or gitHlGroup

            return combinedSymbol, combinedHlGroup
        end

        ---@param cwd string
        ---@param callback function
        ---@return nil
        local function fetchGitStatus(cwd, callback)
            local clean_cwd = cwd:gsub("^minifiles://%d+/", "")
            ---@param content table
            local function on_exit(content)
                if content.code == 0 then
                    callback(content.stdout)
                    -- vim.g.content = content.stdout
                end
            end
            ---@see vim.system
            vim.system(
                { "git", "status", "--ignored", "--porcelain" },
                { text = true, cwd = clean_cwd },
                on_exit
            )
        end

        ---@param buf_id integer
        ---@param gitStatusMap table
        ---@return nil
        local function updateMiniWithGit(buf_id, gitStatusMap)
            vim.schedule(function()
                local nlines = vim.api.nvim_buf_line_count(buf_id)
                local cwd = vim.fs.root(buf_id, ".git")
                local escapedcwd = cwd and vim.pesc(cwd)
                escapedcwd = vim.fs.normalize(escapedcwd)

                for i = 1, nlines do
                    local entry = MiniFiles.get_fs_entry(buf_id, i)
                    if not entry then
                        break
                    end
                    local relativePath = entry.path:gsub("^" .. escapedcwd .. "/", "")
                    local status = gitStatusMap[relativePath]

                    if status then
                        local symbol, hlGroup = mapSymbols(status, isSymlink(entry.path))
                        vim.api.nvim_buf_set_extmark(buf_id, nsMiniFiles, i - 1, 0, {
                            sign_text = symbol,
                            sign_hl_group = hlGroup,
                            priority = 2,
                        })
                        -- This below code is responsible for coloring the text of the items. comment it out if you don't want that
                        local line = vim.api.nvim_buf_get_lines(buf_id, i - 1, i, false)[1]
                        -- Find the name position accounting for potential icons
                        local nameStartCol = line:find(vim.pesc(entry.name)) or 0

                        if nameStartCol > 0 then
                            vim.api.nvim_buf_set_extmark(
                                buf_id,
                                nsMiniFiles,
                                i - 1,
                                nameStartCol - 1,
                                {
                                    end_col = nameStartCol + #entry.name - 1,
                                    hl_group = hlGroup,
                                }
                            )
                        end
                    else
                    end
                end
            end)
        end

        -- Thanks for the idea of gettings https://github.com/refractalize/oil-git-status.nvim signs for dirs
        ---@param content string
        ---@return table
        local function parseGitStatus(content)
            local gitStatusMap = {}
            -- lua match is faster than vim.split (in my experience )
            for line in content:gmatch("[^\r\n]+") do
                local status, filePath = string.match(line, "^(..)%s+(.*)")
                -- Split the file path into parts
                local parts = {}
                for part in filePath:gmatch("[^/]+") do
                    table.insert(parts, part)
                end
                -- Start with the root directory
                local currentKey = ""
                for i, part in ipairs(parts) do
                    if i > 1 then
                        -- Concatenate parts with a separator to create a unique key
                        currentKey = currentKey .. "/" .. part
                    else
                        currentKey = part
                    end
                    -- If it's the last part, it's a file, so add it with its status
                    if i == #parts then
                        gitStatusMap[currentKey] = status
                    else
                        -- If it's not the last part, it's a directory. Check if it exists, if not, add it.
                        if not gitStatusMap[currentKey] then
                            gitStatusMap[currentKey] = status
                        end
                    end
                end
            end
            return gitStatusMap
        end

        ---@param buf_id integer
        ---@return nil
        local function updateGitStatus(buf_id)
            if not vim.fs.root(buf_id, ".git") then
                return
            end
            local cwd = vim.fs.root(buf_id, ".git")
            -- local cwd = vim.fn.expand("%:p:h")
            local currentTime = os.time()

            if
                gitStatusCache[cwd]
                and currentTime - gitStatusCache[cwd].time < cacheTimeout
            then
                updateMiniWithGit(buf_id, gitStatusCache[cwd].statusMap)
            else
                fetchGitStatus(cwd, function(content)
                    local gitStatusMap = parseGitStatus(content)
                    gitStatusCache[cwd] = {
                        time = currentTime,
                        statusMap = gitStatusMap,
                    }
                    updateMiniWithGit(buf_id, gitStatusMap)
                end)
            end
        end

        ---@return nil
        local function clearCache()
            gitStatusCache = {}
            ignoredPathsCache = {}
        end

        local function augroup(name)
            return vim.api.nvim_create_augroup("MiniFiles_" .. name, { clear = true })
        end

        -- ===== show/hide dotfiles + gitignored files =====

        ---@param path string absolute path of the fs entry
        ---@return boolean
        local function isGitIgnored(path)
            local root = vim.fs.root(path, ".git")
            if not root then
                return false
            end

            if not ignoredPathsCache[root] then
                local set = {}
                local ok_sys, result = pcall(function()
                    return vim.system(
                        { "git", "status", "--ignored", "--porcelain" },
                        { text = true, cwd = root }
                    ):wait()
                end)
                if ok_sys and result and result.code == 0 then
                    for line in result.stdout:gmatch("[^\r\n]+") do
                        local status, filePath = line:match("^(..)%s+(.*)")
                        if status == "!!" then
                            set[(filePath:gsub("/$", ""))] = true
                        end
                    end
                end
                ignoredPathsCache[root] = set
            end

            local relativePath = path:gsub("^" .. vim.pesc(root) .. "/", "")
            return ignoredPathsCache[root][relativePath] == true
        end

        ---@param fs_entry table
        ---@return boolean
        local function file_filter(fs_entry)
            if not show_dotfiles and vim.startswith(fs_entry.name, ".") then
                return false
            end
            if not show_gitignored and isGitIgnored(fs_entry.path) then
                return false
            end
            return true
        end

        -- Re-apply the filter and re-draw git status signs/colors on the current explorer
        local function refreshExplorer()
            local buf_id = vim.api.nvim_get_current_buf()
            MiniFiles.refresh({ content = { filter = file_filter } })
            updateGitStatus(buf_id)
        end

        local function toggleDotfiles()
            show_dotfiles = not show_dotfiles
            vim.notify(show_dotfiles and "Showing dotfiles" or "Hiding dotfiles")
            refreshExplorer()
        end

        local function toggleGitignored()
            show_gitignored = not show_gitignored
            -- Drop the cache so newly (un)ignored files are picked up
            ignoredPathsCache = {}
            vim.notify(show_gitignored and "Showing gitignored files" or "Hiding gitignored files")
            refreshExplorer()
        end

        MiniFiles.setup({
            content = {
                filter = file_filter,
            },
        })

        autocmd("User", {
            group = augroup("start"),
            pattern = "MiniFilesExplorerOpen",
            callback = function()
                local bufnr = vim.api.nvim_get_current_buf()
                updateGitStatus(bufnr)
            end,
        })

        autocmd("User", {
            group = augroup("close"),
            pattern = "MiniFilesExplorerClose",
            callback = function()
                clearCache()
            end,
        })

        autocmd("User", {
            group = augroup("update"),
            pattern = "MiniFilesBufferUpdate",
            callback = function(args)
                local bufnr = args.data.buf_id
                local cwd = vim.fs.root(bufnr, ".git")
                if gitStatusCache[cwd] then
                    updateMiniWithGit(bufnr, gitStatusCache[cwd].statusMap)
                end
            end,
        })

        -- Buffer-local keymaps for every mini.files buffer (root + any opened sub-dirs)
        autocmd("User", {
            group = augroup("keymaps"),
            pattern = "MiniFilesBufferCreate",
            callback = function(args)
                local buf_id = args.data.buf_id
                vim.keymap.set("n", ".", toggleDotfiles, { buffer = buf_id, desc = "Toggle dotfiles" })
                vim.keymap.set("n", "gi", toggleGitignored, { buffer = buf_id, desc = "Toggle gitignored files" })
            end,
        })

        -- Open/close mini.files with <leader>e
        vim.keymap.set("n", "<leader>e", function()
            if not MiniFiles.close() then
                local path = vim.api.nvim_buf_get_name(0)
                MiniFiles.open(path ~= "" and path or uv.cwd(), false)
            end
        end, { desc = "Toggle file explorer (mini.files)" })
    end
}
