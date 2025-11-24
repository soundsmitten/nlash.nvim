local util = require 'nlash.util'
local keymap = vim.keymap

-- See `:help mapleader`
--  NOTE: Must happen before plugins are loaded (otherwise wrong leader will be used)
vim.g.mapleader = ' '
vim.g.maplocalleader = '\\'

-- Set to true if you have a Nerd Font installed and selected in the terminal
vim.g.have_nerd_font = true

-- clear highlight on esc.
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

-- disable updating register for x
vim.keymap.set('n', 'x', '"_x')

-- Window management
vim.keymap.del('n', '<C-l>')
util.uniqueKeymap('n', '<C-l>', '<C-w>l', { desc = 'Change window to right' })
util.uniqueKeymap('n', '<C-h>', '<C-w>h', { desc = 'Change window to left' })
util.uniqueKeymap('n', '<C-j>', '<C-w>j', { desc = 'Change window to bottom' })
util.uniqueKeymap('n', '<C-k>', '<C-w>k', { desc = 'Change window to top' })

util.uniqueKeymap('n', '<C-S-l>', '<C-w><', { desc = 'Decrease window width' })
util.uniqueKeymap('n', '<C-S-h>', '<C-w>>', { desc = 'Increase window width' })
util.uniqueKeymap('n', '<C-S-k>', '<C-w>-', { desc = 'Decrease window height' })
util.uniqueKeymap('n', '<C-S-j>', '<C-w>+', { desc = 'Increase window height' })

-- copy & paste
vim.keymap.set('x', 'Y', 'y$', { desc = 'Yank to end of line' })

-- scrolling
vim.keymap.set('n', '<C-d>', '<C-d>zz')
vim.keymap.set('n', '<C-u>', '<C-u>zz')

-- Ctrl+Shift+hjkl for resizing 

-- other
util.uniqueKeymap('n', '<leader>mm', '<cmd>messages<cr>', { desc = 'Show messages' })

-- Fugitive
util.uniqueKeymap('n', '<leader>gg', '<cmd>vertical Git<cr>', { desc = '🔀 Fugitive' })
util.uniqueKeymap('n', '<leader>gG', '<cmd>tabnew|Git|only<cr>', {
  silent = true,
  desc = '🔀 Fugitive (new tab)',
})
-- terminal exi't
util.uniqueKeymap('t', '<C-x>', '<C-\\><C-n>', { desc = 'Exit terminal' })

-- Disable Neovim's built-in commenting (0.10+)
vim.keymap.del('n', 'gcc')
vim.keymap.del('n', 'gc')
vim.keymap.del('x', 'gc')
vim.keymap.del('o', 'gc')

-- Folding keymaps
util.uniqueKeymap('n', '<leader>f1', function()
  vim.opt.foldlevel = 0
end, { desc = 'Fold: Level 1' })
util.uniqueKeymap('n', '<leader>f2', function()
  vim.opt.foldlevel = 1
end, { desc = 'Fold: Level 2' })
util.uniqueKeymap('n', '<leader>f3', function()
  vim.opt.foldlevel = 2
end, { desc = 'Fold: Level 3' })
