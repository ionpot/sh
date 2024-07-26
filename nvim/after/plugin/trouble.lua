local trouble = require("trouble.sources.telescope")
local telescope = require("telescope")

telescope.setup {
  defaults = {
    mappings = {
      i = { ["<c-t>"] = trouble.open },
      n = { ["<c-t>"] = trouble.open },
    },
  },
}

vim.keymap.set("n", "<leader>xx", "<cmd>Trouble<cr>",
  {silent = true, noremap = true}
)
vim.keymap.set("n", "<leader>xd", "<cmd>Trouble diagnostics<cr>",
  {silent = true, noremap = true}
)
vim.keymap.set("n", "<leader>xl", "<cmd>Trouble loclist<cr>",
  {silent = true, noremap = true}
)
vim.keymap.set("n", "<leader>xq", "<cmd>Trouble quickfix<cr>",
  {silent = true, noremap = true}
)
vim.keymap.set("n", "gR", "<cmd>Trouble lsp_references<cr>",
  {silent = true, noremap = true}
)

local tr = require('trouble')

vim.keymap.set("n", "<leader>xn", function ()
	tr.next({skip_groups = true, jump = true})
end,
  {silent = true, noremap = true}
)
vim.keymap.set("n", "<leader>xp", function ()
	tr.previous({skip_groups = true, jump = true})
end,
  {silent = true, noremap = true}
)
