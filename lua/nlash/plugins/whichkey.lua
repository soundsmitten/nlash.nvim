return {
  'folke/which-key.nvim',
  event = 'VeryLazy',
  config = function()
    require('which-key').setup()

    -- Document existing key chains
    require('which-key').add {
      { '<leader>a', group = '[A]I' },
      { '<leader>a_', hidden = true },
      { '<leader>d', group = '[D]ebug' },
      { '<leader>d_', hidden = true },
      { '<leader>f', group = '[F]ormat/Files' },
      { '<leader>f_', hidden = true },
      { '<leader>g', group = '[G]it' },
      { '<leader>g_', hidden = true },
      { '<leader>h', group = 'Args ([H]arpoon-ish)' },
      { '<leader>h_', hidden = true },
      { '<leader>m', group = '[M]isc' },
      { '<leader>m_', hidden = true },
      { '<leader>s', group = '[S]earch' },
      { '<leader>s_', hidden = true },
      { '<leader>t', group = '[T]rouble/Toggle' },
      { '<leader>t_', hidden = true },
      { '<leader>x', group = '[X]codebuild' },
      { '<leader>x_', hidden = true },
      { '<localleader>s', group = '[S]essions' },
      { '<localleader>s_', hidden = true },
    }
  end,
}
