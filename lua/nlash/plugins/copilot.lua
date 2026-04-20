local util = require 'nlash.util'
-- util.uniqueKeymap('n', '<leader>aD', '<cmd>Copilot disable<CR>')
return {
  {
    'zbirenbaum/copilot.lua',
    cmd = 'Copilot',
    event = 'InsertEnter',
    config = function()
      require('copilot').setup {
        suggestion = {
          enabled = false, -- Disable inline suggestions entirely (using blink-copilot instead)
        },
        filetypes = {
          go = false,
        },
        panel = { enabled = false },
      }
    end,
  },
}
