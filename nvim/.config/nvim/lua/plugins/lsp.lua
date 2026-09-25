return {
    -- 1. blink.cmp — declare first so it's clearly a dep of the LSP setup
    {
        "saghen/blink.cmp",
        version = "1.*",
        event = "InsertEnter",
        opts = {
            keymap = { preset = "super-tab" },
            appearance = { nerd_font_variant = "mono" },
            sources = { default = { "lsp", "path", "snippets", "buffer" } },
            -- https://cmp.saghen.dev/configuration/completion.html#menu
            completion = {
                documentation = { auto_show = true, auto_show_delay_ms = 200 },
                ghost_text = { enabled = true },
                menu = {
                    draw = {
                        columns = { { "kind_icon" }, { "label", "label_description", gap = 1 }, { "source_name" } },
                    },
                },
            },
            snippets = { preset = "default" },
            fuzzy = { implementation = "prefer_rust_with_warning" },
        },
    },

    -- 2. mason-lspconfig — owns the dep chain for the whole LSP stack
    {
        "mason-org/mason-lspconfig.nvim",
        -- event = "BufReadPre",
        lazy = false,
        dependencies = {
            { "mason-org/mason.nvim", opts = {} },
            "neovim/nvim-lspconfig",
            "saghen/blink.cmp", -- ensures capabilities patched before servers start
        },
        opts = {
            ensure_installed = { "lua_ls", "basedpyright", "rust_analyzer", "yamlls", "html", "htmx", "jsonls", "ruff", "tailwindcss" },
            automatic_enable = false,
        },
    },
}
