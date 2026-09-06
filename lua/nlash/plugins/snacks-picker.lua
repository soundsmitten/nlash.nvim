local function open_notification(picker, item)
  picker:close()
  if not item then
    return
  end

  vim.schedule(function()
    local notification = item.item
    local buffer = vim.api.nvim_create_buf(false, true)
    local lines = vim.split(notification.msg, '\n', { plain = true })
    if notification.title and notification.title ~= '' then
      table.insert(lines, 1, '# ' .. notification.title)
      table.insert(lines, 2, '')
    end

    vim.api.nvim_buf_set_lines(buffer, 0, -1, false, lines)
    vim.bo[buffer].filetype = notification.ft or 'markdown'
    vim.bo[buffer].modifiable = false
    vim.api.nvim_set_current_buf(buffer)
  end)
end

local function open_message_history()
  local lines = { '# Neovim Messages', '' }
  local messages = vim.api.nvim_exec2('messages', { output = true }).output
  if messages == '' then
    table.insert(lines, '_No messages._')
  else
    vim.list_extend(lines, vim.split(messages, '\n', { plain = true }))
  end

  vim.list_extend(lines, { '', '# Notifications', '' })
  local notifications = Snacks.notifier.get_history()
  if #notifications == 0 then
    table.insert(lines, '_No notifications._')
  end
  for _, notification in ipairs(notifications) do
    local heading = notification.title
    if not heading or heading == '' then
      heading = notification.level:gsub('^%l', string.upper)
    end
    vim.list_extend(lines, { '## ' .. heading, '' })
    vim.list_extend(lines, vim.split(notification.msg, '\n', { plain = true }))
    table.insert(lines, '')
  end

  local name = 'snacks://message-history'
  local buffer = vim.fn.bufnr(name)
  if buffer == -1 then
    buffer = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_name(buffer, name)
  end
  vim.bo[buffer].modifiable = true
  vim.api.nvim_buf_set_lines(buffer, 0, -1, false, lines)
  vim.bo[buffer].filetype = 'markdown'
  vim.bo[buffer].modifiable = false
  vim.api.nvim_set_current_buf(buffer)
end

return {
  'folke/snacks.nvim',
  opts = {
    picker = {
      main = {
        file = false,
        current = true,
      },
      gh_pr = {},
    },
    image = { enabled = false, formats = {} },
  },

  keys = {
    {
      '<leader>sH',
      function()
        Snacks.picker.help()
      end,
      desc = 'Help',
    },
    {
      '<leader>sh',
      function()
        Snacks.picker.notifications { confirm = open_notification }
      end,
      desc = 'Notification History',
    },
    {
      '<leader>sm',
      open_message_history,
      desc = 'Message History',
    },
    {
      '<leader>sk',
      function()
        Snacks.picker.keymaps()
      end,
      desc = 'Keymaps',
    },
    {
      '<leader>s.',
      function()
        Snacks.picker.recent()
      end,
      desc = 'Recent Files',
    },
    {
      '<leader>sr',
      function()
        Snacks.picker.resume()
      end,
      desc = 'Resume Last Picker',
    },

    {
      '<leader>sp',
      function()
        Snacks.picker.pickers()
      end,
      desc = 'Pickers',
    },
    {
      '<leader>sg',
      function()
        Snacks.picker.grep()
      end,
      desc = 'Grep',
    },
    {
      '<leader>sw',
      function()
        Snacks.picker.grep_word()
      end,
      desc = 'Grep visual selection or word)',
    },
    {
      '<leader>sf',
      function()
        Snacks.picker.files()
      end,
      desc = 'Find Files',
    },
    {
      '<leader><leader>',
      function()
        Snacks.picker.buffers()
      end,
      desc = 'Buffers',
    },
    {
      '<leader>/',
      function()
        Snacks.picker.lines()
      end,
      desc = 'Buffer Lines',
    },
    {
      '<leader>s/',
      function()
        Snacks.picker.grep_buffers()
      end,
      desc = 'Grep Open Buffers',
    },
    {
      '<leader>sn',
      function()
        Snacks.picker.files { cwd = vim.fn.stdpath 'config' }
      end,
      desc = 'Find Config File',
    },
    {
      '<leader>su',
      function()
        Snacks.picker.files { cwd = vim.fn.expand '~' .. '/Repos' }
      end,
      desc = 'Find in Repos',
    },
    {
      '<leader>sD',
      function()
        Snacks.picker.files {
          cwd = vim.fn.getcwd() .. '/docs/nlash',
          cmd = 'fd',
          args = { '--type', 'f', '--no-ignore', '--hidden' },
        }
      end,
      desc = 'Find Docs (nlash)',
    },

    -- lsp
    {
      'gd',
      function()
        Snacks.picker.lsp_definitions()
      end,
      desc = 'Goto Definition',
    },
    {
      'gD',
      function()
        Snacks.picker.lsp_declarations()
      end,
      desc = 'Goto Declaration',
    },
    {
      'gr',
      function()
        Snacks.picker.lsp_references()
      end,
      nowait = true,
      desc = 'References',
    },
    {
      'gI',
      function()
        Snacks.picker.lsp_implementations()
      end,
      desc = 'Goto Implementation',
    },
    {
      'gy',
      function()
        Snacks.picker.lsp_type_definitions()
      end,
      desc = 'Goto T[y]pe Definition',
    },
    {
      '<leader>ss',
      function()
        require('mini.sessions').select()
      end,
      desc = 'Sessions',
    },
    {
      '<leader>sy',
      function()
        Snacks.picker.lsp_symbols()
      end,
      desc = 'LSP S[y]mbols',
    },
    {
      '<leader>sY',
      function()
        Snacks.picker.lsp_workspace_symbols()
      end,
      desc = 'LSP Workspace S[Y]mbols',
    },
    {
      '<leader>sd',
      function()
        Snacks.picker.diagnostics()
      end,
      desc = 'Help',
    },
    {
      '<leader>he',
      function()
        local argfiles = {}
        for i = 0, vim.fn.argc() - 1 do
          local file = vim.fn.argv(i)
          if file and file ~= '' then
            table.insert(argfiles, {
              idx = i + 1,
              text = file,
              file = file,
            })
          end
        end

        if #argfiles == 0 then
          vim.notify('No files in arglist', vim.log.levels.INFO)
          return
        end

        Snacks.picker.pick {
          items = argfiles,
          title = 'Arglist Files',
        }
      end,
      desc = 'Arglist Files',
    },
    -- git
    {
      '<leader>gb',
      function()
        Snacks.picker.git_branches()
      end,
      desc = 'Git Branches',
    },
    {
      '<leader>gl',
      function()
        Snacks.picker.git_log()
      end,
      desc = 'Git Log',
    },
    {
      '<leader>gL',
      function()
        Snacks.picker.git_log_line()
      end,
      desc = 'Git Log Line',
    },
    {
      '<leader>gS',
      function()
        Snacks.picker.git_status()
      end,
      desc = 'Git Status',
    },
    {
      '<leader>gs',
      function()
        Snacks.picker.git_stash()
      end,
      desc = 'Git Stash',
    },
    {
      '<leader>gd',
      function()
        Snacks.picker.git_diff()
      end,
      desc = 'Git Diff (Hunks)',
    },
    {
      '<leader>gf',
      function()
        Snacks.picker.git_log_file()
      end,
      desc = 'Git Log File',
    },
    -- Github
    {
      '<leader>gp',
      function()
        Snacks.picker.gh_pr()
      end,
      desc = 'GitHub Pull Requests (open)',
    },
    {
      '<leader>gP',
      function()
        Snacks.picker.gh_pr { state = 'all' }
      end,
      desc = 'GitHub Pull Requests (all)',
    },
  },
}
