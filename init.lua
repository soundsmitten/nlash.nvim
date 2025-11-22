require('nlash')

vim.api.nvim_create_user_command('MessagesToBuffer', function()
  require('nlash.util').messagesToBuffer()
end, {})
