# Neovim LSP and Formatter Setup

## Java

Open a `.java` file and let JDT LS finish importing/indexing the project. Mason
installs `jdtls` and `google-java-format`; the server launcher requires Java 21+
and Python 3.9+. This machine already has Java 25 and Python installed.

Project detection starts at the file and recognizes Maven, Gradle (including
Kotlin build scripts), Eclipse and Git projects. A standalone file uses its own
directory. Each project gets a separate JDT LS workspace based on its full path,
so launching Neovim from another directory does not mix project metadata.
Save a newly created file if JDT LS has not indexed it yet.

Completion appears as you type. Use `Ctrl-Space` to request it manually,
`Ctrl-n` / `Ctrl-p` to select an item, and `Tab` to accept it. After expanding a
snippet, use `Ctrl-j` / `Ctrl-k` to move between placeholders.

Type a snippet prefix, select it in completion, then press `Tab`:

| Prefix | Expansion |
| --- | --- |
| `sout`, `sysout` | `System.out.println(...)` |
| `souf` | `System.out.printf(...)` |
| `serr` | `System.err.println(...)` |
| `psvm`, `main` | `public static void main(String[] args)` |
| `class`, `interface` | Public class/interface named after the file |
| `fori` | Indexed for loop |
| `foreach`, `iter` | Enhanced for loop |
| `if`, `trycatch`, `tryr` | Conditional / exception handling |
| `psf` | `public static final` constant |
| `pum`, `prim`, `prom` | Public/private/protected method |

In insert mode, `Ctrl-g` followed by `p` immediately inserts
`System.out.println();` with the cursor inside the parentheses. It also works
while the server is starting.

`<leader>` is **Space**. Java navigation and actions:

| Keys | Action |
| --- | --- |
| `gd`, `gr` | Definition / references |
| `gi`, `gt` | Implementation / type definition |
| `gI`, `gO` | Incoming / outgoing calls |
| `Space fs`, `Space fS` | Symbols in file / project |
| `Space ff`, `Space fw` | Find files / search project text |
| `K` | Documentation under cursor |
| `Space rn`, `Space ca` | Rename / code actions (including generating methods) |
| `Space oi` | Organize imports |
| `[d`, `]d`, `Space d` | Previous / next diagnostic / diagnostic details |
| `Space fm` | Format (also runs on save) |
| `Space crv`, `Space crc` | Extract variable / constant; also supports selections |
| `Space crm` | Extract selected code into a method |

Your existing jump mappings are reversed from Vim's defaults: `Ctrl-i` goes
back after a jump, and `Ctrl-o` goes forward.

If completion is missing, check `:LspInfo` for an attached `jdtls` client and
`:messages` / `:JdtShowLogs` for import errors. If Mason has just installed the
server, reopen the buffer (or run `:set ft=java`).
You can also run `:MasonInstall jdtls` if the server is absent.

The project `hw-2-oop-polishedblades` currently uses Gradle 9.0.0 with the system
Java 25. [Gradle supports Java 25 starting with 9.1.0](https://docs.gradle.org/current/userguide/compatibility.html#java_runtime).
For that project, upgrade its Gradle wrapper to 9.1+ or run Neovim with a
compatible JDK (for example Java 21 via `JAVA_HOME`). The JDT LS launcher honors
`JAVA_HOME`. Failed build imports can prevent project completion and navigation.

Optional next addition: Java debugging and running individual JUnit tests through
`nvim-dap`, `java-debug-adapter` and `java-test` (not configured here).
See the [nvim-jdtls documentation](https://github.com/mfussenegger/nvim-jdtls)
and [Blink snippet documentation](https://cmp.saghen.dev/configuration/snippets).

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
