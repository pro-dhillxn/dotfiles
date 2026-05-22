require('mini.files').setup()

vim.keymap.set("n", "<leader>e", ":lua MiniFiles.open()<CR>", { desc = "Open Mini Files Explorer" })
