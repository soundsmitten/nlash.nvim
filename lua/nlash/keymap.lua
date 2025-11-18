local util = require 'nlash.util'
local keymap = vim.keymap

-- See `:help mapleader`
--  NOTE: Must happen before plugins are loaded (otherwise wrong leader will be used)
vim.g.mapleader = ' '
vim.g.maplocalleader = ','

-- Set to true if you have a Nerd Font installed and selected in the terminal
vim.g.have_nerd_font = true

-- clear highlight on esc.
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

-- disable updating register for x
vim.keymap.set('n', 'x', '"_x')

vim.keymap.del('n', '<C-l>')
util.uniqueKeymap('n', '<C-l>', '<C-w>l', { desc = 'Change window to right'} )
util.uniqueKeymap('n', '<C-h>', '<C-w>h', { desc = 'Change window to left' })
util.uniqueKeymap('n', '<C-j>', '<C-w>j', { desc = 'Change window to bottom' })
util.uniqueKeymap('n', '<C-k>', '<C-w>k', { desc = 'Change window to top' })
util.uniqueKeymap('n', '<C-x>', '<cmd>close<CR>', { desc = 'Close current split' })

-- tabs management
util.uniqueKeymap('n', '<leader>tn', '<cmd>tabnew<CR>', { desc = 'Open new tab' })
util.uniqueKeymap('n', '<leader>td', '<cmd>tabclose<CR>', { desc = 'Close current tab' })

-- buffers management
util.uniqueKeymap('n', '<leader>bn', '<cmd>new<CR>', { desc = 'New buffer' })
util.uniqueKeymap('n', '<leader>bd', '<cmd>bd<CR>', { desc = 'Close current buffer' })
util.uniqueKeymap('n', '<leader>bx', '<cmd>%bd|e#|bd#<CR>', { desc = 'Close all buffers but this' })

-- copy & paste
-- vim.keymap.set('x', 'p', '"_dP')
vim.keymap.set('x', 'Y', 'y$', { desc = 'Yank to end of line' })
vim.keymap.set('', '<leader>DD', '"_dd', { desc = 'Delete without changing register' })

-- scrolling
vim.keymap.set('n', '<C-d>', '<C-d>zz')
vim.keymap.set('n', '<C-u>', '<C-u>zz')

-- other
util.uniqueKeymap('n', '<leader>mm', '<cmd>messages<cr>', { desc = 'Show messages' })

-- terminal exit
util.uniqueKeymap('t', '<C-x>', '<C-\\><C-n>', { desc = 'Exit terminal' })

-- Disable Neovim's built-in commenting (0.10+)
vim.keymap.del('n', 'gcc')
vim.keymap.del('n', 'gc')
vim.keymap.del('x', 'gc')
vim.keymap.del('o', 'gc')
