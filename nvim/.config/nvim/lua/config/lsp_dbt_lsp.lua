vim.lsp.config('dbt_fusion_lsp', {
    cmd = {
        'dbt', 'lsp',
        '--profiles-dir', vim.fn.expand('~/.dbt'),
        '--static-analysis', 'strict', '--log-level', 'debug'
    },
    filetypes = { 'sql', 'yaml' },
    root_markers = { 'dbt_project.yml', 'dbt_project.yaml' },
})

vim.lsp.enable('dbt_fusion_lsp')
