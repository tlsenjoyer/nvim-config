return {
  "nvim-telescope/telescope.nvim",
  cmd = "Telescope",
  opts = function()
    local actions = require("telescope.actions")

    return {
      defaults = {
        sorting_strategy = "ascending",
        layout_config = {
          prompt_position = "top",
        },
        file_ignore_patterns = {
          ".git", ".next", "node_modules", "target"
        },
        prompt_prefix = "",
        mappings = {
          n = {
            ["q"] = actions.close,
            ["<C-d>"] = actions.delete_buffer,
          },
        },
      },
      pickers = {
        find_files = {
          find_command = {
            "rg",          -- ripgrep
            "--no-ignore", -- disable exclusion of files/directories based on .gitignore
            "--files",     -- dunno
            "--hidden"     -- search hidden files/directories (ones that begin with a dot)
          },
        },
      },
    }
  end,
  dependencies = { "nvim-lua/plenary.nvim" },
  branch = "0.1.x",
}
