local mason_packages = require("config.mason_packages")

return {
  "WhoIsSethDaniel/mason-tool-installer.nvim",
  event = "VeryLazy",
  dependencies = {
    "williamboman/mason.nvim",
  },
  opts = {
    ensure_installed = mason_packages.all(),
    run_on_start = true,
    start_delay = 3000,
    debounce_hours = 12,
  },
}
