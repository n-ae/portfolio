-- vim.keymap.set('n', 'ga', vim.lsp.buf.code_action, { desc = 'Show diagnostic [A]ctions' })
vim.api.nvim_set_keymap('n', '<leader>rr', '<cmd>lua require("rest-nvim").run()<CR>', { noremap = true, silent = true })
