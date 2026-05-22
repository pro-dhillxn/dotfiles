if vim.fn.has("win32") == 1 then
    vim.env.PATH = vim.env.PATH .. ";C:\\Program Files\\nodejs"

    -- vim.env.PATH = "C:\\Program Files\\WindowsApps\\Microsoft.PowerShell_7.5.4.0_x64__8wekyb3d8bbwe;" .. vim.env.PATH
    vim.env.PATH = "C:\\Users\\USER\\apps\\bin;" .. vim.env.PATH

    --- vim.opt.shell = "pwsh"
    -- vim.opt.shellcmdflag = "-NoLogo -NoProfile -ExecutionPolicy RemoteSigned -Command"
    -- vim.opt.shellquote = ""
    -- vim.opt.shellxquote = ""

    -- Use Git Bash as default shell on Windows
    vim.opt.shell = '"C:\\Program Files\\Git\\bin\\bash.exe"'
    vim.opt.shellcmdflag = "-lc"
    vim.opt.shellquote = ""
    vim.opt.shellxquote = ""

    -- vim.opt.guicursor = ""
    -- n-v-c-sm: Normal, Visual, Command modes (Block)
    -- i-ci-ve: Insert mode (Vertical bar)
    -- a:blinkwait0-blinkon300-blinkoff300: Match your 300ms Terminal Emulator speed
    vim.opt.guicursor = "n-v-c-sm:block,i-ci-ve:ver25,r-cr-o:hor20,a:blinkwait0-blinkon150-blinkoff150"
end



require("plugins")


require("config")

---Dbt Config (loaded lazily — keymaps call require("dbt-helpers") on demand)

-- Disable jk in lazygit
vim.api.nvim_create_autocmd("TermOpen", {
    pattern = "term://*lazygit*",
    callback = function()
        -- Temporarily disable jk/jj mappings in this buffer
        vim.keymap.set("t", "jk", "jk", { buffer = true })
        vim.keymap.set("t", "jj", "jj", { buffer = true })
    end,
})
