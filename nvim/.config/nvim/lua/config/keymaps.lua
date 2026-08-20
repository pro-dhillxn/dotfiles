local keymap = vim.keymap

keymap.set({ "n", "v" }, "<Space>", "<Nop>", { silent = true })

keymap.set("i", "jk", "<Esc>", { desc = "Insert/Terminal to Normal Mode with jk" })
keymap.set("i", "jj", "<Esc>", { desc = "Insert/Terminal to Normal Mode with jj" })


-- Map Alt + hjkl in Insert mode
local enabledModes = { "i", "c", "o", "t", "s", "x" }
for _, mode in ipairs(enabledModes) do
    vim.keymap.set(mode, "<A-h>", "<Left>", { noremap = true, silent = true })
    vim.keymap.set(mode, "<A-j>", "<Down>", { noremap = true, silent = true })
    vim.keymap.set(mode, "<A-k>", "<Up>", { noremap = true, silent = true })
    vim.keymap.set(mode, "<A-l>", "<Right>", { noremap = true, silent = true })
end

-- Window Navigation
keymap.set("n", "<C-h>", "<C-w>h", { desc = "Go to left window" })
keymap.set("n", "<C-j>", "<C-w>j", { desc = "Go to lower window" })
keymap.set("n", "<C-k>", "<C-w>k", { desc = "Go to upper window" })
keymap.set("n", "<C-l>", "<C-w>l", { desc = "Go to right window" })

-- Better Indenting (Keeping the cursor in Visual Mode)
keymap.set("v", ">", ">gv", { desc = "Indent Right", noremap = true, silent = true })
keymap.set("v", "<", "<gv", { desc = "Indent Left", noremap = true, silent = true })

-- Clear search highlights (after we press Esc)
keymap.set("n", "<Esc>", ":nohl<CR>", { desc = "Clear search highlights", noremap = true, silent = true })

keymap.set("v", "J", ":m '>+1<CR>gv=gv", { desc = "moves lines down in visual selection" })
keymap.set("v", "K", ":m '<-2<CR>gv=gv", { desc = "moves lines up in visual selection" })

-- Preventing clipboard pollution
vim.keymap.set({ "n", "v" }, "<Del>", '"_d', { desc = "Delete without yank", noremap = true, silent = true })
vim.keymap.set("n", "x", '"_x', { desc = "Delete chars without yank", noremap = true, silent = true })


--  Opening the file in right split
vim.keymap.set("n", "<leader>sr", function()
    local api = require("nvim-tree.api")
    local node = api.tree.get_node_under_cursor()

    if node and node.type == "file" then
        vim.cmd("vsplit " .. node.absolute_path)
    end
end, { desc = "Vertical Split file on the Right" })

-- -- Replace the selection in current buffer
-- vim.keymap.set("v", "<leader>s", function()
--     -- copy selection
--     vim.cmd('normal! "vy')
--
--     -- escape special regex chars
--     local text = vim.fn.escape(vim.fn.getreg("v"), [[\/.*$^~[]])
--
--     -- open replace command for whole buffer with selection filled in
--     vim.fn.feedkeys(":%s/" .. text .. "/", "n")
-- end, { desc = "Replace the visual selection from buffer", noremap = true, silent = true })

-- Split windows
-- (<leader>sv and <leader>sh removed; use <C-w>v / <C-w>s directly)


-- File Related operations
-- Copy File Path to Clipboard
keymap.set("n", "<leader>fp", function()
    local filepath = vim.fn.expand("%:p") --file path from Root (Use "%:~" to get relative to home)
    vim.fn.setreg("+", filepath)          -- Copy the file path to clipboard register
    print("File Path Copied to Clipboard: " .. filepath)
end, { desc = "Copy Complete File Path" })

-- Temporary Explorer
keymap.set("n", "-", "<cmd>Ex<CR>", { desc = "Open Netrw file explorer" })



-- Buffer management
keymap.set("n", "<S-h>", ":bprev<CR>", { desc = "Previous buffer" })
keymap.set("n", "<S-l>", ":bnext<CR>", { desc = "Next buffer" })
keymap.set("n", "<leader>bd", ":bdelete<CR>", { desc = "Delete buffer" })
keymap.set("n", "<leader>bD", ":bdelete!<CR>", { desc = "Delete buffer Hard" })
-- <leader><leader> is handled by the telescope plugin spec (lazy keys)

-- Window management
keymap.set("n", "<C-Up>", "<cmd>resize +2<cr>", { desc = "Increase Height" })
keymap.set("n", "<C-Down>", "<cmd>resize -2<cr>", { desc = "Decrease Height" })
keymap.set("n", "<C-Right>", "<cmd>vertical resize +2<cr>", { desc = "Increase Width" })
keymap.set("n", "<C-Left>", "<cmd>vertical resize -2<cr>", { desc = "Decrease Width" })


-- Terminal Management
keymap.set('t', '<Esc>', '<C-\\><C-n>', { noremap = true, silent = true })
keymap.set('t', 'jk', '<C-\\><C-n>', { noremap = true, silent = true })


-- run current python file
vim.keymap.set(
    "n",
    "<leader>rp",
    function()
        local filepath = vim.fn.expand("%:p");
        vim.cmd(":terminal python " .. vim.fn.shellescape(filepath))
    end,
    {
        desc = "Run Current Python File"
    }
)

-- -- dbt-helpers keybindings
-- vim.keymap.set("n", "<leader>dr", function()
--     require("dbt-helpers").insert_ref()
-- end, { desc = "dbt: Insert ref() manually" })
--
-- vim.keymap.set("n", "<leader>dR", function()
--     require("dbt-helpers").insert_ref_interactive()
-- end, { desc = "dbt: Insert ref() interactively" })
--
-- vim.keymap.set("n", "<leader>ds", function()
--     require("dbt-helpers").insert_source()
-- end, { desc = "dbt: Insert source()" })
--
-- vim.keymap.set("n", "<leader>dc", function()
--     require("dbt-helpers").refresh_model_cache()
-- end, { desc = "dbt: Clear model cache" })


-- Aerial (Outline)
vim.keymap.set("n", "<leader>aa", "<cmd>AerialToggle!<CR>")


-- Python - Jupyter file related:
-- Cell Creation
keymap.set(
    "n",
    "<leader>rc",
    "o# %% <CR><CR># %%<Up>",
    { desc = "Create a new Python Cell at current location" }
)


-- -- treesitter keymaps
-- vim.keymap.set({ "x", "o" }, "af", function()
--     require("nvim-treesitter-textobjects.select").select_textobject("@function.outer", "textobjects")
-- end)

vim.keymap.set("n", "<leader>tr", function() require("neotest").run.run() end, { desc = "Run Nearest Test" })

-- Toggle the interactive visual test summary panel (great for big applications)
vim.keymap.set("n", "<leader>ts", function() require("neotest").summary.toggle() end, { desc = "Toggle Test Summary" })

-- Toggle the output panel for the current test to see print statements/panics
vim.keymap.set("n", "<leader>to", function() require("neotest").output_panel.toggle() end,
    { desc = "Toggle Output Panel" })
