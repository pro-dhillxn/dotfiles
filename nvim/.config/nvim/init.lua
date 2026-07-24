if vim.fn.has("win32") == 1 then
    vim.env.PATH = vim.env.PATH .. ";C:\\Program Files\\nodejs"

    vim.env.PATH = (vim.env.USERPROFILE or "") .. "\\apps\\bin;" .. vim.env.PATH
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
