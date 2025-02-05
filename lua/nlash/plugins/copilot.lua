return {
  {
    'zbirenbaum/copilot-cmp',
    config = function()
      require('copilot_cmp').setup()
    end,
  },
  {
    'zbirenbaum/copilot.lua',
    cmd = 'Copilot',
    event = 'InsertEnter',
    config = function()
      require('copilot').setup {
        suggestion = {
          auto_trigger = false,
          keymap = {
            accept = '<TAB>',
            accept_word = '<C-w>',
            accept_line = '<C-l>',
            next = '<C-j>',
            prev = '<C-k>',
            dismiss = '<ESC>',
            open = '<C-,>',
          },
        },
        panel = { enabled = false },
      }
    end,
  },
}
