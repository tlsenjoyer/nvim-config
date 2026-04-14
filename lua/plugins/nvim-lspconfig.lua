local on_attach = require("utils.lsp_on_attach")

return {
  "neovim/nvim-lspconfig",
  event = { "BufReadPre", "BufNewFile" },
  dependencies = {
    { "antosha417/nvim-lsp-file-operations", config = true },
    "saghen/blink.cmp"
  },
  config = function()
    -- Change the Diagnostic symbols in the sign column (gutter)
    vim.diagnostic.config({
      signs = {
        text = {
          [vim.diagnostic.severity.ERROR] = " ",
          [vim.diagnostic.severity.WARN] = " ",
          [vim.diagnostic.severity.INFO] = "󰋼 ",
          [vim.diagnostic.severity.HINT] = "󰌵 ",
        },
      },
    })

    -- used to enable autocompletion (assign to every lsp server config)
    local capabilities = require('blink.cmp').get_lsp_capabilities()
    local servers_with_default_options = {
      "marksman",
      "markdown_oxide",
      "prismals",
      "pyright",
      "html",
      "ts_ls",
      "cssls",
      "tailwindcss",
      "taplo",
      "css_variables",
      "cssmodules_ls",
      "gopls",
      "svelte",
      "clangd",
      "graphql",
      "emmet_ls",
      "ansiblels"
    }

    for _, server in ipairs(servers_with_default_options) do
      vim.lsp.config(server, { capabilities = capabilities, on_attach = on_attach })
      vim.lsp.enable(server)
    end

    vim.lsp.config("lua_ls", {
      capabilities = capabilities,
      on_attach = on_attach,
      settings = { -- custom settings for lua
        Lua = {
          -- make the language server recognize "vim" global
          diagnostics = {
            globals = { "vim" },
          },
          workspace = {
            -- make language server aware of runtime files
            library = {
              [vim.fn.expand("$VIMRUNTIME/lua")] = true,
              [vim.fn.stdpath("config") .. "/lua"] = true,
            },
          },
        },
      },
    })
    vim.lsp.enable("lua_ls")

    vim.lsp.config("rust_analyzer", {
      on_attach = on_attach,
      capabilities = capabilities,
      settings = {
        ["rust-analyzer"] = {
          check = {
            command = "clippy"
          }
        },
      },
    })
    vim.lsp.enable("rust_analyzer")

    local vscodeLsCapabilities = vim.lsp.protocol.make_client_capabilities()
    vscodeLsCapabilities.textDocument.completion.completionItem.snippetSupport = true
    vim.lsp.config("cssls", {
      capabilities = vscodeLsCapabilities,
      on_attach = on_attach,
    })
    vim.lsp.enable("cssls")

    vim.lsp.config("jsonls", {
      capabilities = vscodeLsCapabilities,
      on_attach = on_attach,
    })
    vim.lsp.enable("jsonls")
  end,
}
