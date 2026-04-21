local mason_packages = require("config.mason_packages")

return {
  "mason-org/mason-lspconfig.nvim",
  opts = {
    automatic_enable = false, -- this this this this shit fixes shit fucking finally
    -- rust_analyzer was attaching twice without this and only worked for the buffer
    -- that was open first
    automatic_installation = true,
    ensure_installed = mason_packages.lsp_servers,
  },
  event = "BufReadPre",
  dependencies = "williamboman/mason.nvim",
}
