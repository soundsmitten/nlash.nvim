require 'nlash.opt'
require 'nlash.keymap'
require 'nlash.lazy_init'
require 'nlash.health'
require 'nlash.util'
-- [[ Basic Autocommands ]]
--  See `:help lua-guide-autocommands`

-- Highlight when yanking (copying) text
--  Try it with `yap` in normal mode
--  See `:help vim.highlight.on_yank()`
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end,
})

vim.api.nvim_create_autocmd({ 'BufRead', 'BufNewFile' }, {
  pattern = { '*.podspec', 'Podfile' },
  command = 'set filetype=ruby',
})

vim.api.nvim_create_autocmd({ 'BufRead', 'BufNewFile' }, {
  pattern = { 'Podfile.lock' },
  command = 'set filetype=yaml',
})

vim.api.nvim_create_user_command('MessagesToBuffer', function()
  require('nlash.util').messagesToBuffer()
end, {
  desc = 'Show messages in a new buffer',
})

vim.api.nvim_create_user_command('BufOnly', function()
  vim.cmd "silent! execute '%bd|e#|bd#'"
end, {
  desc = 'Close all buffers except the current one (silent)',
})
