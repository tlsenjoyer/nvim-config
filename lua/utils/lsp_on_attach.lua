local function tsserver_organize_imports()
  local params = {
    command = "_typescript.organizeImports",
    arguments = { vim.api.nvim_buf_get_name(0) },
    title = "",
  }
  vim.lsp.buf.execute_command(params)
end

return function(client, bufnr)
  local keymap = vim.keymap
  local opts = { noremap = true, silent = true, buffer = bufnr }

  keymap.set("n", "gD", vim.lsp.buf.declaration, opts)                                                       -- go to declaration
  keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, opts)                                      -- see available code actions, in visual mode will apply to selection
  keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)                                                    -- smart rename
  keymap.set("n", "[d", function() vim.diagnostic.jump({ count = -1, float = { source = true } }) end, opts) -- jump to previous diagnostic in buffer
  keymap.set("n", "]d", function() vim.diagnostic.jump({ count = 1, float = { source = true } }) end, opts)  -- jump to next diagnostic in buffer
  keymap.set("n", "<leader>d", function() vim.diagnostic.open_float({ source = true }) end, opts)            -- show diagnostic for what is under cursor
  keymap.set("n", "K", vim.lsp.buf.hover, opts)                                                              -- show documentation for what is under cursor
  keymap.set("n", "<leader>rs", ":LspRestart<CR>", opts)                                                     -- mapping to restart lsp if necessary
  keymap.set("n", "<leader>H", ':execute "help " . expand("<cword>")<CR>', opts)

  if client.name == "pyright" then
    keymap.set("n", "<leader>oi", ":PyrightOrganizeImports<CR>", opts)              -- organize imports
    keymap.set("n", "<leader>db", ":DapToggleBreakpoint<CR>", opts)                 -- toggle breakpoint
    keymap.set("n", "<leader>dr", ":DapContinue<CR>", opts)                         -- continue/invoke debugger
    keymap.set("n", "<leader>dt", ":lua require('dap-python').test_method()", opts) -- run tests
  end

  if client.name == "ts_ls" or client.name == "tsserver" then
    keymap.set("n", "<leader>oi", tsserver_organize_imports, opts) -- organize imports
  end
end
