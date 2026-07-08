# Agent Notes

## Project Overview

This is a personal Neovim configuration written in Lua and managed with
lazy.nvim.

- `init.lua` only loads `lua/config/init.lua`.
- `lua/config/init.lua` loads globals, options, keymaps, highlight groups, and
  autocmds, then bootstraps lazy.nvim and loads plugin specs from `lua/plugins`.
- `lua/plugins/*.lua` are one-file lazy.nvim specs. Prefer adding or changing a
  focused plugin spec over creating broad central registries.
- `lua/config/mason_packages.lua` is the shared source of truth for Mason LSP
  servers and external formatter/tool installs.
- `lua/plugins/nvim-lspconfig.lua` enables most LSP servers from the shared
  Mason list with common Blink capabilities and `utils.lsp_on_attach`.
- `ftplugin/java.lua` owns the JDTLS setup. `jdtls` is intentionally excluded
  from the generic LSP loop.
- `snippets/` contains VS Code-style snippet JSON files and `snippets/package.json`.
- `old_snippets/` is historical snippet material; do not migrate it unless asked.

## Local Style

- Follow the style of the file you touch. Most Lua files use two-space
  indentation, while a few older utility files use tabs.
- Keep plugin specs small and declarative. Use `config = function()` only when
  the plugin needs imperative setup.
- Put general keymaps in `lua/config/keymaps.lua`; put buffer-local LSP keymaps
  in `lua/utils/lsp_on_attach.lua`; keep Java-only actions in `ftplugin/java.lua`.
- When adding a new LSP or formatter, update the Mason package list first and
  then the consumer config. The README has the detailed flow.
- Preserve user muscle memory. Keymap changes should be intentional and called
  out clearly.

## Validation

Use a headless load check after config changes:

```sh
NVIM_LOG_FILE=/tmp/nvim-agent.log nvim --headless --cmd 'set shada=' '+lua print("config loaded")' '+qa'
```

Notes:

- `--cmd 'set shada='` avoids ShaDa writes outside the workspace in restricted
  sandboxes.
- `NVIM_LOG_FILE=/tmp/nvim-agent.log` avoids updating the local `nvim.log`.
- For LSP/formatter work, also verify interactively with `:Mason`, `:LspInfo`,
  `:ConformInfo`, and `<leader>fm` when possible.

## Findings From Project Review

- The config currently loads successfully under Neovim `0.12.4` with the
  headless command above.
- `snippets/package.json` references `./python.json`, `./lua.json`, and
  `./allFiletypes.json`, but those files are not present. Add the files or remove
  the manifest entries before relying on those snippet contributions.
- Treesitter runs on `branch = "main"` (the maintained, Neovim 0.11+-compatible
  rewrite). There is no module system: `lua/plugins/nvim-treesitter.lua` calls
  `require("nvim-treesitter").install(...)` for parsers and starts highlighting +
  the experimental `indentexpr` from a `FileType` autocmd via `vim.treesitter.start()`.
  The `main` branch builds parsers with the `tree-sitter` CLI, so `tree-sitter-cli`
  is listed in `lua/config/mason_packages.lua`. Keep the spec and the
  `lazy-lock.json` branch entry on `main`.
- `nvim-ts-autotag` is its own spec (`lua/plugins/nvim-ts-autotag.lua`) now that the
  legacy `autotag` module option is gone. The old `nvim-treesitter/playground`
  plugin was removed; use Neovim's built-in `:InspectTree` / `:Inspect` instead.
- Markdown Treesitter highlighting is enabled and works on Neovim 0.12. The previous
  fenced-code-block crash was caused by the archived `master` branch shipping query
  directives written for the pre-0.11 treesitter API; the `main` branch migration
  fixed it. No markdown-specific guard is needed.
- `conform.nvim` is configured with `lsp_fallback`; verify the current Conform
  option names before major plugin updates.
- `lua/config/init.lua` uses `vim.loop.fs_stat`, and `lua/config/autocmds.lua`
  uses `vim.api.nvim_buf_set_option`. These still load, but are compatibility
  watch points for future Neovim API cleanup.

## Git Hygiene

- Expect this repo to have local personal changes. Check `git status --short`
  before editing and do not revert unrelated files.
- Do not hand-edit `lazy-lock.json` unless the requested change is explicitly
  about lockfile state. Let lazy.nvim update it during plugin updates.
- Avoid deleting logs, generated state, or untracked local files unless the user
  explicitly asks.

