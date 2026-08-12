local util = require 'nlash.util'

local M = {}

local function listAgents()
  if vim.env.HERDR_ENV ~= '1' then
    vim.notify('Neovim is not running inside Herdr', vim.log.levels.WARN)
    return
  end

  local result = vim.system({ 'herdr', 'agent', 'list' }, { text = true }):wait()
  if result.code ~= 0 then
    vim.notify(result.stderr or 'Could not list Herdr agents', vim.log.levels.ERROR)
    return
  end

  local ok, response = pcall(vim.json.decode, result.stdout)
  if not ok or not response.result or not response.result.agents then
    vim.notify('Could not understand the Herdr agent list', vim.log.levels.ERROR)
    return
  end

  return vim.tbl_filter(function(agent)
    return agent.pane_id ~= vim.env.HERDR_PANE_ID
  end, response.result.agents)
end

local function selectAgent(onChoice)
  local agents = listAgents()
  if not agents then
    return
  end

  if #agents == 0 then
    vim.notify('No Herdr agents are available', vim.log.levels.WARN)
    return
  end

  local currentTabAgents = vim.tbl_filter(function(agent)
    return agent.tab_id == vim.env.HERDR_TAB_ID
  end, agents)

  -- Auto-select if only one candidate in the current tab
  if #currentTabAgents == 1 then
    onChoice(currentTabAgents[1])
    return
  end

  -- Show picker over all agents (current tab first)
  local sorted = {}
  for _, a in ipairs(currentTabAgents) do table.insert(sorted, a) end
  for _, a in ipairs(agents) do
    if a.tab_id ~= vim.env.HERDR_TAB_ID then table.insert(sorted, a) end
  end

  vim.ui.select(sorted, {
    prompt = 'Send to Herdr agent',
    format_item = function(agent)
      local title = agent.terminal_title_stripped or agent.agent or 'Agent'
      return string.format('%s (%s)', title, agent.pane_id)
    end,
  }, function(agent)
    if agent then onChoice(agent) end
  end)
end

local function sendText(text)
  selectAgent(function(agent)
    vim.system({ 'herdr', 'pane', 'send-text', agent.pane_id, text .. '\n' }, { text = true }, function(result)
      if result.code ~= 0 then
        vim.schedule(function()
          vim.notify(result.stderr or 'Could not send text to Herdr', vim.log.levels.ERROR)
        end)
      end
    end)
  end)
end

function M.setup()
  -- Navigate windows, crossing into herdr (or tmux) at split edges
  local function nav(wincmd, dir)
    local prev = vim.api.nvim_get_current_win()
    vim.cmd('wincmd ' .. wincmd)
    if vim.api.nvim_get_current_win() ~= prev then
      return
    end
    if vim.env.HERDR_PANE_ID and vim.env.HERDR_PANE_ID ~= '' then
      local herdr = vim.env.HERDR_BIN_PATH
      if herdr == nil or herdr == '' then
        herdr = 'herdr'
      end
      vim.fn.system { herdr, 'pane', 'focus', '--direction', dir, '--pane', vim.env.HERDR_PANE_ID }
    elseif vim.env.TMUX and vim.env.TMUX ~= '' then
      local tmux = { left = 'Left', down = 'Down', up = 'Up', right = 'Right' }
      pcall(vim.cmd, 'TmuxNavigate' .. tmux[dir])
    end
  end

  local function map(lhs, wincmd, dir, desc)
    vim.keymap.set('n', lhs, function()
      nav(wincmd, dir)
    end, { silent = true, noremap = true, desc = desc })
  end

  map('<C-h>', 'h', 'left', 'Navigate left (vim/herdr)')
  map('<C-j>', 'j', 'down', 'Navigate down (vim/herdr)')
  map('<C-k>', 'k', 'up', 'Navigate up (vim/herdr)')
  map('<C-l>', 'l', 'right', 'Navigate right (vim/herdr)')

  -- Send current file path to a herdr agent
  util.uniqueKeymap('n', '<leader>af', function()
    local path = vim.fn.expand '%:.'
    if path == '' then
      vim.notify('Current buffer has no file path', vim.log.levels.WARN)
      return
    end
    sendText('@' .. path .. ' ')
  end, { desc = 'Send file path to Herdr agent' })

  -- Send visual selection to a herdr agent
  util.uniqueKeymap('x', '<leader>at', function()
    local selection = vim.fn.getregion(vim.fn.getpos 'v', vim.fn.getpos '.', { type = vim.fn.mode() })
    sendText(table.concat(selection, '\n'))
  end, { desc = 'Send selected text to Herdr agent' })
end

return M
