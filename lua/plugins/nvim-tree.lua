return {
	"nvim-tree/nvim-tree.lua",
	lazy = false,
	opts = {
		on_attach = function(bufnr)
			local api = require("nvim-tree.api")
			api.config.mappings.default_on_attach(bufnr)

			vim.keymap.set("n", "s", function()
				if vim.fn.has("wsl") ~= 1 then
					api.node.run.system()
					return
				end

				local node = api.tree.get_node_under_cursor()
				if not node then
					return
				end

				-- Windows applications need a drive path or a WSL UNC path.
				local result = vim.system({ "wslpath", "-w", node.link_to or node.absolute_path }, { text = true }):wait()
				if result.code ~= 0 then
					vim.notify("Cannot convert path for Windows: " .. (result.stderr or ""), vim.log.levels.ERROR)
					return
				end

				local _, err = vim.ui.open(vim.trim(result.stdout), { cmd = { "explorer.exe" } })
				if err then
					vim.notify(err, vim.log.levels.ERROR)
				end
			end, { buffer = bufnr, desc = "Open in default application", noremap = true, silent = true, nowait = true })
		end,
		hijack_cursor = true,
		select_prompts = true,
		update_focused_file = { enable = true },
		view = {
			relativenumber = true,
			cursorline = true,
			width = 45,
		},
		renderer = {
			root_folder_label = ":t",
			highlight_bookmarks = "name",
			group_empty = false,
			indent_markers = {
				enable = true,
				inline_arrows = true,
			},
		},
		diagnostics = {
			enable = true,
		},
		filters = {
			exclude = { -- always show
				".env*",
				"node_modules",
			},
		},
		trash = {
			cmd = "trash",
		},
	},
	keys = {
		{ "<leader>N", ":NvimTreeToggle<CR>" },
	},
}
