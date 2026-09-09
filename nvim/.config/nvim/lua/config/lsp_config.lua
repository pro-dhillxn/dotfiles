-- PYTHON

vim.lsp.config("basedpyright", {
    settings = {
        basedpyright = {
            analysis = {
                typeCheckingMode = "basic",
                diagnosticMode = "openFilesOnly",
            },
            inlayHints = {
                variableTypes = true,
                functionReturnTypes = true,
                callArgumentNames = true,
                genericTypes = true,
            },
        },
    },
})

-- The Ruff LSP configuration
vim.lsp.config("ruff", {
    settings = {
        -- This tells Ruff's LSP to use its native linting engine
        lint = {
            enable = true,
            -- Optional: tells ruff to run on text change, or save
            run = "onType",
        },
    },
    -- Prevent duplicate hover popups (Let Basedpyright handle hover documentation)
    on_attach = function(client, _bufnr) -- keeping bufnr for any future code actions needed
        if client.name == "ruff" then
            client.server_capabilities.hoverProvider = false
        end
    end,
})


-- NOTE: rust-analyzer is intentionally NOT configured or enabled here.
-- rustaceanvim (see lua/plugins/neotest_rust_adapter.lua) owns the
-- rust-analyzer client. Enabling it via lspconfig too would attach a
-- second client, causing duplicate completion/hover/inlay entries.


vim.lsp.config('lua_ls', {
    settings = {
        Lua = {
            diagnostics = {
                globals = { 'vim' }, -- stop 'vim' being flagged as undefined
            },
        },
    },
})

vim.lsp.config('yamlls', {})

vim.lsp.config('jsonls', {})

vim.lsp.enable({ "lua_ls", "basedpyright", "ruff", "yamlls", "jsonls" })

-- ── Diagnostic appearance ─────────────────────────────────────────
vim.diagnostic.config({
    virtual_text = {
        prefix = "●",
        spacing = 4,
    },
    signs = true,
    underline = true,
    update_in_insert = false,
    severity_sort = true,
    float = {
        border = "rounded",
        source = true,
    },
})

-- ── Diagnostic keymaps (global, always available) ─────────────────
vim.keymap.set("n", "[d", function() vim.diagnostic.jump({ count = -1, float = true }) end, { desc = "Prev diagnostic" })
vim.keymap.set("n", "]d", function() vim.diagnostic.jump({ count = 1, float = true }) end, { desc = "Next diagnostic" })
vim.keymap.set("n", "<leader>dd", vim.diagnostic.open_float, { desc = "Show line diagnostics" })
vim.keymap.set("n", "<leader>dl", vim.diagnostic.setloclist, { desc = "Diagnostics loclist" })

-- ── LSP keymaps (only when a server is attached) ──────────────────
vim.api.nvim_create_autocmd("LspAttach", {
    group = vim.api.nvim_create_augroup("lsp-keymaps", { clear = true }),
    callback = function(event)
        local map = function(k, f, d)
            vim.keymap.set("n", k, f, { buffer = event.buf, desc = "LSP: " .. d })
        end
        map("gd", vim.lsp.buf.definition, "Go to Definition")
        map("gD", vim.lsp.buf.declaration, "Go to Declaration")
        map("gr", vim.lsp.buf.references, "Find References")
        map("gi", vim.lsp.buf.implementation, "Go to Implementation")
        map("K", vim.lsp.buf.hover, "Hover Documentation")
        map("<leader>rn", vim.lsp.buf.rename, "Rename Symbol")
        map("<leader>ca", vim.lsp.buf.code_action, "Code Action")

        local bufnr = event.buf
        vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
        vim.keymap.set("n", "<leader>ih", function()
            vim.lsp.inlay_hint.enable(
                not vim.lsp.inlay_hint.is_enabled({ bufnr = bufnr }),
                { bufnr = bufnr }
            )
        end, { buffer = bufnr, desc = "LSP: Toggle inlay hints" })
    end,
})
