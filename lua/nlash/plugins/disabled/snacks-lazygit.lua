return {
  'folke/snacks.nvim',
  opts = {
    lazygit = {
      enabled = true,
      cmd = 'lazygit',
      args = {},
    },
  },

  keys = {
    {
      '<leader>gf',
      function()
        Snacks.lazygit.log_file()
      end,
      desc = 'Lazygit Current File History',
    },
    {
      '<leader>gg',
      function()
        Snacks.lazygit()
      end,
      desc = 'Lazygit',
    },
  },
}
