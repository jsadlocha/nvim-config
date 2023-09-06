local dap, dapui = require('dap'),require('dapui')
vim.dapui = dapui
vim.dap = dap
dapui.setup()

dap.adapters.python = function(cb, config)
  if config.request == 'attach' then
    ---@diagnostic disable-next-line: undefined-field
    local port = (config.connect or config).port
    ---@diagnostic disable-next-line: undefined-field
    local host = (config.connect or config).host or '127.0.0.1'
    cb({
      type = 'server',
      port = assert(port, '`connect.port` is required for a python `attach` configuration'),
      host = host,
      options = {
        source_filetype = 'python',
      },
    })
  else
    cb({
      type = 'executable',
      --command = 'path/to/virtualenvs/debugpy/bin/python',
      command = '/usr/bin/python',
      args = { '-m', 'debugpy.adapter' },
      options = {
        source_filetype = 'python',
      },
    })
  end
end

dap.configurations.python = {
  {
    -- The first three options are required by nvim-dap
    type = 'python'; -- the type here established the link to the adapter definition: `dap.adapters.python`
    request = 'launch';
    name = "Launch file";

    -- Options below are for debugpy, see https://github.com/microsoft/debugpy/wiki/Debug-configuration-settings for supported options

    program = "${file}"; -- This configuration will launch the current file if used.
    pythonPath = function()
      -- debugpy supports launching an application with a different interpreter then the one used to launch debugpy itself.
      -- The code below looks for a `venv` or `.venv` folder in the current directly and uses the python within.
      -- You could adapt this - to for example use the `VIRTUAL_ENV` environment variable.
      local cwd = vim.fn.getcwd()
      if vim.fn.executable(cwd .. '/venv/bin/python') == 1 then
        return cwd .. '/venv/bin/python'
      elseif vim.fn.executable(cwd .. '/.venv/bin/python') == 1 then
        return cwd .. '/.venv/bin/python'
      else
        return '/usr/bin/python'
      end
    end;
  },
}

dap.adapters.lldb = {
  type = 'executable',
  command = '/usr/bin/lldb-vscode-10',
  name = 'lldb'
}

dap.configurations.cpp = {
  {
    name = "Launch",
    type = "lldb",
    request = "launch",
    program = function()
        return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
    end,
    cwd = '${workspaceFolder}',
    stopOnEntry = false,
    args = {},
    runInTerminal = true,
  },
}

dap.configurations.c = dap.configurations.cpp
dap.configurations.rust = dap.configurations.cpp

dap.listeners.after.event_initialized["dapui_config"]=function()
  dapui.open()
end
dap.listeners.before.event_terminated["dapui_config"]=function()
  -- dapui.close()
end
dap.listeners.before.event_exited["dapui_config"]=function()
  -- dapui.close()
end

vim.fn.sign_define('DapBreakpoint',{ text ='🟥', texthl ='', linehl ='', numhl =''})
vim.fn.sign_define('DapBreakpointCondition',{ text ='🟥', texthl ='', linehl ='', numhl =''})
vim.fn.sign_define('DapStopped',{ text ='▶️', texthl ='', linehl ='', numhl =''})

-- nvim-dapui
vim.keymap.set('n', '<F5>', require 'dap'.continue, { desc = "Continue execution (dap)" })
vim.keymap.set('n', '<F6>', require 'dap'.step_over, { desc = "Step Over (dap)" })
vim.keymap.set('n', '<F7>', require 'dap'.step_into, { desc = "Step Into (dap)" })
vim.keymap.set('n', '<F8>', require 'dap'.step_out, { desc = "Step Out (dap)" })
vim.keymap.set('n', '<F10>', require 'dapui'.eval, { desc = "Eval line (dap)" })
vim.keymap.set('n', '<leader>b', require 'dap'.toggle_breakpoint, { desc = "Toggle Breakpoint (dap)" })
vim.keymap.set('n', '<leader>r', require 'dap'.restart, { desc = "Restart debugging (dap)"})
vim.keymap.set('n', '<leader>R', function()
  vim.dapui.close()
  vim.dap.close()
end, { desc = "Close debugger (dap)" })
vim.keymap.set('n', '<leader>B', function()
  require 'dap'.set_breakpoint(vim.fn.input('Breakpoint condition: ')) end, { desc = "Conditional Breakpoint (dap)" })


-- vim.api.nvim_create_autocmd(
--   {"InsertLeave"}, {
--   pattern = {"*"},
--   callback = function(ev)
--     vim.notify_once("Insert Leave")
--   end
-- })

-- vim.api.nvim_create_autocmd(
--   {"ColorScheme"}, {
--   pattern = {"*"},
--   callback = function(ev)
--     vim.notify_once("Welcome Master!")
--   end
-- })

