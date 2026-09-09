return {
    "stevearc/conform.nvim",
    event = { "BufReadPre", "BufNewFile" },
    opts = {
        formatters_by_ft = {
            lua    = { "stylua" },
            python = { "ruff_organize_imports", "ruff_format" },
            -- sql    = { "sqlfluff" },
        },
        format_on_save = {
            lsp_format = "fallback",
            timeout_ms = 10000,
        },
    },

    keys = {
        {
            "<leader>ft",
            function() require("conform").format({ async = true }) end,
            desc = "Format buffer",
        },
    },
}
