return {
    'nvim-lualine/lualine.nvim',
    event = "VeryLazy",
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    opts = {
        theme = 'kanagawa',
        tabline = {
            lualine_a = { function()
                local count = #vim.fn.getbufinfo({ buflisted = 1 })
                return "(" .. count .. ")"
            end },
            lualine_b = { 'buffers' },
        }
    }
}

-- require('lualine').setup({
--   tabline = {
--     lualine_a = { 'mode' }, -- Displays the mode in the top-left
--     lualine_b = { 'branch' },
--     lualine_c = { { 'filename', path = 1 } }, -- Full path in top-middle
--   }
-- })
