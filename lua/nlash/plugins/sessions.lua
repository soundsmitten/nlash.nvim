return {
  'natecraddock/sessions.nvim',
  branch = 'master',

  config = function()
    local sessions = require 'sessions'

    sessions.setup {
      events = { 'WinEnter' },
      session_filepath = vim.fn.stdpath 'data' .. '/sessions',
      absolute = true,
    }
  end,
}
