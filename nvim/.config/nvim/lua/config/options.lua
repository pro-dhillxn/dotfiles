-- Leaders must be set before lazy.nvim loads
vim.g.mapleader = " "
vim.g.maplocalleader = " "

local opt = vim.opt

-- line numbers
opt.number = true

-- tab and indents
opt.tabstop = 4       -- Tab means 4 spaces
opt.softtabstop = 4
opt.shiftwidth = 4    -- 4 spaces for indent width
opt.expandtab = true  -- Expands tab to spaces
opt.autoindent = true -- Copy indent from current line

-- Search settings
opt.ignorecase = true -- Ignore case when searching
opt.smartcase = true  -- Unless capital letter in search

-- Appearance
opt.termguicolors = true -- True color support
opt.cursorline = true
opt.scrolloff = 6        -- padding above and below when scrolling
opt.showmode = false

-- Behavior
opt.mouse = 'a' -- mouse support
opt.splitright = true
opt.splitbelow = true
opt.signcolumn = "yes" -- show git diagnostics and all signs overlayed on line nums instead of left margin.


-- Clipboard Setup using clip.exe for WSL:
if vim.fn.has("wsl") == 1 then
    vim.g.clipboard = {
        name = "WslClipboard",
        copy = {
            ["+"] = "clip.exe",
            ["*"] = "clip.exe",
        },
        paste = {
            ["+"] = 'powershell.exe -NoProfile -Command Get-Clipboard',
            ["*"] = 'powershell.exe -NoProfile -Command Get-Clipboard',
        },
        cache_enabled = 0,
    }
end

vim.opt.clipboard = "unnamedplus" -- use system clipboard

-- Backups
opt.swapfile = true -- yes we want it
opt.undofile = true -- enable persistent undo

-- Folds
opt.foldmethod = "expr"
opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
opt.foldenable = false

-- C Compiler mingw for windows
if vim.fn.has("win32") == 1 then
    vim.env.CC = "gcc"
end
