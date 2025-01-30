return {
  'folke/snacks.nvim',
  ---@type snacks.Config
  opts = {
    lazygit = {
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
