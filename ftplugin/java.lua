local home = os.getenv("HOME")
local workspace_path = home .. "/.local/share/nvim/jdtls-workspace/"
local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ":p:h:t")
local workspace_dir = workspace_path .. project_name
local mason_jdtls_path = home .. "/.local/share/nvim/mason/packages/jdtls"
local config_dir = "config_linux"

if vim.fn.has("macunix") == 1 then
  config_dir = "config_mac"
elseif vim.fn.has("win32") == 1 then
  config_dir = "config_win"
end

local status, jdtls = pcall(require, "jdtls")
if not status then
  return
end

local on_attach = require("utils.lsp_on_attach")
local capabilities = require("blink.cmp").get_lsp_capabilities()
local extendedClientCapabilities = jdtls.extendedClientCapabilities

local config = {
  cmd = {
    "java",
    "-Declipse.application=org.eclipse.jdt.ls.core.id1",
    "-Dosgi.bundles.defaultStartLevel=4",
    "-Declipse.product=org.eclipse.jdt.ls.core.product",
    "-Dlog.protocol=true",
    "-Dlog.level=ALL",
    "-Xmx1g",
    "--add-modules=ALL-SYSTEM",
    "--add-opens",
    "java.base/java.util=ALL-UNNAMED",
    "--add-opens",
    "java.base/java.lang=ALL-UNNAMED",
    "-javaagent:" .. mason_jdtls_path .. "/lombok.jar",
    "-jar",
    vim.fn.glob(mason_jdtls_path .. "/plugins/org.eclipse.equinox.launcher_*.jar"),
    "-configuration",
    mason_jdtls_path .. "/" .. config_dir,
    "-data",
    workspace_dir,
  },
  root_dir = require("jdtls.setup").find_root({ ".git", "mvnw", "gradlew", "pom.xml", "build.gradle" }),
  on_attach = on_attach,
  capabilities = capabilities,
  settings = {
    java = {
      signatureHelp = { enabled = true },
      extendedClientCapabilities = extendedClientCapabilities,
      maven = {
        downloadSources = true,
      },
      referencesCodeLens = {
        enabled = true,
      },
      references = {
        includeDecompiledSources = true,
      },
      inlayHints = {
        parameterNames = {
          enabled = "all", -- literals, all, none
        },
      },
      format = {
        enabled = false,
      },
    },
  },

  init_options = {
    bundles = {},
  },
}
require("jdtls").start_or_attach(config)

local keymap = vim.keymap

keymap.set("n", "<leader>rr", ":term ./gradlew run<CR>")

keymap.set("n", "<leader>oi", "<Cmd>lua require'jdtls'.organize_imports()<CR>", { desc = "Organize Imports" })
keymap.set("n", "<leader>crv", "<Cmd>lua require('jdtls').extract_variable()<CR>", { desc = "Extract Variable" })
keymap.set(
  "v",
  "<leader>crv",
  "<Esc><Cmd>lua require('jdtls').extract_variable(true)<CR>",
  { desc = "Extract Variable" }
)
keymap.set("n", "<leader>crc", "<Cmd>lua require('jdtls').extract_constant()<CR>", { desc = "Extract Constant" })
keymap.set(
  "v",
  "<leader>crc",
  "<Esc><Cmd>lua require('jdtls').extract_constant(true)<CR>",
  { desc = "Extract Constant" }
)
keymap.set("v", "<leader>crm", "<Esc><Cmd>lua require('jdtls').extract_method(true)<CR>", { desc = "Extract Method" })
