return {
  'nvim-neorg/neorg',
  lazy = true,
  version = '*', -- Pin Neorg to the latest stable release
  config = function()
    require('neorg').setup {
      load = {
        ['core.defaults'] = {}, -- Load all the default modules
        ['core.concealer'] = {
          config = {
            icon_preset = 'basic',
          },
        }, -- Allows for use of icons
        ['core.itero'] = {}, -- list/heading continuation
        ['core.dirman'] = { -- Manages Neorg workspaces
          config = {
            workspaces = {
              notes = '~/neorg/notes',
            },
            default_workspace = 'notes',
          },
        },
      },
    }
  end,
}
