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
		opts = {
			ensure_installed = { "lua_ls", "ts_ls" },
			automatic_enable = true,
		},
	},
	{
		"neovim/nvim-lspconfig",
		dependencies = {
			"hrsh7th/cmp-nvim-lsp",
			"williamboman/mason.nvim",
			"williamboman/mason-lspconfig.nvim",
		},
		config = function()
			vim.lsp.config("*", {
				capabilities = require("cmp_nvim_lsp").default_capabilities(),
			})

			vim.lsp.config("lua_ls", {
				settings = {
					Lua = {
						diagnostics = { globals = { "vim" } },
					},
				},
			})
		end,
	},
	{
		"L3MON4D3/LuaSnip",
		version = "v2.*",
		build = "make install_jsregexp",
		dependencies = {
			"rafamadriz/friendly-snippets", -- Optional: collection of pre-made snippets
		},
		config = function()
			local ls = require("luasnip")

			-- Load friendly-snippets if installed
			require("luasnip.loaders.from_vscode").lazy_load()

			-- Go files can also have SQL snippets available
			ls.filetype_extend("go", {"sql"})

			-- Keybindings
			vim.keymap.set({"i", "s"}, "<Tab>", function()
				if ls.expand_or_jumpable() then
					ls.expand_or_jump()
				else
					return "<Tab>"
				end
			end, {silent = true})

			vim.keymap.set({"i", "s"}, "<S-Tab>", function()
				if ls.jumpable(-1) then
					ls.jump(-1)
				end
			end, {silent = true})
		end,
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
		branch = "main",
		lazy = false,
		build = ":TSUpdate",
		config = function()
			require("nvim-treesitter").install({
				"cpp", "git_rebase", "gitcommit", "go", "lua",
				"markdown", "python", "sql", "templ", "typescript", "vimdoc",
			})
			vim.api.nvim_create_autocmd("FileType", {
				callback = function()
					pcall(vim.treesitter.start)
				end,
			})
		end,
	},
	{
		"nvimtools/none-ls.nvim",
		dependencies = { "nvim-lua/plenary.nvim" },
		config = function()
			local null_ls = require("null-ls")
			null_ls.setup({
				sources = {
					null_ls.builtins.diagnostics.sqlfluff,
					null_ls.builtins.formatting.sqlfluff,
				},
			})
		end,
	},
	{
		"nvim-telescope/telescope.nvim",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-telescope/telescope-live-grep-args.nvim",
		},
		keys = {
			{ "<leader>pf", function() require("telescope.builtin").find_files() end },
			{ "<C-p>", function() require("telescope.builtin").git_files() end },
			{ "<leader>ps", function()
				-- brew install ripgrep for this
				require("telescope.builtin").grep_string({ search = vim.fn.input("Grep > ") })
			end },
			{ "<leader>tt", function()
				local text = vim.fn.expand("<cword>")
				require("telescope.builtin").current_buffer_fuzzy_find({ default_text = text })
			end },
			{ "<leader>g", function() require("telescope.builtin").grep_string() end, mode = "n" },
			{ "<leader>g", function()
				local text = getVisualSelection()
				require("telescope.builtin").current_buffer_fuzzy_find({ default_text = text })
			end, mode = "v" },
			{ "<leader>G", function()
				require("telescope-live-grep-args.shortcuts").grep_word_under_cursor({ postfix = " " })
			end, mode = "n" },
			{ "<leader>G", function()
				require("telescope-live-grep-args.shortcuts").grep_visual_selection({ postfix = " " })
			end, mode = "v" },
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
		keys = {
			{ "<leader>a", function() require("harpoon"):list():add() end },
			{ "<leader>h", function()
				local harpoon = require("harpoon")
				harpoon.ui:toggle_quick_menu(harpoon:list(), {
					height_in_lines = 40
				})
			end },
			{ "<C-h>", function() require("harpoon"):list():select(1) end },
			{ "<C-t>", function() require("harpoon"):list():select(2) end },
			{ "<C-n>", function() require("harpoon"):list():select(3) end },
			{ "<C-s>", function() require("harpoon"):list():select(4) end },
			-- Toggle previous & next buffers stored within Harpoon list
			{ "<C-S-P>", function() require("harpoon"):list():prev() end },
			{ "<C-S-N>", function() require("harpoon"):list():next() end },
		},
		config = function()
			require("harpoon"):setup()
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
		ft = "dart",
		dependencies = {
			"nvim-lua/plenary.nvim",
		},
		config = true,
	},
}
