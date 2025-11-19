vim.api.nvim_set_hl(0, 'NLBlinkIndentOrange', { default = true, fg = '#ee9360', ctermfg = 'Brown' })

return {
  'saghen/blink.indent',
  --- @module 'blink.indent'
  --- @type blink.indent.Config
  opts = {
    scope = {
      highlights = { 'NLBlinkIndentOrange' },
    },
  },
}
