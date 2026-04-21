# Neovim LSP and Formatter Setup

This config uses:

- `mason.nvim` to install external tools
- `mason-lspconfig.nvim` to install LSP servers
- `mason-tool-installer.nvim` to auto-install non-LSP tools like formatters
- `nvim-lspconfig` to configure and enable language servers
- `conform.nvim` to run formatters

The shared install list lives in [lua/config/mason_packages.lua](/home/user/.config/nvim/lua/config/mason_packages.lua:1).

## Add a New LSP Server

### 1. Add the Mason package

Add the Mason package name to `M.lsp_servers` in [lua/config/mason_packages.lua](/home/user/.config/nvim/lua/config/mason_packages.lua:1).

Example:

```lua
M.lsp_servers = {
  "pyright",
  "rust_analyzer",
  "gopls",
  "yamlls",
}
```

This makes Mason install the server automatically.

### 2. Default servers are enabled automatically

If the server works with the default setup, you usually do not need to change [lua/plugins/nvim-lspconfig.lua](/home/user/.config/nvim/lua/plugins/nvim-lspconfig.lua:1) at all.

Servers listed in `M.lsp_servers` are automatically enabled with the shared `on_attach` and Blink completion capabilities unless they are handled as a special case.

### 3. Use a custom config when needed

If the server needs special settings, add it to `custom_server_settings` in [lua/plugins/nvim-lspconfig.lua](/home/user/.config/nvim/lua/plugins/nvim-lspconfig.lua:1).

Example:

```lua
local custom_server_settings = {
  examplels = {
    settings = {
      example = {
        enableFeature = true,
      },
    },
  },
}
```

### 4. Reload Neovim

Restart Neovim and Mason will install the new server automatically.

### 5. Special cases

Some servers are intentionally excluded from the default flow.

- `jdtls` is installed by Mason but configured separately in [ftplugin/java.lua](/home/user/.config/nvim/ftplugin/java.lua:1)

Useful checks:

- `:Mason`
- `:LspInfo`

## Add a New Formatter

### 1. Add the Mason package

Add the package name to `M.tools` in [lua/config/mason_packages.lua](/home/user/.config/nvim/lua/config/mason_packages.lua:31).

Example:

```lua
M.tools = {
  "black",
  "stylua",
  "prettierd",
  "shfmt",
}
```

This makes Mason install the formatter binary automatically.

### 2. Add the formatter to Conform

Map the formatter to a filetype in `formatters_by_ft` in [lua/plugins/conform.lua](/home/user/.config/nvim/lua/plugins/conform.lua:15).

Example:

```lua
formatters_by_ft = {
  python = { "isort", "black" },
  lua = { "stylua" },
  ruby = { "rubocop" },
}
```

### 3. Know the naming difference

The Mason package name and the Conform formatter name are often the same, but not always.

- Mason installs the tool
- Conform uses the formatter ID it knows about

If formatting does not run, check Conform's formatter name in its docs.

### 4. Test formatting

You already have format-on-save enabled, so either:

- save the file
- press `<leader>fm`

Useful checks:

- `:Mason`
- `:ConformInfo`

## Quick Rule of Thumb

- New LSP with default settings: update `lua/config/mason_packages.lua`
- New LSP with custom settings: update `lua/config/mason_packages.lua` and `lua/plugins/nvim-lspconfig.lua`
- New formatter: update `lua/config/mason_packages.lua` and `lua/plugins/conform.lua`

## Example

To add YAML support:

1. Add `"yamlls"` to `M.lsp_servers`
2. Restart Neovim

To add a Ruby formatter:

1. Add the Mason package for the formatter to `M.tools`
2. Add `ruby = { "rubocop" }` to `formatters_by_ft`
3. Restart Neovim and test with `<leader>fm`
