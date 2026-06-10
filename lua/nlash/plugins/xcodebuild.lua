local was_setup = false
local progress_handle = nil
local is_work_machine = os.getenv 'NLCOMP' == 'work'
local external_build_job_id = nil

local function make_empty_report()
  return {
    output = {},
    tests = {},
    buildErrors = {},
    buildWarnings = {},
    testsCount = 0,
    testErrors = {},
    failedTestsCount = 0,
    xcresultFilepath = nil,
  }
end

local function make_failure_report(log_file, exit_code)
  local filename = vim.fn.fnamemodify(log_file, ':t')
  return {
    output = {},
    tests = {},
    buildErrors = {
      {
        filepath = log_file,
        filename = filename,
        lineNumber = 1,
        columnNumber = 0,
        message = { 'Build failed (exit ' .. tostring(exit_code) .. ')' },
      },
    },
    buildWarnings = {},
    testsCount = 0,
    testErrors = {},
    failedTestsCount = 0,
    xcresultFilepath = nil,
  }
end

local function get_external_build_command(build_for_testing, clean)
  local project_config = require 'xcodebuild.project.config'
  if not project_config.is_configured() then
    return nil, nil, 'Xcodebuild project is not configured'
  end

  local settings = project_config.settings
  if not settings.projectFile or not settings.scheme or not settings.destination then
    return nil, nil, 'Missing projectFile, scheme, or destination in xcodebuild settings'
  end

  local config = require('xcodebuild.core.config').options
  local project_flag = settings.projectFile:match '%.xcworkspace$' and '-workspace' or '-project'
  local extra_args = build_for_testing and config.commands.extra_test_args or config.commands.extra_build_args

  local command = {
    'xcodebuild',
    clean and 'clean' or nil,
    build_for_testing and 'build-for-testing' or 'build',
    project_flag,
    settings.projectFile,
    '-scheme',
    settings.scheme,
    '-destination',
    'id=' .. settings.destination,
  }

  if type(extra_args) == 'table' then
    for _, arg in ipairs(extra_args) do
      table.insert(command, arg)
    end
  end

  command = vim.tbl_filter(function(arg)
    return arg ~= nil
  end, command)

  return command, settings.workingDirectory
end

local function run_external_build(opts, callback)
  opts = opts or {}

  local command, cwd, err = get_external_build_command(opts.buildForTesting or false, opts.clean or false)
  if not command then
    vim.notify(err, vim.log.levels.ERROR)
    return
  end

  if external_build_job_id and vim.fn.jobwait({ external_build_job_id }, 0)[1] == -1 then
    vim.notify('External xcodebuild is already running', vim.log.levels.WARN)
    return
  end

  local title = (opts.buildForTesting and 'xcodebuild (external build-for-testing)') or 'xcodebuild (external build)'
  local appdata = require 'xcodebuild.project.appdata'
  local notifications = require 'xcodebuild.broadcasting.notifications'
  local events = require 'xcodebuild.broadcasting.events'
  local project_builder = require 'xcodebuild.project.builder'
  local config = require('xcodebuild.core.config').options
  local log_file = appdata.build_logs_filepath
  local log_dir = vim.fn.fnamemodify(log_file, ':h')
  vim.fn.mkdir(log_dir, 'p')
  vim.fn.writefile({ title, '', 'Running: ' .. table.concat(command, ' '), '' }, log_file)

  local parent_pid = vim.fn.getpid()
  local watchdog_script = [[
parent_pid="$1"
log_file="$2"
shift 2
"$@" >> "$log_file" 2>&1 &
child_pid=$!
on_term() {
  kill -TERM "$child_pid" 2>/dev/null
  wait "$child_pid" 2>/dev/null
  exit 143
}
trap on_term TERM INT HUP
while kill -0 "$child_pid" 2>/dev/null; do
  if ! kill -0 "$parent_pid" 2>/dev/null; then
    kill -TERM "$child_pid" 2>/dev/null
    wait "$child_pid" 2>/dev/null
    exit 0
  fi
  sleep 1
done
wait "$child_pid"
exit $?
]]

  local wrapped_command = { '/bin/sh', '-c', watchdog_script, 'xcodebuild-watchdog', tostring(parent_pid), log_file }
  vim.list_extend(wrapped_command, command)

  local build_id = notifications.start_build_timer(opts.buildForTesting or false)
  events.build_started(opts.buildForTesting or false)

  external_build_job_id = vim.fn.jobstart(wrapped_command, {
    cwd = cwd,
    on_exit = function(_, code, _)
      vim.schedule(function()
        external_build_job_id = nil

        local report = code == 0 and make_empty_report() or make_failure_report(log_file, code)
        project_builder.currentJobId = nil
        appdata.report = report

        if config.restore_on_start then
          appdata.write_report(report)
        end

        notifications.stop_build_timer()
        notifications.send_build_finished(report, build_id, false, {})

        if code == 0 then
          if type(callback) == 'function' then
            vim.defer_fn(function()
              local ok, err = pcall(callback, report)
              if not ok then
                vim.notify('Post-build action failed: ' .. tostring(err), vim.log.levels.ERROR)
              end
            end, 100)
          end
        end
      end)
    end,
  })

  project_builder.currentJobId = external_build_job_id
end

local function setupXcodebuildRosettaBuildArgs()
  local config = require 'xcodebuild.core.config'
  -- set an env variable on work machine to always use rosetta simulators
  if os.getenv 'NLCOMP' == 'work' and string.match(vim.g.xcodebuild_platform, 'Simulator') then
    config.options.commands.extra_build_args = { '-parallelizeTargets', 'ARCHS=x86_64', 'OTHER_LDFLAGS=$(inherited) -Xlinker -interposable' }
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
  util.safeKeymapDel('n', '<leader>xg')
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
    vim.cmd 'XcodebuildTest'
  end, { desc = 'Run Tests' })
  vim.keymap.set('v', '<leader>xt', function()
    vim.cmd 'XcodebuildTestSelected'
  end, { desc = 'Run Selected Tests' })
  vim.keymap.set('n', '<leader>xT', function()
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
  vim.keymap.set('n', '<leader>xk', '<cmd>XcodebuildCancel<cr>', { desc = 'Cancel Xcodebuild' })

  vim.keymap.set('n', '<leader>xx', '<cmd>XcodebuildQuickfixLine<cr>', { desc = 'Quickfix Line' })
  vim.keymap.set('n', '<leader>xa', '<cmd>XcodebuildCodeActions<cr>', { desc = 'Show Code Actions' })

  vim.keymap.set('n', '<leader>xg', function()
    local snacks = require 'snacks'

    local progress_id = 'tuist_generate'
    snacks.notifier.notify('Running tuist generate...', 'info', {
      id = progress_id,
      timeout = false,
    })

    vim.fn.jobstart({ 'tuist', 'generate', '--no-open' }, {
      on_exit = function(_, code)
        snacks.notifier.hide(progress_id)
        if code == 0 then
          vim.notify('✅ Tuist generate complete', vim.log.levels.INFO)
          vim.defer_fn(function()
            vim.cmd 'e'
          end, 500)
        else
          vim.notify('❌ Tuist generate failed', vim.log.levels.ERROR)
        end
      end,
    })
  end, { desc = 'Run Tuist Generate' })

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
    xcodebuild.debug_tests()
  end, { desc = 'Debug Tests' })
  vim.keymap.set('n', '<leader>dT', function()
    setupXcodebuildRosettaBuildArgs()
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
        local snacks = require 'snacks'
        if progress_handle then
          if not message:find 'Loading' then
            snacks.notifier.hide(progress_handle)
            progress_handle = nil
            if vim.trim(message) ~= '' then
              snacks.notify(message, { level = severity })
              os.execute(string.format("osascript -e 'display notification \"%s\" with title \"xcodebuild\"'", message:gsub('"', '\\"')))
            end
          end
        else
          snacks.notify(message, { level = severity })
          os.execute(string.format("osascript -e 'display notification \"%s\" with title \"xcodebuild\"'", message:gsub('"', '\\"')))
        end
      end,
      notify_progress = function(message)
        local snacks = require 'snacks'
        local spinner = { '⠋', '⠙', '⠹', '⠸', '⠼', '⠴', '⠦', '⠧', '⠇', '⠏' }

        if not progress_handle then
          progress_handle = 'xcodebuild_progress'
        end

        snacks.notifier.notify(message, 'info', {
          id = progress_handle,
          title = 'xcodebuild.nvim',
          timeout = false,
          opts = function(notif)
            notif.icon = spinner[math.floor(vim.uv.hrtime() / (1e6 * 80)) % #spinner + 1]
          end,
        })
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
  branch = 'main',
  -- tag = 'v7.0.0',
  dependencies = {
    'folke/snacks.nvim',
    'MunifTanjim/nui.nvim',
    'stevearc/oil.nvim',
    'nvim-treesitter/nvim-treesitter',
  },
  config = function()
    require('xcodebuild').setup(getXcodebuildConfig())
    if is_work_machine then
      local helpers = require 'xcodebuild.helpers'
      local project_builder = require 'xcodebuild.project.builder'

      project_builder.build_project = function(opts, callback)
        opts = opts or {}

        if not helpers.validate_project() then
          return
        end

        run_external_build(opts, callback)
      end
    end

    if require('xcodebuild.project.config').is_configured() then
      was_setup = true
      setupXcodebuildKeymaps()
    else
      vim.keymap.set('n', '<leader>xS', '<cmd>XcodebuildSetup<cr>', { desc = 'Set up Xcode project' })
      vim.keymap.set('n', '<leader>X', '<Noop>', { desc = 'Disabled (accident prevention)' })
    end
  end,
}
