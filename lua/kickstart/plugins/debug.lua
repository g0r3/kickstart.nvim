-- debug.lua
--
-- Shows how to use the DAP plugin to debug your code.
--
-- Primarily focused on configuring the debugger for Go, but can
-- be extended to other languages as well. That's why it's called
-- kickstart.nvim and not kitchen-sink.nvim ;)

return {
  -- NOTE: Yes, you can install new plugins here!
  'mfussenegger/nvim-dap',
  -- NOTE: And you can specify dependencies as well
  dependencies = {
    -- Creates a beautiful debugger UI
    'rcarriga/nvim-dap-ui',

    -- Required dependency for nvim-dap-ui
    'nvim-neotest/nvim-nio',

    -- Installs the debug adapters for you
    'williamboman/mason.nvim',
    'jay-babu/mason-nvim-dap.nvim',

    -- Add your own debuggers here
    'mfussenegger/nvim-dap-python',
  },
  config = function()
    local dap = require 'dap'
    local dapui = require 'dapui'
    local dappython = require('dap-python').setup '~/.virtualenvs/debugpy/bin/python'

    require('mason-nvim-dap').setup {
      -- Makes a best effort to setup the various debuggers with
      -- reasonable debug configurations
      automatic_setup = true,

      -- You can provide additional configuration to the handlers,
      -- see mason-nvim-dap README for more information
      handlers = {},

      -- You'll need to check that you have the required things installed
      -- online, please don't ask me how to install them :)
      ensure_installed = {
        -- Update this to ensure that you have the debuggers for the langs you want
        'debugpy',
      },
    }

    -- Basic debugging keymaps, feel free to change to your liking!
    vim.keymap.set('n', '<F5>', dap.continue, { desc = 'Debug: Start/Continue' })
    vim.keymap.set('n', '<F1>', dap.step_into, { desc = 'Debug: Step Into' })
    vim.keymap.set('n', '<F2>', dap.step_over, { desc = 'Debug: Step Over' })
    vim.keymap.set('n', '<F3>', dap.step_out, { desc = 'Debug: Step Out' })
    vim.keymap.set('n', '<leader>b', dap.toggle_breakpoint, { desc = 'Debug: Toggle Breakpoint' })
    vim.keymap.set('n', '<leader>B', function()
      dap.set_breakpoint(vim.fn.input 'Breakpoint condition: ')
    end, { desc = 'Debug: Set Breakpoint' })
    -- Dap UI setup
    -- For more information, see |:help nvim-dap-ui|
    dapui.setup {
      -- Set icons to characters that are more likely to work in every terminal.
      --    Feel free to remove or use ones that you like more! :)
      --    Don't feel like these are good choices.
      icons = { expanded = '▾', collapsed = '▸', current_frame = '*' },
      controls = {
        icons = {
          disconnect = '',
          pause = '',
          play = '',
          run_last = '',
          step_back = '',
          step_into = '',
          step_out = '',
          step_over = '',
          terminate = '',
        },
      },
      layouts = {
        {
          elements = {
            {
              id = 'scopes',
              size = 0.25,
            },
            {
              id = 'breakpoints',
              size = 0.25,
            },
            {
              id = 'stacks',
              size = 0.25,
            },
            {
              id = 'watches',
              size = 0.25,
            },
          },
          position = 'left',
          size = 40,
        },
        {
          elements = { {
            id = 'console',
            size = 0.9,
          }, {
            id = 'repl',
            size = 0.1,
          } },
          position = 'right',
          size = 0.5,
        },
      },
    }

    -- Toggle to see last session result. Without this, you can't see session output in case of unhandled exception.
    vim.keymap.set('n', '<F7>', dapui.toggle, { desc = 'Debug: See last session result.' })

    local cdw = vim.fn.getcwd()
    print(cdw .. 'autotest/autotest-core/bin/entrypoint.sh')

    dap.listeners.after.event_initialized['dapui_config'] = dapui.open
    dap.configurations.python = {
      {
        -- The first three options are required by nvim-dap
        type = 'python', -- the type here established the link to the adapter definition: `dap.adapters.python`
        request = 'launch',
        subProcess = false, -- needed for the multiprocess library, since debugpy officially does not support multiple threads
        name = 'Run testcase',
        console = 'integratedTerminal',
        program = cdw .. '/autotest/autotest-core/bin/entrypoint.py',
        args = {
          'docker-host=10.17.96.3',
          'vm-power-off-after-run=False',
          'reporters=log-summary,video-collector',
          'case-retry-on-error=False',
          'case-retry-on-fail=False',
          'revert=after-run',
          'cases=dummy_pass',
          'profile=onprem-run',
        },
        env = {
          BCC_USER = 'SVCENGNGSVNsync@protonmail.com',
          BCC_PASS = '&Rk7ofWV4AJ#',
          VNC_CLIENT = '/mnt/c/Program\\ Files/RealVNC/VNC\\ Viewer/vncviewer.exe {ip}:{port}',
          PYTHONWARNINGS = 'ignore:Unverified HTTPS request',
          REQUESTS_CA_BUNDLE = '/nix/store/wm5gsfan12qbgas2d9385fm42sg2v959-nss-cacert-3.89.1/etc/ssl/certs/ca-bundle.crt',
          LD_LIBRARY_PATH = '/nix/store/bymsnmvi5zkbm84chkl0zsy7wf5vn944-autotest-core-env/lib',
          PATH = '/nix/store/bymsnmvi5zkbm84chkl0zsy7wf5vn944-autotest-core-env/bin',
        },
        pythonPath = function()
          -- debugpy supports launching an application with a different interpreter then the one used to launch debugpy itself.
          -- The code below looks for a `venv` or `.venv` folder in the current directly and uses the python within.
          -- You could adapt this - to for example use the `VIRTUAL_ENV` environment variable.
          local cwd = vim.fn.getcwd()
          if vim.fn.executable '/home/rstaudacher/.local/share/virtualenvs/fix-testruns/bin/python' == 1 then
            return '/home/rstaudacher/.local/share/virtualenvs/fix-testruns/bin/python'
          elseif vim.fn.executable(cwd .. '/.venv/bin/python') == 1 then
            return cwd .. '/.venv/bin/python'
          else
            return '/usr/bin/python'
          end
        end,
      },
    }
  end,
}
