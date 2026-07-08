return {
  "nvim-treesitter/nvim-treesitter",
  branch = "main",
  event = { "VeryLazy" },
  lazy = vim.fn.argc(-1) == 0, -- load treesitter early when opening a file from the cmdline
  build = ":TSUpdate",
  config = function()
    local ts = require("nvim-treesitter")

    ts.setup({})

    -- Parsers to keep installed (replaces the legacy `ensure_installed`).
    local ensure_installed = {
      "bash",
      "c",
      "diff",
      "html",
      "javascript",
      "jsdoc",
      "json",
      "lua",
      "luadoc",
      "luap",
      "markdown",
      "markdown_inline",
      "printf",
      "python",
      "query",
      "regex",
      "toml",
      "tsx",
      "typescript",
      "vim",
      "vimdoc",
      "xml",
      "yaml",
      "rust",
      "go",
    }
    ts.install(ensure_installed)

    -- On the `main` branch there is no highlight/indent module; highlighting is
    -- core-driven via `vim.treesitter.start()`. Enable it (and the experimental
    -- treesitter indent) for any filetype that has an available parser.
    vim.api.nvim_create_autocmd("FileType", {
      group = vim.api.nvim_create_augroup("user_treesitter", { clear = true }),
      callback = function(args)
        local buf = args.buf
        local ft = vim.bo[buf].filetype
        local lang = vim.treesitter.language.get_lang(ft)
        if not lang then
          return
        end

        -- Install the parser on demand if it is missing (approximates the old
        -- `auto_install = true`), then start highlighting once it is available.
        if not pcall(vim.treesitter.language.add, lang) then
          ts.install({ lang })
          return
        end

        pcall(vim.treesitter.start, buf, lang)
        -- experimental main-branch treesitter indentation
        vim.bo[buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
      end,
    })
  end,
}
