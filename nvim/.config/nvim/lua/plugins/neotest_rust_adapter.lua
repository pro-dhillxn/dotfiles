return {
    'mrcjkb/rustaceanvim',
    -- To avoid being surprised by breaking changes,
    -- I recommend you set a version range
    version = '^9',
    -- This plugin implements proper lazy-loading (see :h lua-plugin-lazy).
    -- No need for lazy.nvim to lazy-load it.
    lazy = false,
    init = function()
        -- rustaceanvim owns the rust-analyzer client. Do NOT also enable
        -- rust_analyzer via lspconfig, or two clients attach and you get
        -- duplicate completion/hover/inlay-hint entries.
        vim.g.rustaceanvim = {
            server = {
                default_settings = {
                    ["rust-analyzer"] = {
                        checkOnSave = true,
                        check = {
                            command = "clippy",
                        },
                        inlayHints = {
                            bindingModeHints = { enable = true },
                            chainingHints = { enable = true },
                            closingBraceHints = { enable = true },
                        },
                    },
                },
            },
        }
    end,
}
