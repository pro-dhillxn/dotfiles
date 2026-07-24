local lspconfig = require('lspconfig')
local configs = require('lspconfig.configs')

if vim.fn.executable("ferrodata") == 0 then
    return
end

if not configs.ferrodata then
    configs.ferrodata = {
        default_config = {
            cmd = { 'ferrodata' },
            filetypes = { 'sql' },
            root_dir = lspconfig.util.root_pattern('dbt_project.yml'),
            name = 'ferrodata',
        },
    }
end

lspconfig.ferrodata.setup({})
