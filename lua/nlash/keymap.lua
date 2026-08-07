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

-- util.uniqueKeymap('n', '<C-S-l>', '<C-w><', { desc = 'Decrease window width' })
-- util.uniqueKeymap('n', '<C-S-h>', '<C-w>>', { desc = 'Increase window width' })
-- util.uniqueKeymap('n', '<C-S-k>', '<C-w>-', { desc = 'Decrease window height' })
-- util.uniqueKeymap('n', '<C-S-j>', '<C-w>+', { desc = 'Increase window height' })
--
local function nav(wincmd, dir)
  local prev = vim.api.nvim_get_current_win()
  vim.cmd("wincmd " .. wincmd)
  if vim.api.nvim_get_current_win() ~= prev then
    return -- moved within Neovim
  end
  -- At a split edge: cross into the surrounding multiplexer.
  if vim.env.HERDR_PANE_ID and vim.env.HERDR_PANE_ID ~= "" then
    local herdr = vim.env.HERDR_BIN_PATH
    if herdr == nil or herdr == "" then
      herdr = "herdr"
    end
    -- Target this pane explicitly: `--current` resolves to the server's
    -- globally focused pane, which is not necessarily the one we are in.
    vim.fn.system({ herdr, "pane", "focus", "--direction", dir, "--pane", vim.env.HERDR_PANE_ID })
  elseif vim.env.TMUX and vim.env.TMUX ~= "" then
    local tmux = { left = "Left", down = "Down", up = "Up", right = "Right" }
    pcall(vim.cmd, "TmuxNavigate" .. tmux[dir])
  end
end

local function map(lhs, wincmd, dir, desc)
  vim.keymap.set("n", lhs, function()
    nav(wincmd, dir)
  end, { silent = true, noremap = true, desc = desc })
end

map("<C-h>", "h", "left", "Navigate left (vim/herdr)")
map("<C-j>", "j", "down", "Navigate down (vim/herdr)")
map("<C-k>", "k", "up", "Navigate up (vim/herdr)")
map("<C-l>", "l", "right", "Navigate right (vim/herdr)")

util.uniqueKeymap('t', '<C-l>', '<C-\\><C-n><C-w>l', { desc = 'Change window to right (terminal)' })
util.uniqueKeymap('t', '<C-h>', '<C-\\><C-n><C-w>h', { desc = 'Change window to left (terminal)' })
util.uniqueKeymap('t', '<C-j>', '<C-\\><C-n><C-w>j', { desc = 'Change window to bottom (terminal)' })
util.uniqueKeymap('t', '<C-k>', '<C-\\><C-n><C-w>k', { desc = 'Change window to top (terminal)' })
util.uniqueKeymap('t', '<M-l>', function()
  if vim.b.terminal_job_id ~= nil then
    local ctrlL = vim.api.nvim_replace_termcodes('<C-l>', true, false, true)
    vim.api.nvim_chan_send(vim.b.terminal_job_id, ctrlL)
  end
end, { desc = 'Clear terminal' })

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
-- terminal
util.uniqueKeymap('t', '<C-x>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })
util.uniqueKeymap('t', '<C-0>', '<C-\\><C-n><cmd>bd!<CR>', { desc = 'Kill terminal buffer' })

vim.api.nvim_create_user_command('TermRaw', function(opts)
  if opts.args ~= '' then
    vim.cmd('terminal ' .. opts.args)
  else
    vim.cmd 'terminal'
  end

  local buffer = vim.api.nvim_get_current_buf()
  for _, key in ipairs({ '<C-h>', '<C-j>', '<C-k>', '<C-l>' }) do
    keymap.set('t', key, key, { buffer = buffer, silent = true })
  end
end, { nargs = '*', complete = 'shellcmd', desc = 'Open passthrough terminal' })

vim.cmd [[cnoreabbrev <expr> termraw (getcmdtype() == ':' && getcmdline() ==# 'termraw' ? 'TermRaw' : 'termraw')]]

-- Disable Neovim's built-in commenting (0.10+)
vim.keymap.del('n', 'gcc')
vim.keymap.del('n', 'gc')
vim.keymap.del('x', 'gc')
vim.keymap.del('o', 'gc')

-- Open current file in Marked.app
util.uniqueKeymap('n', '<leader>mo', function()
  local path = vim.fn.expand '%:p'
  vim.fn.jobstart({ 'open', '-a', '/Applications/Setapp/Marked.app', path }, { detach = true })
end, { desc = 'Open in Marked.app' })

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

-- Arglist management (harpoon-style)
util.uniqueKeymap('n', '<leader>ha', function()
  vim.cmd 'argadd %'
  vim.notify('Added ' .. vim.fn.expand '%:t' .. ' to arglist')
end, { desc = 'Add current file to arglist' })

util.uniqueKeymap('n', '<leader>hd', function()
  local filename = vim.fn.expand '%:t'
  vim.cmd 'argdel %'
  vim.notify('Removed ' .. filename .. ' from arglist')
end, { desc = 'Remove current file from arglist' })

util.uniqueKeymap('n', '<leader>hc', function()
  vim.cmd 'argd *'
  vim.notify 'Cleared arglist'
end, { desc = 'Clear arglist' })

for i = 1, 5 do
  util.uniqueKeymap('n', '<C-' .. i .. '>', function()
    -- silent fallback if the index doesn't exist
    local ok = pcall(function()
      vim.cmd('argument ' .. i)
    end)
    if not ok then
      vim.notify('No arglist entry ' .. i, vim.log.levels.WARN)
    end
  end, { desc = 'Jump to arglist entry ' .. i })
end
