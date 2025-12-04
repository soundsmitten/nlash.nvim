local function setupListeners()
  local dap = require 'dap'
  local areSet = false

  dap.listeners.after['event_initialized']['me'] = function()
    if not areSet then
      areSet = true
      vim.keymap.set('n', '<leader>dc', dap.continue, { desc = 'Continue', noremap = true })
      vim.keymap.set('n', '<leader>dC', dap.run_to_cursor, { desc = 'Run To Cursor' })
      vim.keymap.set('n', '<leader>ds', dap.step_over, { desc = 'Step Over' })
      vim.keymap.set('n', '<leader>di', dap.step_into, { desc = 'Step Into' })
      vim.keymap.set('n', '<leader>do', dap.step_out, { desc = 'Step Out' })
      vim.keymap.set({ 'n', 'v' }, '<Leader>dh', require('dap.ui.widgets').hover, { desc = 'Hover' })
      vim.keymap.set({ 'n', 'v' }, '<Leader>de', require('dapui').eval, { desc = 'Eval' })
    end
  end

  dap.listeners.after['event_terminated']['me'] = function()
    if areSet then
      areSet = false
      vim.keymap.del('n', '<leader>dc')
      vim.keymap.del('n', '<leader>dC')
      vim.keymap.del('n', '<leader>ds')
      vim.keymap.del('n', '<leader>di')
      vim.keymap.del('n', '<leader>do')
      vim.keymap.del({ 'n', 'v' }, '<Leader>dh')
      vim.keymap.del({ 'n', 'v' }, '<Leader>de')
    end
  end
end

local function getDependencies()
  local deps = {
    -- Creates a beautiful debugger UI
    'rcarriga/nvim-dap-ui',

    -- Required dependency for nvim-dap-ui
    'nvim-neotest/nvim-nio',

    -- Installs the debug adapters for you
    'williamboman/mason.nvim',
  }

  if vim.loop.os_uname().sysname == 'Darwin' then
    table.insert(deps, 'wojciech-kulik/xcodebuild.nvim')
  end

  return deps
end

return {
  -- NOTE: Yes, you can install new plugins here!
  'mfussenegger/nvim-dap',
  -- NOTE: And you can specify dependencies as well
  dependencies = getDependencies(),
  lazy = true,
  config = function()
    if vim.loop.os_uname().sysname == 'Darwin' then
      local xcodebuild = require 'xcodebuild.integrations.dap'

      -- TODO: change it to your local codelldb path
      -- local codelldbPath = os.getenv 'HOME' .. '/.local/bin/codelldb-darwin-arm64/extension/adapter/codelldb'

      xcodebuild.setup()
      setupListeners()
    end
    local dap = require 'dap'
    local dapui = require 'dapui'
    --
    -- require('mason-nvim-dap').setup {
    --   automatic_installation = true,
    --
    --   -- Makes a best effort to setup the various debuggers with
    --   -- reasonable debug configurations
    --   automatic_setup = true,
    --
    --   -- You can provide additional configuration to the handlers,
    --   -- see mason-nvim-dap README for more information
    --   handlers = {},
    --
    --   -- You'll need to check that you have the required things installed
    --   -- online, please don't ask me how to install them :)
    --   ensure_installed = {
    --     -- Update this to ensure that you have the debuggers for the langs you want
    --   },
    -- }

    -- Dap UI setup
    -- For more information, see |:help nvim-dap-ui|
    dapui.setup {
      -- Set icons to characters that are more likely to work in every terminal.
      --    Feel free to remove or use ones that you like more! :)
      --    Don't feel like these are good choices.
      icons = { expanded = '▾', collapsed = '▸', current_frame = '*' },
      controls = {
        icons = {
          pause = '⏸',
          play = '▶',
          step_into = '⏎',
          step_over = '⏭',
          step_out = '⏮',
          step_back = 'b',
          run_last = '▶▶',
          terminate = '⏹',
          disconnect = '⏏',
        },
        element = 'repl',
        enabled = true,
      },
      floating = {
        border = 'single',
        mappings = {
          close = { 'q', '<Esc>' },
        },
      },
      layouts = {
        {
          elements = {
            { id = 'stacks', size = 0.25 },
            { id = 'scopes', size = 0.25 },
            { id = 'breakpoints', size = 0.25 },
            { id = 'watches', size = 0.25 },
          },
          position = 'left',
          size = 40,
        },
        {
          elements = {
            { id = 'repl', size = 0.5 },
            { id = 'console', size = 0.5 },
          },
          position = 'bottom',
          size = 30,
        },
      },
    }

    -- Toggle to see last session result. Without this, you can't see session output in case of unhandled exception.
    vim.keymap.set('n', '<F7>', dapui.toggle, { desc = 'Debug: See last session result.' })

    dap.listeners.after.event_initialized['dapui_config'] = dapui.open
    dap.listeners.before.event_terminated['dapui_config'] = dapui.close
    dap.listeners.before.event_exited['dapui_config'] = dapui.close
  end,
}
