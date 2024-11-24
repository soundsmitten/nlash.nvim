return {
  'natecraddock/workspaces.nvim',
  branch = 'master',

  config = function()
    local workspaces = require 'workspaces'

    workspaces.setup {
      hooks = {
        -- open = { 'Telescope find_files' },
        open = function()
          require('oil').open(workspaces.path())
          require('telescope.builtin').find_files()
        end,
      },
    }
  end,
}
