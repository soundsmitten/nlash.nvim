return {
  'natecraddock/workspaces.nvim',
  dependencies = { 'natecraddock/sessions.nvim' },
  branch = 'master',

  config = function()
    local workspaces = require 'workspaces'

    workspaces.setup {
      hooks = {
        -- open = { 'Telescope find_files' },
        open = function()
          if require('sessions').load(nil, { autosave = true }) == false then
            require('oil').open(workspaces.path())
            require('sessions').save(nil, { autosave = true })
          end
        end,
      },
    }
  end,
}
