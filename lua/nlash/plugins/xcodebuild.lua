local was_setup = false

local function setupXcodebuildRosettaBuildArgs()
  local config = require 'xcodebuild.core.config'
  -- set an env variable on work machine to always use rosetta simulators
  if os.getenv 'NLCOMP' == 'work' and string.match(vim.g.xcodebuild_platform, 'Simulator') then
    config.options.commands.extra_build_args = { '-parallelizeTargets', 'ARCHS=x86_64' }
    config.options.commands.extra_test_args = { '-parallelizeTargets', 'ARCHS=x86_64' }
  else
    config.options.commands.extra_build_args = { '-parallelizeTargets' }
    config.options.commands.extra_test_args = { '-parallelizeTargets' }
  end
end

local function removeXcodebuildKeymaps()
  local util = require 'nlash.util'
  util.safeKeymapDel('n', '<leader>X')
  util.safeKeymapDel('n', '<leader>xf')
  util.safeKeymapDel('n', '<leader>xb')
  util.safeKeymapDel('n', '<leader>xB')
  util.safeKeymapDel('n', '<leader>xr')
  util.safeKeymapDel('n', '<leader>xt')
  util.safeKeymapDel('v', '<leader>xt')
  util.safeKeymapDel('n', '<leader>xT')
  util.safeKeymapDel('n', '<leader>xl')
  util.safeKeymapDel('n', '<leader>xc')
  util.safeKeymapDel('n', '<leader>xC')
  util.safeKeymapDel('n', '<leader>xe')
  util.safeKeymapDel('n', '<leader>xs')
  util.safeKeymapDel('n', '<leader>xd')
  util.safeKeymapDel('n', '<leader>xp')
  util.safeKeymapDel('n', '<leader>xq')
  util.safeKeymapDel('n', '<leader>xx')
  util.safeKeymapDel('n', '<leader>xa')
  util.safeKeymapDel('n', '<leader>dd')
  util.safeKeymapDel('n', '<leader>dr')
  util.safeKeymapDel('n', '<leader>dt')
  util.safeKeymapDel('n', '<leader>dT')
  util.safeKeymapDel('n', '<leader>b')
  util.safeKeymapDel('n', '<leader>B')
  util.safeKeymapDel('n', '<leader>dx')
end

local function setupXcodebuildKeymaps()
  local util = require 'nlash.util'
  local xcodebuild = require 'xcodebuild.integrations.dap'

  util.safeKeymapDel('n', '<leader>X')
  vim.keymap.set('n', '<leader>X', '<cmd>XcodebuildPicker<cr>', { desc = 'Show Xcodebuild Actions' })
  vim.keymap.set('n', '<leader>xf', '<cmd>XcodebuildProjectManager<cr>', { desc = 'Show Project Manager Actions' })

  vim.keymap.set('n', '<leader>xb', '<cmd>XcodebuildBuild<cr>', { desc = 'Build Project' })
  vim.keymap.set('n', '<leader>xB', '<cmd>XcodebuildBuildForTesting<cr>', { desc = 'Build For Testing' })
  vim.keymap.set('n', '<leader>xr', '<cmd>XcodebuildBuildRun<cr>', { desc = 'Build & Run Project' })

  vim.keymap.set('n', '<leader>xt', function()
    vim.cmd 'XcodebuildTestExplorerShow'
    vim.cmd 'XcodebuildTest'
  end, { desc = 'Run Tests' })
  vim.keymap.set('v', '<leader>xt', function()
    vim.cmd 'XcodebuildTestExplorerShow'
    vim.cmd 'XcodebuildTestSelected'
  end, { desc = 'Run Selected Tests' })
  vim.keymap.set('n', '<leader>xT', function()
    vim.cmd 'XcodebuildTestExplorerShow'
    vim.cmd 'XcodebuildTestClass'
  end, { desc = 'Run This Test Class' })

  vim.keymap.set('n', '<leader>xl', '<cmd>XcodebuildToggleLogs<cr>', { desc = 'Toggle Xcodebuild Logs' })
  vim.keymap.set('n', '<leader>xc', '<cmd>XcodebuildToggleCodeCoverage<cr>', { desc = 'Toggle Code Coverage' })
  vim.keymap.set('n', '<leader>xC', '<cmd>XcodebuildShowCodeCoverageReport<cr>', { desc = 'Show Code Coverage Report' })
  vim.keymap.set('n', '<leader>xe', '<cmd>XcodebuildTestExplorerToggle<cr>', { desc = 'Toggle Test Explorer' })
  vim.keymap.set('n', '<leader>xs', '<cmd>XcodebuildFailingSnapshots<cr>', { desc = 'Show Failing Snapshots' })

  vim.keymap.set('n', '<leader>xd', '<cmd>XcodebuildSelectDevice<cr>', { desc = 'Select Device' })
  vim.keymap.set('n', '<leader>xp', '<cmd>XcodebuildSelectTestPlan<cr>', { desc = 'Select Test Plan' })
  vim.keymap.set('n', '<leader>xq', '<cmd>Telescope quickfix<cr>', { desc = 'Show QuickFix List' })

  vim.keymap.set('n', '<leader>xx', '<cmd>XcodebuildQuickfixLine<cr>', { desc = 'Quickfix Line' })
  vim.keymap.set('n', '<leader>xa', '<cmd>XcodebuildCodeActions<cr>', { desc = 'Show Code Actions' })

  vim.keymap.set('n', '<leader>dd', function()
    setupXcodebuildRosettaBuildArgs()
    xcodebuild.build_and_debug()
  end, { desc = 'Build & Debug' })
  vim.keymap.set('n', '<leader>dr', function()
    setupXcodebuildRosettaBuildArgs()
    xcodebuild.debug_without_build()
  end, { desc = 'Debug Without Building' })
  vim.keymap.set('n', '<leader>dt', function()
    setupXcodebuildRosettaBuildArgs()
    vim.cmd 'XcodebuildTestExplorerShow'
    xcodebuild.debug_tests()
  end, { desc = 'Debug Tests' })
  vim.keymap.set('n', '<leader>dT', function()
    setupXcodebuildRosettaBuildArgs()
    vim.cmd 'XcodebuildTestExplorerShow'
    xcodebuild.debug_class_tests()
  end, { desc = 'Debug Class Tests' })

  vim.keymap.set('n', '<leader>b', xcodebuild.toggle_breakpoint, { desc = 'Toggle Breakpoint' })
  vim.keymap.set('n', '<leader>B', xcodebuild.toggle_message_breakpoint, { desc = 'Toggle Message Breakpoint' })

  vim.keymap.set('n', '<leader>dx', function()
    xcodebuild.terminate_session()
    require('dap').listeners.after['event_terminated']['me']()
  end, { desc = 'Terminate debugger' })
end

local function getXcodebuildConfig()
  return {
    show_build_progress_bar = true,
    logs = {
      auto_open_on_success_tests = false,
      auto_open_on_failed_tests = false,
      auto_open_on_success_build = false,
      auto_open_on_failed_build = true,
      auto_focus = false,
      auto_close_on_app_launch = true,
      only_summary = true,
      notify = function(message, severity)
        local fidget = require 'fidget'
        if progress_handle then
          progress_handle.message = message
          if not message:find 'Loading' then
            progress_handle:finish()
            progress_handle = nil
            if vim.trim(message) ~= '' then
              fidget.notify(message, severity)
            end
          end
        else
          fidget.notify(message, severity)
        end
      end,
      notify_progress = function(message)
        local progress = require 'fidget.progress'

        if progress_handle then
          progress_handle.title = ''
          progress_handle.message = message
        else
          progress_handle = progress.handle.create {
            message = message,
            lsp_client = { name = 'xcodebuild.nvim' },
          }
        end
      end,
      integrations = {
        pymobiledevice = {
          enabled = true,
        },
      },
    },
    code_coverage = {
      enabled = true,
    },
    commands = {
      -- this is to force rosetta simulators. delete when we don't need to anymore.
      -- extra_build_args = '-parallelizeTargets ARCHS=x86_64',
    },
  }
end

vim.api.nvim_create_user_command('NLXcodebuildRefresh', function()
  require('xcodebuild').setup(getXcodebuildConfig())
  local project_config = require 'xcodebuild.project.config'
  if project_config.is_configured() then
    setupXcodebuildKeymaps()

    local project_name = vim.fs.basename(project_config.settings.projectFile or ''):gsub('%..*', '')
    was_setup = true
    vim.notify('🚀 ' .. project_name .. ' • ' .. project_config.settings.scheme .. ' ready')
  else
    removeXcodebuildKeymaps()
    vim.keymap.set('n', '<leader>xS', '<cmd>XcodebuildSetup<cr>', { desc = 'Set up Xcode project' })
    vim.keymap.set('n', '<leader>X', '<Noop>', { desc = 'Disabled (accident prevention)' })
  end
end, { nargs = 0 })

vim.api.nvim_create_autocmd('User', {
  pattern = 'XcodebuildProjectSettingsUpdated',
  callback = function(event)
    if not was_setup then
      setupXcodebuildKeymaps()
      was_setup = true
    end
  end,
})

return {
  'wojciech-kulik/xcodebuild.nvim',
  -- dir = os.getenv 'HOME' .. '/Repos/xcodebuild.nvim',
  -- branch = 'main',
  tag = 'v7.0.0',
  dependencies = {
    'folke/snacks.nvim',
    'MunifTanjim/nui.nvim',
    'stevearc/oil.nvim',
    'nvim-treesitter/nvim-treesitter',
  },
  config = function()
    require('xcodebuild').setup(getXcodebuildConfig())
    if require('xcodebuild.project.config').is_configured() then
      was_setup = true
      setupXcodebuildKeymaps()
    else
      vim.keymap.set('n', '<leader>xS', '<cmd>XcodebuildSetup<cr>', { desc = 'Set up Xcode project' })
      vim.keymap.set('n', '<leader>X', '<Noop>', { desc = 'Disabled (accident prevention)' })
    end
  end,
}
