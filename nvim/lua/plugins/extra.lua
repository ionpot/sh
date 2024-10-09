local function keymap(mode, key, cmd)
	local opts = { remap = false }
	vim.keymap.set(mode, key, cmd, opts)
end

local function getVisualSelection()
	vim.cmd('noau normal! "vy"')
	local text = vim.fn.getreg("v")
	vim.fn.setreg("v", {})

	text = string.gsub(text, "\n", "")
	if #text > 0 then
		return text
	else
		return ""
	end
end

return {
	{ "williamboman/mason.nvim", opts = {} },
	{
		"williamboman/mason-lspconfig.nvim",
		dependencies = {
			"williamboman/mason.nvim",
		},
		opts = {},
	},
	{
		"neovim/nvim-lspconfig",
		dependencies = {
			"hrsh7th/cmp-nvim-lsp",
			"williamboman/mason.nvim",
			"williamboman/mason-lspconfig.nvim",
		},
		config = function()
			local cap = require("cmp_nvim_lsp").default_capabilities()
			require("mason-lspconfig").setup_handlers {
				function (server_name)
					require("lspconfig")[server_name].setup {
						capabilities = cap,
					}
				end,
			}
		end
	},
	{
		"folke/lazydev.nvim",
		ft = "lua",
		opts = {
			library = {
				-- See the configuration section for more details
				-- Load luvit types when the `vim.uv` word is found
				{ path = "luvit-meta/library", words = { "vim%.uv" } },
			},
		},
	},
	{ "Bilal2453/luvit-meta", lazy = true },
	{
		"nvim-tree/nvim-tree.lua",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		opts = {
			view = { width = 40 },
		},
		keys = {
			{ "<leader>nt", vim.cmd.NvimTreeFindFile },
			{ "<leader>nn", vim.cmd.NvimTreeOpen },
		},
	},
	{
		"nvim-treesitter/nvim-treesitter",
		build = ":TSUpdate",
		config = function ()
			local c = require("nvim-treesitter.configs")
			c.setup({
				highlight = {
					enable = true,
					additional_vim_regex_highlighting = true,
				},
			})
		end
	},
	{
		"nvim-telescope/telescope.nvim",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-telescope/telescope-live-grep-args.nvim",
		},
		config = function()
			require("telescope").load_extension("live_grep_args")
			local builtin = require('telescope.builtin')
			keymap('n', '<leader>pf', builtin.find_files)
			keymap('n', '<C-p>', builtin.git_files)
			keymap('n', '<leader>ps', function()
				-- brew install ripgrep for this
				builtin.grep_string({ search = vim.fn.input("Grep > ") })
			end)
			keymap('n', '<space>tt', ':Telescope current_buffer_fuzzy_find<cr>')
			keymap('v', '<space>g', function()
				local text = getVisualSelection()
				builtin.current_buffer_fuzzy_find({ default_text = text })
			end)
			keymap('n', '<space>G', ':Telescope live_grep_args<cr>')
			keymap('v', '<space>G', function()
				local text = getVisualSelection()
				builtin.live_grep({ default_text = text })
			end)
		end
	},
	{
		"folke/trouble.nvim",
		dependencies = {
			"nvim-tree/nvim-web-devicons",
			"nvim-telescope/telescope.nvim",
		},
		opts = {},
		cmd = "Trouble",
		keys = {
			{
				"<leader>xX",
				"<cmd>Trouble diagnostics toggle<cr>",
				desc = "Diagnostics (Trouble)",
			},
			{
				"<leader>xx",
				"<cmd>Trouble diagnostics toggle filter.buf=0<cr>",
				desc = "Buffer Diagnostics (Trouble)",
			},
			{
				"<leader>cs",
				"<cmd>Trouble symbols toggle focus=false<cr>",
				desc = "Symbols (Trouble)",
			},
			{
				"<leader>cl",
				"<cmd>Trouble lsp toggle focus=false win.position=right<cr>",
				desc = "LSP Definitions / references / ... (Trouble)",
			},
			{
				"<leader>xl",
				"<cmd>Trouble loclist toggle<cr>",
				desc = "Location List (Trouble)",
			},
			{
				"<leader>xq",
				"<cmd>Trouble qflist toggle<cr>",
				desc = "Quickfix List (Trouble)",
			},
		},
	},
	{
		"theprimeagen/harpoon",
		config = function()
			local mark = require("harpoon.mark")
			local ui = require("harpoon.ui")

			keymap("n", "<leader>a", mark.add_file)
			keymap("n", "<leader>h", ui.toggle_quick_menu)

			keymap("n", "<C-h>", function() ui.nav_file(1) end)
			keymap("n", "<C-t>", function() ui.nav_file(2) end)
			keymap("n", "<C-n>", function() ui.nav_file(3) end)
			keymap("n", "<C-s>", function() ui.nav_file(4) end)
		end,
	},
	{
		"mbbill/undotree",
		keys = {
			{ "<leader>u", "<cmd>UndotreeToggle<cr>" },
		},
	},
	{
		"tpope/vim-fugitive",
		keys = {
			{ "<leader>gs", vim.cmd.Git },
		},
	},
	{
		"akinsho/flutter-tools.nvim",
		lazy = false,
		dependencies = {
			"nvim-lua/plenary.nvim",
			"stevearc/dressing.nvim", -- optional for vim.ui.select
		},
		config = true,
	},
}
