return {
  'nvim-orgmode/orgmode',
  event = 'VeryLazy',
  ft = { 'org' },
  config = function()
    -- Setup orgmode
    require('orgmode').setup {
      org_agenda_files = '~/orgfiles/**/*',
      org_default_notes_file = '~/orgfiles/inbox.org',
    }

    -- Prevent folds from collapsing when exiting insert mode
    vim.api.nvim_create_autocmd('FileType', {
      pattern = 'org',
      callback = function()
        vim.opt_local.foldmethod = 'expr'
        vim.opt_local.foldexpr = 'nvim_treesitter#foldexpr()'
        vim.opt_local.foldlevel = 99
        vim.opt_local.foldlevelstart = 99
      end,
    })
  end,
}
