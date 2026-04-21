local mason_packages = require("config.mason_packages")
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

    -- Base capabilities are shared by every server. Special cases can extend them.
    local capabilities = require("blink.cmp").get_lsp_capabilities()
    local snippet_capabilities = vim.deepcopy(capabilities)
    snippet_capabilities.textDocument = snippet_capabilities.textDocument or {}
    snippet_capabilities.textDocument.completion = snippet_capabilities.textDocument.completion or {}
    snippet_capabilities.textDocument.completion.completionItem =
      snippet_capabilities.textDocument.completion.completionItem or {}
    snippet_capabilities.textDocument.completion.completionItem.snippetSupport = true

    local excluded_servers = {
      jdtls = true, -- Java is configured separately in ftplugin/java.lua
    }

    local custom_server_settings = {
      lua_ls = {
        settings = { -- custom settings for lua
          Lua = {
            -- make language server recognize the "vim" global
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
      },
      rust_analyzer = {
        settings = {
          ["rust-analyzer"] = {
            check = {
              command = "clippy",
            },
          },
        },
      },
      cssls = {
        capabilities = snippet_capabilities,
      },
      jsonls = {
        capabilities = snippet_capabilities,
      },
    }

    local function enable(server, opts)
      vim.lsp.config(server, vim.tbl_deep_extend("force", {
        capabilities = capabilities,
        on_attach = on_attach,
      }, opts or {}))
      vim.lsp.enable(server)
    end

    for _, server in ipairs(mason_packages.lsp_servers) do
      if not excluded_servers[server] and not custom_server_settings[server] then
        enable(server)
      end
    end

    for server, opts in pairs(custom_server_settings) do
      enable(server, opts)
    end
  end,
}
