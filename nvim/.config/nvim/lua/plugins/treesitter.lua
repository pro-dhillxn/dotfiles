return {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    lazy = false,

    config = function()
        require("nvim-treesitter").setup({
            ensure_installed = {
                "lua",
                "vim",
                "vimdoc",
                "python",
                "sql",
                "yaml",
                "rust",
                "json",
                "jsonc", -- optional but useful
            },

            auto_install = true,

            highlight = {
                enable = true,
            },

            indent = {
                enable = true,
            },

            incremental_selection = {
                enable = true,
                keymaps = {
                    init_selection = "<CR>",
                    node_incremental = "<CR>",
                    scope_incremental = "<Tab>",
                    node_decremental = "<S-CR>",
                },
            },
        })
    end,
}
-- On windows, tree-sitter build defaults to cl.exe (MSVC) which isn't installed. Fix it by setting CC=gcc to sue our MingW GCC at ~/.local/mingw64/bin/gcc.exe
-- Since auto_install = true is set in our config, future parsers for new file types will also need CC=gcc in the environment where Neovim is launched - otherwise they will fail
