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
			local telescope = require("telescope")
			local lga_actions = require("telescope-live-grep-args.actions")
			telescope.setup({
				extensions = {
					live_grep_args = {
						auto_quoting = true,
						mappings = {
							i = { ["<C-k>"] = lga_actions.quote_prompt() },
						},
					},
				},
			})
			telescope.load_extension("live_grep_args")

			local builtin = require("telescope.builtin")
			keymap("n", "<leader>pf", builtin.find_files)
			keymap("n", "<C-p>", builtin.git_files)
			keymap("n", "<leader>ps", function()
				-- brew install ripgrep for this
				builtin.grep_string({ search = vim.fn.input("Grep > ") })
			end)
			--keymap("n", "<leader>tt", ":Telescope current_buffer_fuzzy_find<cr>")
			keymap("n", "<leader>tt", function()
				local text = vim.fn.expand("<cword>")
				builtin.current_buffer_fuzzy_find({ default_text = text })
			end)
			keymap("v", "<leader>g", function()
				local text = getVisualSelection()
				builtin.current_buffer_fuzzy_find({ default_text = text })
			end)

			local lga_fn = require("telescope-live-grep-args.shortcuts")
			--keymap("n", "<leader>G", ":Telescope live_grep_args<cr>")
			keymap("n", "<leader>G", function ()
				lga_fn.grep_word_under_cursor({ postfix = " " })
			end)
			keymap("v", "<leader>G", function ()
				lga_fn.grep_visual_selection({ postfix = " " })
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
		"ThePrimeagen/harpoon",
		branch = "harpoon2",
		dependencies = { "nvim-lua/plenary.nvim" },
		config = function()
			local harpoon = require("harpoon")

			-- REQUIRED
			harpoon:setup()
			-- REQUIRED

			keymap("n", "<leader>a", function() harpoon:list():add() end)
			keymap("n", "<leader>h", function()
				harpoon.ui:toggle_quick_menu(harpoon:list(), {
					height_in_lines = 40
				})
			end)

			keymap("n", "<C-h>", function() harpoon:list():select(1) end)
			keymap("n", "<C-t>", function() harpoon:list():select(2) end)
			keymap("n", "<C-n>", function() harpoon:list():select(3) end)
			keymap("n", "<C-s>", function() harpoon:list():select(4) end)

			-- Toggle previous & next buffers stored within Harpoon list
			keymap("n", "<C-S-P>", function() harpoon:list():prev() end)
			keymap("n", "<C-S-N>", function() harpoon:list():next() end)
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
