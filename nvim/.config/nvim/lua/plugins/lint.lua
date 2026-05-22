return {
    "mfussenegger/nvim-lint",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
        local lint = require("lint")

        lint.linters_by_ft = {
            python = {},
            -- sql    = { "sqlfluff" },
            -- lua_ls already covers lua well, luacheck is optional
            -- lua = { "luacheck" },
        }
        vim.api.nvim_create_autocmd({ "BufWritePost" }, { -- removed BufEnter + InsertLeave
            group = vim.api.nvim_create_augroup("nvim-lint", { clear = true }),
            callback = function()
                require("lint").try_lint()
            end,
        })
    end,
}
