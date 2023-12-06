print("BEGIN username/init.lua")
vim.wo.number = true
vim.opt.tabstop = 2
vim.opt.softtabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
require("username.remap")
require("username.colorscheme")
require("username.undotree")
require("username.fugitive")
require("username.lsp-zero")
require("username.dap_config")
require("username.rust_config")
