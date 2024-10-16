require 'username.keymaps'
require 'username.lsp'

if username then
  return
end -- avoid loading twice the same module

local username = {}

username.plugins = {
  require 'username.DAP',
  -- 'mfussenegger/nvim-dap',
  { 'kosayoda/nvim-lightbulb' },
  { 'rcarriga/nvim-dap-ui', dependencies = { 'mfussenegger/nvim-dap', 'nvim-neotest/nvim-nio' } },
  { 'David-Kunz/jester' },
  -- { 'NTBBloodbath/rest.nvim', dependencies = { 'nvim-lua/plenary.nvim' } },
  -- {
  --   'vhyrro/luarocks.nvim',
  --   priority = 1000,
  --   config = true,
  --   opts = {
  --     rocks = { 'lua-curl', 'nvim-nio', 'mimetypes', 'xml2lua' },
  --   },
  -- },
  -- {
  --   'rest-nvim/rest.nvim',
  --   ft = 'http',
  --   dependencies = { 'luarocks.nvim' },
  --   config = function()
  --     require('rest-nvim').setup()
  --   end,
  -- },
  -- { 'diepm/vim-rest-console' },
  -- { 'BlackLight/nvim-http' },
  -- {
  --   'vhyrro/luarocks.nvim',
  --   priority = 1000,
  --   config = true,
  --   opts = {
  --     rocks = { 'lua-curl', 'nvim-nio', 'mimetypes', 'xml2lua' },
  --   },
  -- },
  -- {
  --   'rest-nvim/rest.nvim',
  --   ft = 'http',
  --   dependencies = { 'luarocks.nvim' },
  --   config = function()
  --     require('rest-nvim').setup()
  --   end,
  -- },
  -- {
  --   'nvim-neotest/neotest',
  --   dependencies = {
  --     'nvim-neotest/neotest-jest',
  --   },
  --   config = function()
  --     require('neotest').setup {
  --       adapters = {
  --         require 'neotest-jest' {
  --           -- jestCommand = 'npm test --',
  --           -- jestConfigFile = 'custom.jest.config.ts',
  --           jestCommand = 'yarn test:integration',
  --           -- jestConfigFile = 'custom.jest.config.ts',
  --           env = { CI = true },
  --           cwd = function(path)
  --             return vim.fn.getcwd()
  --           end,
  --         },
  --       },
  --     }
  --   end,
  -- },
  -- {
  --   'nvim-treesitter/nvim-treesitter',
  --   opts = {
  --     ensure_installed = {
  --       'hcl',
  --       'terraform',
  --     },
  --   },
  -- },
}

username.servers = {
  terraformls = {
    -- filetypes = { 'terraform' },
  },
  clangd = {},
  marksman = {},
  tsserver = {},
  jsonls = {},
  yamlls = {
    settings = {
      yaml = {
        validate = true,
        schemas = {
          kubernetes = { 'k8s**.yaml', 'kube*/*.yaml' },
        },
      },
    },
  },
  omnisharp = {},
}

return username
