return {
  'folke/snacks.nvim',
  opts = {
    zen = { enabled = true, toggles = { dim = false } },
  },
  keys = {
    {
      '<leader>zz',
      function()
        Snacks.zen()
      end,
      desc = 'Toggle Zen Mode',
    },
  },
}
