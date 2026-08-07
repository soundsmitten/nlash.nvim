local function is_gradle_project()
  return vim.fn.filereadable(vim.fn.getcwd() .. '/gradlew') == 1
end

local last_task = nil

local function run_gradle(task)
  local overseer = require 'overseer'
  last_task = task

  local cwd = vim.fn.getcwd()
  local cmd

  if task:lower():match '^install' then
    local launch = string.format(
      [[apk=$(find '%s/app/build/outputs/apk' -name '*.apk' 2>/dev/null | xargs ls -t | head -1) && ]]
        .. [[pkg=$(aapt dump badging "$apk" 2>/dev/null | grep "^package:" | sed "s/.*name='\\([^']*\\)'.*/\\1/") && ]]
        .. [[adb shell monkey -p "$pkg" -c android.intent.category.LAUNCHER 1]],
      cwd
    )
    cmd = './gradlew ' .. task .. ' && ' .. launch
  else
    cmd = './gradlew ' .. task
  end

  overseer.new_task({
    cmd = { 'sh', '-c', cmd },
    name = 'gradle ' .. task,
  }):start()
end

local function fetch_and_pick(on_select)
  if not is_gradle_project() then
    vim.notify('No gradlew found in ' .. vim.fn.getcwd(), vim.log.levels.WARN)
    return
  end

  local snacks = require 'snacks'
  local progress_id = 'gradle_tasks'
  snacks.notifier.notify('Fetching Gradle tasks...', 'info', { id = progress_id, timeout = false })

  local lines = {}
  vim.fn.jobstart({ './gradlew', 'tasks', '--all', '--console=plain', '-q' }, {
    cwd = vim.fn.getcwd(),
    stdout_buffered = true,
    on_stdout = function(_, data)
      vim.list_extend(lines, data)
    end,
    on_exit = function()
      snacks.notifier.hide(progress_id)

      local tasks = {}
      for _, line in ipairs(lines) do
        local task = line:match '^([%w:]+)%s*%-'
        if task then
          table.insert(tasks, task)
        end
      end

      if #tasks == 0 then
        vim.notify('No Gradle tasks found', vim.log.levels.WARN)
        return
      end

      vim.schedule(function()
        snacks.picker.select(tasks, { prompt = 'Gradle Task' }, function(item)
          if item then
            on_select(item)
          end
        end)
      end)
    end,
  })
end

local function pick_gradle_task()
  fetch_and_pick(run_gradle)
end

local function rerun_or_pick()
  if last_task then
    run_gradle(last_task)
  else
    fetch_and_pick(run_gradle)
  end
end

return {
  'stevearc/overseer.nvim',
  lazy = true,
  cmd = { 'OverseerRun', 'OverseerToggle', 'OverseerOpen' },
  keys = {
    { '<leader>Ao', '<cmd>OverseerToggle<cr>', desc = 'Toggle Overseer' },
    { '<leader>Ar', '<cmd>OverseerRun<cr>', desc = 'Run Task' },
    { '<leader>Ag', pick_gradle_task, desc = 'Pick Gradle Task' },
    { '<leader>Ae', rerun_or_pick, desc = 'Re-run Last Gradle Task' },
  },
  config = function()
    require('overseer').setup {
      task_list = {
        direction = 'bottom',
        min_height = 15,
        max_height = 25,
        default_detail = 1,
        keymaps = {
          ['<C-k>'] = false,
          ['<C-j>'] = false,
        },
      },
      form = { border = 'rounded' },
      confirm = { border = 'rounded' },
      task_win = { border = 'rounded' },
    }
  end,
}
