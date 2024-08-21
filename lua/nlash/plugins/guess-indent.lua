return {
  'nmac427/guess-indent.nvim',
  lazy = false,
  config = function()
    require('guess-indent').setup {}
    vim.keymap.set('n', '<Tab>g', vim.cmd.GuessIndent, { desc = 'GuessIndent (manual)' })
  end,
}
