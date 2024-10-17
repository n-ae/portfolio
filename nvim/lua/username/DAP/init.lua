-- https://theosteiner.de/debugging-javascript-frameworks-in-neovim#setting-up-our-debug-adapter-nvim-dap-vscode-js
print 'DAP'

return {
  'mfussenegger/nvim-dap',
  dependencies = {
    'rcarriga/nvim-dap-ui',
    'mxsdev/nvim-dap-vscode-js',
    'theHamsta/nvim-dap-virtual-text',
    'Samsung/netcoredbg',
    -- build debugger from source
    {
      'microsoft/vscode-js-debug',
      version = '1.x',
      build = 'npm i && npm run compile vsDebugServerBundle && mv dist out',
    },
  },
  keys = {
    -- normal mode is default
    {
      '<leader>d',
      function()
        require('dap').toggle_breakpoint()
      end,
    },
    {
      '<leader>c',
      function()
        require('dap').continue()
      end,
    },
    {
      "<C-'>",
      function()
        require('dap').step_over()
      end,
    },
    {
      '<C-;>',
      function()
        require('dap').step_into()
      end,
    },
    {
      '<C-:>',
      function()
        require('dap').step_out()
      end,
    },
  },
  config = function()
    require('dap-vscode-js').setup {
      debugger_path = vim.fn.stdpath 'data' .. '/lazy/vscode-js-debug',
      adapters = {
        'pwa-node',
        'pwa-chrome',
        'pwa-msedge',
        'node-terminal',
        'pwa-extensionHost',
      },
    }

    local dap = require 'dap'

    for _, language in ipairs {
      'typescript',
      'javascript',
      'svelte',
    } do
      dap.configurations[language] = {
        -- attach to a node process that has been started with
        -- `--inspect` for longrunning tasks or `--inspect-brk` for short tasks
        -- npm script -> `node --inspect-brk ./node_modules/.bin/vite dev`
        {
          -- use nvim-dap-vscode-js's pwa-node debug adapter
          type = 'pwa-node',
          -- attach to an already running node process with --inspect flag
          -- default port: 9222
          request = 'attach',
          -- allows us to pick the process using a picker
          processId = require('dap.utils').pick_process,
          -- name of the debug action you have to select for this config
          name = 'Attach debugger to existing `node --inspect` process',
          -- for compiled languages like TypeScript or Svelte.js
          sourceMaps = true,
          -- resolve source maps in nested locations while ignoring node_modules
          resolveSourceMapLocations = {
            '${workspaceFolder}/**',
            '!**/node_modules/**',
          },
          -- path to src in vite based projects (and most other projects as well)
          cwd = '${workspaceFolder}/src',
          -- we don't want to debug code inside node_modules, so skip it!
          skipFiles = { '${workspaceFolder}/node_modules/**/*.js' },
        },
        {
          type = 'pwa-chrome',
          name = 'Launch Chrome to debug client',
          request = 'launch',
          url = 'http://localhost:5173',
          sourceMaps = true,
          protocol = 'inspector',
          port = 9222,
          -- port = 9229,
          webRoot = '${workspaceFolder}/src',
          -- skip files from vite's hmr
          skipFiles = { '**/node_modules/**/*', '**/@vite/*', '**/src/client/*', '**/src/*' },
        },
        -- {
        --   type = 'pwa-node',
        --   request = 'launch',
        --   name = 'Debug Jest Tests',
        --   -- trace = true, -- include debugger info
        --   runtimeExecutable = 'node',
        --   runtimeArgs = {
        --     './node_modules/jest/bin/jest.js',
        --     '--runInBand',
        --   },
        --   rootPath = '${workspaceFolder}',
        --   cwd = '${workspaceFolder}',
        --   console = 'integratedTerminal',
        --   internalConsoleOptions = 'neverOpen',
        -- },
        -- only if language is javascript, offer this debug action
        -- language == 'javascript'
        -- and
        {
          -- use nvim-dap-vscode-js's pwa-node debug adapter
          type = 'pwa-node',
          -- launch a new process to attach the debugger to
          request = 'launch',
          -- name of the debug action you have to select for this config
          name = 'Launch file in new node process',
          -- launch current file
          program = '${file}',
          cwd = '${workspaceFolder}',
        } or nil,
      }
    end

    -- C#
    dap.adapters.coreclr = {
      type = 'executable',
      -- command = vim.fn.stdpath 'data' .. '/usr/local/netcoredbg',
      command = '/usr/local/netcoredbg',
      args = { '--interpreter=vscode' },
    }
    dap.configurations.cs = {
      {
        type = 'coreclr',
        name = 'launch - netcoredbg',
        request = 'launch',
        program = function() -- Ask the user what executable wants to debug
          -- return vim.fn.input('Path to dll: ', vim.fn.getcwd() .. '/bin/Program.exe', 'file')
          return vim.fn.input('Path to dll: ', vim.fn.getcwd() .. '/bin/Program.dll', 'file')
        end,
      },
    }

    require('dapui').setup()
    local dapui = require 'dapui'
    dap.listeners.after.event_initialized['dapui_config'] = function()
      dapui.open { reset = true }
    end
    dap.listeners.before.event_terminated['dapui_config'] = dapui.close
    -- dap.listeners.before.event_exited['dapui_config'] = dapui.close
  end,
}
