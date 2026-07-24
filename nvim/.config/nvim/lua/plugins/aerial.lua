return {
    'stevearc/aerial.nvim',
    opts = {
        -- Disable aerial on files with this many lines
        disable_max_lines = 80000,
    },
    cmd = { 'AerialToggle' },
    -- Optional dependencies
    dependencies = {
        "nvim-treesitter/nvim-treesitter",
        "nvim-tree/nvim-web-devicons"
    },
}
