return {
  "folke/which-key.nvim",
  event = "VeryLazy",
  opts = {
    -- your configuration comes here
    -- or leave it empty to use the default settings
    -- refer to the configuration section below
    spec = {
      { "<leader>s", group = "send" },
      { "<leader>r", group = "repl" },
      { "<leader>m", group = "mark" },
      { "<leader>b", group = "buffer" },
      { "<leader>f", group = "file" },
      { "<leader>d", group = "dbt" },
      { "<leader>t", group = "terminal" },
      { "<leader>a", group = "aerial" },
    },
  },
  keys = {
    {
      "<leader>?",
      function()
        require("which-key").show({ global = false })
      end,
      desc = "Buffer Local Keymaps (which-key)",
    },
  },
}
