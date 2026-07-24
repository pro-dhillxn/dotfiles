return {
    "nvim-treesitter/nvim-treesitter-textobjects",
    init = function()
        -- Disable entire built-in ftplugin mappings to avoid conflicts.
        -- See https://github.com/neovim/neovim/tree/master/runtime/ftplugin for built-in ftplugins.
        -- vim.g.no_plugin_maps = true

        -- Or, disable per filetype (add as you like)
        -- vim.g.no_python_maps = true
        -- vim.g.no_ruby_maps = true
        -- vim.g.no_rust_maps = true
        -- vim.g.no_go_maps = true
    end,
    config = function()
        local select = require("nvim-treesitter-textobjects.select")

        local map = function(lhs, query)
            vim.keymap.set({ "x", "o" }, lhs, function()
                select.select_textobject(query, "textobjects")
            end, { silent = true })
        end

        -- Functions
        map("af", "@function.outer")
        map("if", "@function.inner")

        -- Classes / structs / impls
        map("ac", "@class.outer")
        map("ic", "@class.inner")

        -- Blocks { ... }
        map("ab", "@block.outer")
        map("ib", "@block.inner")

        -- Parameters
        map("aa", "@parameter.outer")
        map("ia", "@parameter.inner")

        -- Conditionals
        map("ai", "@conditional.outer")
        map("ii", "@conditional.inner")

        -- Loops
        map("al", "@loop.outer")
        map("il", "@loop.inner")

        -- Function calls
        map("aC", "@call.outer")
        map("iC", "@call.inner")
    end
}
