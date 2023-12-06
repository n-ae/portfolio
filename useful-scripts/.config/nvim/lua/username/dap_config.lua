print("BEGIN dapui_config")

local dap, dapui = require("dap"), require("dapui")

dapui.setup()
dap.listeners.after.event_initialized["dapui_config"] = function()
  dapui.open()
end

dap.listeners.before.event_initialized["dapui_config"] = function()
  dapui.close()
end

dap.listeners.before.event_terminated["dapui_config"] = function()
  dapui.close()
end

dap.listeners.before.event_exited["dapui_config"] = function()
  dapui.close()
end

vim.keymap.set("n", "<leader>dt", ":DapToggleBreakpoint<CR>")
vim.keymap.set("n", "<leader>dx", ":DapTerminate<CR>")
vim.keymap.set("n", "<leader>do", ":DapStepOver<CR>")

local mason_registry = require("mason-registry")
local codelldb_root = mason_registry.get_package("codelldb"):get_install_path() .. "/extension/"
local codelldb_path = codelldb_root .. "adapter/codelldb"
local liblldb_path = codelldb_root .. "lldb/lib/liblldb.so"
dap.adapters.rust = {
  type = "server",
  port = "${port}",
  host = "127.0.0.1",
  executable = {
    command = codelldb_path,
    args = { "--liblldb", liblldb_path, "--port", "${port}" },
    -- args = { "--port", "${port}" },
  },
}

dap.adapters.codelldb = {
  type = 'executable',
  command = codelldb_path,
  name = 'lldb'
}

dap.configurations.rust = {
    {
        type = 'codelldb',
        request = 'launch',
        program = function()
            return vim.fn.input('Path to executable: ', vim.fn.getcwd()..'/target/debug', 'file')
        end,
        cwd = '${workspaceFolder}',
        terminal = 'integrated',
        sourceLanguages = { 'rust' }
    }
}

print("END dapui_config")
