return {
    "nvim-neotest/neotest",
    dependencies = {
        "nvim-neotest/nvim-nio",
        "antoinemadec/FixCursorHold.nvim",
        "nvim-treesitter/nvim-treesitter",
    },
    keys = {
        { "<leader>tt", function() require("neotest").run.run() end,                     desc = "Run nearest test" },
        { "<leader>tf", function() require("neotest").run.run(vim.fn.expand("%")) end,   desc = "Run current file" },
        { "<leader>ts", function() require("neotest").summary.toggle() end,              desc = "Toggle test summary" },
        { "<leader>to", function() require("neotest").output.open({ enter = true }) end, desc = "Show test output" },
        { "<leader>tO", function() require("neotest").output_panel.toggle() end,         desc = "Toggle output panel" },
        { "<leader>tS", function() require("neotest").run.stop() end,                    desc = "Stop test" },
    },
    config = function()
        require("neotest").setup({
            adapters = {
                require("rustaceanvim.neotest"),
            },
        })
    end,
}
