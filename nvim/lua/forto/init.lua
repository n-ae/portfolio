print 'forto/init.lua'

local cmd = '!yarn eslint % --fix'
-- vim.api.nvim_create_autocmd({ 'BufWritePre' }, {
vim.api.nvim_create_autocmd({ 'BufWritePost' }, {
  -- buffer = 0, -- if 0 doesn't work do vim.api.nvim_get_current_buf()
  pattern = '*.ts',
  -- callback = function()
  --   print(cmd)
  -- end,
  command = cmd,
})
