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
  config = function(_, opts)
    require("telescope").setup(opts)

    -- Telescope 0.1.x's `current_buffer_fuzzy_find` (<leader>fz) highlights the
    -- picker results through the legacy nvim-treesitter API: `parsers.ft_to_lang`
    -- and `configs.is_enabled`. This config runs nvim-treesitter on the `main`
    -- branch, where `parsers` is now a plain data table (no `ft_to_lang`) and the
    -- `configs` module was removed entirely. That mismatch made the picker error
    -- with "attempt to call field 'ft_to_lang' (a nil value)". Provide thin shims
    -- that map both onto the core `vim.treesitter` API so the picker keeps its
    -- highlighting instead of crashing.
    local parsers_ok, parsers = pcall(require, "nvim-treesitter.parsers")
    if parsers_ok and type(parsers) == "table" and type(parsers.ft_to_lang) ~= "function" then
      parsers.ft_to_lang = function(ft)
        return vim.treesitter.language.get_lang(ft) or ft
      end
    end

    if not pcall(require, "nvim-treesitter.configs") then
      package.loaded["nvim-treesitter.configs"] = {
        -- telescope calls is_enabled("highlight", lang, bufnr); report whether a
        -- treesitter highlighter is actually active for the buffer.
        is_enabled = function(_, _, bufnr)
          bufnr = bufnr or vim.api.nvim_get_current_buf()
          return vim.treesitter.highlighter.active[bufnr] ~= nil
        end,
      }
    end
  end,
  dependencies = { "nvim-lua/plenary.nvim" },
  branch = "0.1.x",
}
