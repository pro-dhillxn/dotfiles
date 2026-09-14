---
name: nvim-plugin-dev
description: Use whenever writing, editing, or debugging a Neovim plugin (Lua) targeting Neovim 0.12+. Also use whenever generating code that touches vim.api, vim.lsp, vim.diagnostic, vim.pack, autocommands, or any :help topic — Neovim 0.12 introduced significant breaking changes and new APIs, and memorized knowledge of the Neovim API is very likely stale or wrong. Trigger this even if the user doesn't mention a version number.
---

# Neovim (0.12+) Plugin Dev

Your training data almost certainly predates Neovim 0.12 (March 2026) and its
changes. Do not trust memorized signatures for `vim.api.*`, `vim.lsp.*`,
`vim.diagnostic.*`, or autocommand behavior without checking. Wrong assumptions
here produce code that fails silently or errors on load — check first.

## Where to look, in order

1. **Local `:help`, not the web, is the source of truth.** It matches the
   exact Neovim binary the user is running, including any dev/nightly build.
   Read it via the shell, not by guessing from memory:
   ```sh
   nvim --version                        # confirm exact version first
   nvim -es -c 'set rtp+=.' -c 'help api' -c 'w! /tmp/h.txt' -c 'q'  # dump a help page to a file to read
   ```
   Or if you have a running Neovim + a way to send commands to it, use
   `:help <topic>` directly and read the output.

2. **Check the changelog for the running version before writing API code.**
   Every release has `:help news-<version>` (e.g. `:help news-0.12`) listing
   breaking changes and new functions. If the plugin does anything with
   autocommands, diagnostics, LSP config, or the sign/extmark APIs, read the
   news file for every version between what you'd assume and the actual
   version — deprecations often land quietly two releases before removal.

3. **Key things that changed around 0.12 — verify against `:help` rather than
   assuming either the old or new behavior:**
   - LSP server setup moved toward `vim.lsp.config[...]` + `vim.lsp.enable(...)`
     instead of `require('lspconfig').X.setup{}` (the old pattern still works
     but isn't the only path anymore — check which the user's config uses).
   - `vim.diagnostic.disable()` / `is_disabled()` and the legacy
     `vim.diagnostic.enable()` signature are gone; diagnostic signs can no
     longer be set via `:sign-define`/`sign_define()`.
   - `nvim_create_autocmd()`, `nvim_exec_autocmds()`, `nvim_clear_autocmds()`
     no longer treat an empty (non-nil) `pattern`/`event` as nil — an empty
     string/array now means "match nothing," not "match everything."
   - `vim.pack` is a new built-in plugin manager — don't assume the user needs
     lazy.nvim/packer, and don't assume `vim.pack` exists on versions <0.12.
   - New Lua helpers exist (`vim.net.request`, `vim.fs.ext`, `vim.list.unique`,
     `vim.list.bisect`, etc.) — check `:help lua-vim` before hand-rolling
     something one of these already does.

4. **If `:help` isn't available in the environment** (e.g. no Neovim binary
   handy, just editing files), fetch the canonical docs instead of relying on
   memory:
   - https://neovim.io/doc/user/ — full user manual, generated from source
   - https://neovim.io/doc/user/news-0.12/ (and news-<version> for whatever
     version is in play) — authoritative breaking-change list
   - https://neovim.io/doc/user/api.html — full `vim.api` reference

## Workflow

1. Get the exact Neovim version in play (`nvim --version`, or ask if unknown
   — don't assume "0.12" means a specific patch release).
2. Before using any API you're not 100% sure of, look it up per above rather
   than pattern-matching to pre-0.12 conventions.
3. When something could plausibly have changed (autocmd semantics, LSP setup,
   diagnostics, sign/extmark APIs, plugin management), explicitly check the
   news file for that version range instead of guessing.
4. If local docs and web docs disagree, trust local `:help` — it reflects the
   binary actually running.
