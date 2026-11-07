return {
	"nvim-treesitter/nvim-treesitter",
	branch = "main",
	event = { "BufReadPre", "BufNewFile" },
	build = ":TSUpdate",
	dependencies = {
		"windwp/nvim-ts-autotag",
	},
	init = function()
		-- Enable native Neovim treesitter highlighting and indentation
		vim.api.nvim_create_autocmd("FileType", {
			callback = function()
				pcall(vim.treesitter.start)
				vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
			end,
		})

		-- Smart parser installation logic
		local ensureInstalled = {
			"bash",
			"css",
			"dockerfile",
			"go",
			"gomod",
			"gosum",
			"gowork",
			"html",
			"javascript",
			"json",
			"lua",
			"php",
			"python",
			"tsx",
			"typescript",
			"yaml",
			"vim",
			"gitignore",
		}

		local alreadyInstalled = require("nvim-treesitter.config").get_installed()

		local parsersToInstall = vim.iter(ensureInstalled)
			:filter(function(parser)
				return not vim.tbl_contains(alreadyInstalled, parser)
			end)
			:totable()

		-- Only call the install API if there are missing parsers
		if #parsersToInstall > 0 then
			require("nvim-treesitter").install(parsersToInstall)
		end
	end,
	config = function()
		-- Setup nvim-ts-autotag separately, as it no longer hooks into treesitter
		require("nvim-ts-autotag").setup({
			opts = {
				enable_close = true,
				enable_rename = true,
				enable_close_on_slash = false,
			},
		})
	end,
}
