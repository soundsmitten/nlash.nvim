return {
  'stevearc/oil.nvim',
  opts = {},
  tag = 'v2.8.0',

  config = function()
    local oil = require 'oil'
    oil.setup {
      -- Set the default keymap to <leader>o
      vim.keymap.set('n', '<leader>db', function()
        oil.open(nil)
      end),
    }
  end,

  -- Optional dependencies
  dependencies = { 'nvim-tree/nvim-web-devicons' },
}
