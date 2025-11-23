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
      { '<leader>h', group = 'Git [H]unk' },
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

    -- visual mode
    require('which-key').add {
      { '<leader>h', desc = 'Git [H]unk', mode = 'v' },
    }

    -- filetype specific
    vim.api.nvim_create_autocmd('FileType', {
      pattern = 'norg',
      callback = function()
        require('which-key').add {
          { '<localleader>', group = 'Neorg', buffer = 0 },
        }
      end,
    })
  end,
}
