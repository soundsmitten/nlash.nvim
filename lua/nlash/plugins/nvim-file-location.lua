return {
  'diegoulloao/nvim-file-location',
  config = function()
    require('nvim-file-location').setup {
      keymap = '<leader>mL',
      mode = 'workdir',
      add_line = true,
      add_column = false,
      default_register = 'p',
    }
  end,
}
