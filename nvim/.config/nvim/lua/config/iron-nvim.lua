local iron = require("iron.core")
local view = require("iron.view")
local common = require("iron.fts.common")

iron.setup {
    config = {
        -- Whether a repl should be discarded or not
        scratch_repl = true,
        -- Your repl definitions come here
        repl_definition = {
            sh = {
                -- Can be a table or a function that
                -- returns a table (see below)
                command = { "zsh" }
            },
            python = {
                command = { "ipython", "--no-autoindent" },
                format = common.bracketed_paste_python,
                block_dividers = { "# %%", "#%%" },
            }
        },
        -- set the file type of the newly created repl to ft
        -- bufnr is the buffer id of the REPL and ft is the filetype of the
        -- language being used for the REPL.
        repl_filetype = function(bufnr, ft)
            return ft
            -- or return a string name such as the following
            -- return "iron"
        end,
        -- Send selections to the DAP repl if an nvim-dap session is running.
        dap_integration = true,
        -- How the repl window will be displayed
        -- See below for more information
        -- repl_open_cmd = view.bottom(40),
        repl_open_cmd = view.split.vertical.rightbelow("%40"),

        -- repl_open_cmd can also be an array-style table so that multiple
        -- repl_open_commands can be given.
        -- When repl_open_cmd is given as a table, the first command given will
        -- be the command that `IronRepl` initially toggles.
        -- Moreover, when repl_open_cmd is a table, each key will automatically
        -- be available as a keymap (see `keymaps` below) with the names
        -- toggle_repl_with_cmd_1, ..., toggle_repl_with_cmd_k
        -- For example,
        --
        -- repl_open_cmd = {
        --   view.split.vertical.rightbelow("%40"), -- cmd_1: open a repl to the right
        --   view.split.rightbelow("%25")  -- cmd_2: open a repl below
        -- }

    },
    -- Iron doesn't set keymaps by default anymore.
    -- You can set them here or manually add keymaps to the functions in iron.core
    keymaps = {
        toggle_repl = "<space>rr", -- toggles the repl open and closed.
        -- If repl_open_command is a table as above, then the following keymaps are
        -- available
        -- toggle_repl_with_cmd_1 = "<space>rv",
        -- toggle_repl_with_cmd_2 = "<space>rh",
        restart_repl = "<space>rR", -- calls `IronRestart` to restart the repl
        send_motion = "<space>sc",
        visual_send = "<space>sc",
        send_file = "<space>sf",
        send_line = "<space>sl",
        send_paragraph = "<space>sp",
        send_until_cursor = "<space>su",
        send_mark = "<space>sm",
        send_code_block = "<space>sb",
        send_code_block_and_move = "<space>sn",
        mark_motion = "<space>mc",
        mark_visual = "<space>mc",
        remove_mark = "<space>md",
        cr = "<space>s<cr>",
        interrupt = "<space>s<space>",
        exit = "<space>sq",
        clear = "<space>cl",
    },
    -- If the highlight is on, you can change how it looks
    -- For the available options, check nvim_set_hl
    highlight = {
        italic = true
    },
    ignore_blank_lines = true, -- ignore blank lines when sending visual select lines
}

-- iron also has a list of commands, see :h iron-commands for all available commands
vim.keymap.set('n', '<space>rf', '<cmd>IronFocus<cr>')
vim.keymap.set('n', '<space>rh', '<cmd>IronHide<cr>')

-- Highlight group for cell dividers: bold + Comment foreground
vim.api.nvim_set_hl(0, "IronCellDivider", { link = "Comment", bold = true })

vim.api.nvim_create_autocmd("FileType", {
    pattern = "python",
    desc = "Iron: cell navigation, divider highlight, and <M-CR> send",
    callback = function(ev)
        local bufnr = ev.buf
        local opts = { noremap = true, silent = true, buffer = bufnr }

        -- ]c — jump to next cell divider (#%% or # %%)
        vim.keymap.set("n", "]c", function()
            local current = vim.fn.line(".")
            local last = vim.fn.line("$")
            for lnum = current + 1, last do
                if vim.fn.getline(lnum):match("^#%s*%%%%") then
                    vim.fn.cursor(lnum, 1)
                    return
                end
            end
        end, vim.tbl_extend("force", opts, { desc = "Jump to next cell" }))

        -- [c — jump to previous cell divider (#%% or # %%)
        vim.keymap.set("n", "[c", function()
            local current = vim.fn.line(".")
            for lnum = current - 1, 1, -1 do
                if vim.fn.getline(lnum):match("^#%s*%%%%") then
                    vim.fn.cursor(lnum, 1)
                    return
                end
            end
        end, vim.tbl_extend("force", opts, { desc = "Jump to previous cell" }))

        -- <M-CR> (Alt+Enter) — send current code block and move to next (Jupyter-style)
        vim.keymap.set("n", "<M-CR>", function()
            require("iron.core").send_code_block(true)
        end, vim.tbl_extend("force", opts, { desc = "Send cell and move to next" }))

        -- Highlight #%% and # %% divider lines in the current window
        vim.fn.matchadd("IronCellDivider", [[^\s*#\s*%%]])
    end,
})

-- Re-apply cell divider highlight when a Python buffer is displayed in any new window
vim.api.nvim_create_autocmd("BufWinEnter", {
    pattern = "*.py",
    desc = "Iron: re-apply cell divider highlight on new window",
    callback = function()
        vim.fn.matchadd("IronCellDivider", [[^\s*#\s*%%]])
    end,
})
