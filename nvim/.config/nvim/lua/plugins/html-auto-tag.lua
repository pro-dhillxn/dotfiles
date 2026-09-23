return {
    "windwp/nvim-ts-autotag",
    -- event = "VeryLazy",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    config = function()
        require("nvim-ts-autotag").setup({
            -- This is the new nested layout the plugin now expects
            opts = {
                enable_close = true,           -- Auto-close tags when typing '>'
                enable_rename = true,          -- Rename closing tag when you edit the opening tag
                enable_close_on_slash = false, -- Closes tag when typing '</' instead of '>'
            },
        })
    end,
}
