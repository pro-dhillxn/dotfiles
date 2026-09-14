return {
    "pro-dhillxn/databricks-nvim",
    lazy = false,                           -- tiny; load at start
    config = function()
        require("databricks-nvim").setup()  -- core (signs, hl, opts)
        require("databricks-nvim.commands") -- autocmds + user commands
    end,
}
