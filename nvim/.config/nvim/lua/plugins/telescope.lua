return {
    'nvim-telescope/telescope.nvim',
    version = '*',
    cmd = "Telescope",
    keys = {
        { '<leader>ff',       '<cmd>Telescope find_files<cr>',                                                             desc = 'Telescope find files' },
        { '<leader>fg',       '<cmd>Telescope live_grep<cr>',                                                              desc = 'Telescope live grep' },
        { '<leader>fb',       '<cmd>Telescope buffers sort_mru=true sort_lastused=true initial_mode=normal theme=ivy<cr>', desc = 'Telescope buffers' },
        { '<leader>fh',       '<cmd>Telescope help_tags<cr>',                                                              desc = 'Telescope help tags' },
        { '<leader><leader>', '<cmd>Telescope buffers sort_mru=true sort_lastused=true initial_mode=normal theme=ivy<cr>', desc = 'Telescope buffers' },
    },
    dependencies = {
        'nvim-lua/plenary.nvim',
        -- optional but recommended
        { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' }
    },
    config = function()
        require("telescope").setup({
            pickers = {
                buffers = {
                    path_display = function(_, path)
                        local parent = vim.fn.fnamemodify(path, ":h:t")
                        local name = vim.fn.fnamemodify(path, ":t")

                        if parent == "." then
                            return name
                        end

                        return parent .. "/" .. name
                    end,
                    mappings = {
                        n = {
                            ["x"] = require("telescope.actions").delete_buffer,
                            ["q"] = require("telescope.actions").close
                        }
                    }
                }
            }
        })
    end
}
