local jdtls = require("jdtls")
local bufnr = vim.api.nvim_get_current_buf()
local filename = vim.api.nvim_buf_get_name(bufnr)
if filename == "" or vim.bo[bufnr].buftype ~= "" then
  return
end

-- Find the build from the file, even when Neovim was started elsewhere.
local root_dir = vim.fs.root(bufnr, { "gradlew", "mvnw", "settings.gradle", "settings.gradle.kts" })
  or vim.fs.root(bufnr, { "pom.xml", "build.gradle", "build.gradle.kts", ".project" })
  or vim.fs.root(bufnr, { ".git" })
  or vim.fs.dirname(filename)
root_dir = vim.uv.fs_realpath(root_dir) or root_dir

-- Projects with the same name must not share Eclipse metadata.
local project_id = vim.fs.basename(root_dir) .. "-" .. vim.fn.sha256(root_dir):sub(1, 16)
local workspace_dir = vim.fn.stdpath("cache") .. "/jdtls/" .. project_id
local mason_path = require("mason.settings").current.install_root_dir
local launcher = mason_path .. "/bin/jdtls"
if vim.fn.has("win32") == 1 then
  launcher = launcher .. ".cmd"
end

local function map(mode, lhs, rhs, desc)
  vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, silent = true, desc = desc })
end

-- Works immediately, including while the language server is still indexing.
map("i", "<C-g>p", function()
  vim.snippet.expand("System.out.println(${1});$0")
end, "Java: System.out.println")

if vim.fn.executable(launcher) == 0 then
  vim.notify("Java: install jdtls with :MasonInstall jdtls, then reopen this buffer.", vim.log.levels.WARN)
  return
end

-- The official launcher handles the platform, Java version and launcher JAR.
local cmd = { launcher, "-data", workspace_dir, "-configuration", workspace_dir .. "/config" }
local lombok = mason_path .. "/packages/jdtls/lombok.jar"
if vim.fn.filereadable(lombok) == 1 then
  table.insert(cmd, "--jvm-arg=-javaagent:" .. lombok)
end

jdtls.start_or_attach({
  cmd = cmd,
  root_dir = root_dir,
  capabilities = require("blink.cmp").get_lsp_capabilities(),
  on_attach = function(client, attached_bufnr)
    require("utils.lsp_on_attach")(client, attached_bufnr)
    local function lsp_map(lhs, rhs, desc)
      vim.keymap.set("n", lhs, rhs, { buffer = attached_bufnr, silent = true, desc = desc })
    end
    lsp_map("gd", "<Cmd>Telescope lsp_definitions<CR>", "Go to definition")
    lsp_map("gr", "<Cmd>Telescope lsp_references<CR>", "Find references")
    lsp_map("gi", "<Cmd>Telescope lsp_implementations<CR>", "Go to implementation")
    lsp_map("gt", "<Cmd>Telescope lsp_type_definitions<CR>", "Go to type definition")
    lsp_map("<leader>fs", "<Cmd>Telescope lsp_document_symbols<CR>", "Find symbols in file")
    lsp_map("<leader>fS", "<Cmd>Telescope lsp_dynamic_workspace_symbols<CR>", "Find symbols in project")
    lsp_map("<leader>oi", jdtls.organize_imports, "Organize imports")
    lsp_map("<leader>crv", jdtls.extract_variable, "Extract variable")
    lsp_map("<leader>crc", jdtls.extract_constant, "Extract constant")
    for lhs, method in pairs({ crv = "extract_variable", crc = "extract_constant", crm = "extract_method" }) do
      vim.keymap.set(
        "x",
        "<leader>" .. lhs,
        "<Esc><Cmd>lua require('jdtls')." .. method .. "(true)<CR>",
        { buffer = attached_bufnr, silent = true, desc = "Java: " .. method:gsub("_", " ") }
      )
    end
    if vim.fn.filereadable(root_dir .. "/gradlew") == 1 then
      lsp_map("<leader>rr", function()
        vim.cmd("botright new")
        vim.fn.jobstart({ root_dir .. "/gradlew", "run" }, { cwd = root_dir, term = true })
        vim.cmd("startinsert")
      end, "Gradle run (requires application plugin)")
    end
  end,
  settings = {
    java = {
      signatureHelp = { enabled = true },
      maven = { downloadSources = true },
      referencesCodeLens = { enabled = true },
      references = { includeDecompiledSources = true },
      inlayHints = { parameterNames = { enabled = "all" } },
      format = { enabled = false }, -- Conform uses google-java-format.
    },
  },
  init_options = {
    extendedClientCapabilities = jdtls.extendedClientCapabilities,
    bundles = {},
  },
})
