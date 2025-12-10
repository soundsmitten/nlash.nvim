vim.api.nvim_set_hl(0, 'NLBlinkIndentGray', { default = true, fg = '#bcbfc4', ctermfg = 250 })

return {
  'saghen/blink.indent',
  --- @module 'blink.indent'
  --- @type blink.indent.Config
  opts = {
    scope = {
      highlights = { 'NLBlinkIndentGray' },
    },
  },
}
