return {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    build = ":TSUpdate",
    lazy = false,

    config = function()
        local ts = require("nvim-treesitter")

        -- On the `main` branch, setup() only accepts `install_dir`; the old
        -- `highlight`/`indent`/`incremental_selection`/`ensure_installed` keys
        -- are ignored. Parsers are installed explicitly and highlighting is
        -- started per-buffer via `vim.treesitter.start()` below.
        ts.setup({})

        local parsers = {
            "lua",
            "vim",
            "vimdoc",
            "python",
            "sql",
            "markdown", -- required by databricks.nvim (%md magic cell content highlighting)
            "yaml",
            "rust",
            "json",
            "jinja",        -- dbt / Jinja templating in .sql files
            "jinja_inline", -- required by the jinja parser
        }

        -- Install any parsers that aren't present yet (async, no-op if installed).
        local installed = ts.get_installed("parsers")
        local have = {}
        for _, p in ipairs(installed) do
            have[p] = true
        end
        local missing = {}
        for _, p in ipairs(parsers) do
            if not have[p] then
                table.insert(missing, p)
            end
        end
        if #missing > 0 then
            ts.install(missing)
        end

        -- dbt .sql files are Jinja with embedded SQL. Parse `sql`-filetype
        -- buffers as `jinja` (which nests macro/if/for blocks and exposes the
        -- raw text as `content`), then inject `sql` into `content` via the
        -- queries in after/queries/jinja/. Plain SQL files become one big
        -- `content` node, so they still get SQL highlighting + folds.
        vim.treesitter.language.register("jinja", "sql")

        vim.api.nvim_create_autocmd("FileType", {
            group = vim.api.nvim_create_augroup("user_treesitter", { clear = true }),
            callback = function(args)
                local buf = args.buf
                -- Only start when a parser is actually available for this buffer.
                local ok = pcall(vim.treesitter.start, buf)
                if not ok then
                    return
                end

                -- Treesitter-based indentation.
                vim.bo[buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"

                -- incremental_selection (main branch dropped the built-in module,
                -- so we use a small local reimplementation). Only for normal file
                -- buffers, so we don't clobber <CR> in help/quickfix/etc.
                if vim.bo[buf].buftype == "" then
                    local incr = require("config.ts_incremental")
                    vim.keymap.set("n", "<CR>", incr.init_selection, { buffer = buf, silent = true })
                    vim.keymap.set("x", "<CR>", incr.node_incremental, { buffer = buf, silent = true })
                    vim.keymap.set("x", "<Tab>", incr.scope_incremental, { buffer = buf, silent = true })
                    vim.keymap.set("x", "<S-CR>", incr.node_decremental, { buffer = buf, silent = true })
                end
            end,
        })
    end,
}
-- On windows, tree-sitter build defaults to cl.exe (MSVC) which isn't installed. Fix it by setting CC=gcc to sue our MingW GCC at ~/.local/mingw64/bin/gcc.exe
-- Since we install parsers explicitly, new parsers will also need CC=gcc in the environment where Neovim is launched - otherwise they will fail
