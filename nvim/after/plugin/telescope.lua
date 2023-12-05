local builtin = require('telescope.builtin')

local function keymap(mode, key, cmd)
	local opts = { noremap = true, silent = true }
	vim.keymap.set(mode, key, cmd, opts)
end

keymap('n', '<leader>pf', builtin.find_files)
keymap('n', '<C-p>', builtin.git_files)
keymap('n', '<leader>ps', function()
	-- brew install ripgrep for this
	builtin.grep_string({ search = vim.fn.input("Grep > ") })
end)

local function getVisualSelection()
	vim.cmd('noau normal! "vy"')
	local text = vim.fn.getreg('v')
	vim.fn.setreg('v', {})

	text = string.gsub(text, "\n", "")
	if #text > 0 then
		return text
	else
		return ''
	end
end

keymap('n', '<space>tt', ':Telescope current_buffer_fuzzy_find<cr>')
keymap('v', '<space>g', function()
	local text = getVisualSelection()
	builtin.current_buffer_fuzzy_find({ default_text = text })
end)

keymap('n', '<space>G', ':Telescope live_grep<cr>')
keymap('v', '<space>G', function()
	local text = getVisualSelection()
	builtin.live_grep({ default_text = text })
end)
