return {
  "numToStr/Comment.nvim",
  dependencies = "JoosepAlviste/nvim-ts-context-commentstring",
  keys = {
    {
      "<leader>/",
      "<leader>/",
    },
    {
      "<leader>/",
      "<leader>/",
      mode = "v",
    },
    {
      "<leader>b/",
      "<leader>b/",
      mode = "v",
    },
  },
  opts = function()
    local ts_context_commentstring = require("ts_context_commentstring.integrations.comment_nvim").create_pre_hook()
    local ft = require("Comment.ft")

    return {
      toggler = {
        line = "<leader>/",
        block = "<nop>",
      },
      opleader = {
        line = "<leader>/",
        block = "<leader>b/",
      },
      mappings = {
        extra = false, -- don't create unnecessary mappings
      },
      pre_hook = function(ctx)
        local ok, commentstring = pcall(ts_context_commentstring, ctx)
        if ok and commentstring then
          return commentstring
        end

        return ft.get(vim.bo.filetype, ctx.ctype) or vim.bo.commentstring
      end,
    }
  end,
}
