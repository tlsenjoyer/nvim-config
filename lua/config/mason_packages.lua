local M = {}

-- Curated "popular language" baseline so Mason, LSP, and formatting stay in sync.
M.lsp_servers = {
  "ansiblels",
  "bashls",
  "clangd",
  "cssls",
  "css_variables",
  "cssmodules_ls",
  "docker_compose_language_service",
  "dockerls",
  "emmet_ls",
  "gopls",
  "graphql",
  "html",
  "intelephense",
  "jdtls",
  "jsonls",
  "lua_ls",
  "marksman",
  "markdown_oxide",
  "prismals",
  "pyright",
  "rust_analyzer",
  "svelte",
  "tailwindcss",
  "taplo",
  "ts_ls",
  "vimls",
  "yamlls",
}

M.tools = {
  "black",
  "clang-format",
  "codespell",
  "gofumpt",
  "goimports",
  "google-java-format",
  "isort",
  "prettierd",
  "rustfmt",
  "shfmt",
  "stylua",
}

function M.all()
  local packages = vim.deepcopy(M.lsp_servers)
  vim.list_extend(packages, M.tools)
  return packages
end

return M
