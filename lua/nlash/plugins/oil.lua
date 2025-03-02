local util = require 'nlash.util'

local function shell(cmd)
  local result
  local jobid = vim.fn.jobstart(cmd, {
    stdout_buffered = true,
    on_stdout = function(_, data, _)
      result = data
    end,
  })
  vim.fn.jobwait { jobid }

  return result or {}
end

return {
  {
    'stevearc/oil.nvim',
    opts = {},
    tag = 'v2.14.0',

    config = function()
      local detail = false
      local oil = require 'oil'
      oil.setup {
        win_options = {
          signcolumn = 'yes:2',
        },

        util.uniqueKeymap('n', '<leader>db', function()
          oil.open(nil)
        end),

        view_options = {
          show_hidden = false,
        },

        keymaps = {
          ['gd'] = {
            desc = 'Toggle file Detail view',

            callback = function()
              detail = not detail
              if detail then
                require('oil').set_columns { 'icon', 'permissions', 'size', 'mtime' }
              else
                require('oil').set_columns { 'icon' }
              end
            end,
          },

          ['gq'] = {
            desc = 'Open the entry under the cursor in Quick Look',
            callback = function()
              local entry = oil.get_cursor_entry()
              local dir = oil.get_current_dir()
              if not entry or not dir then
                return
              end
              local path = dir .. entry.name
              local command = { 'qlmanage', '-p', path }
              local jid = vim.fn.jobstart(command, {
                detach = true,
              })

              -- HACK: the preview stays behind the terminal window
              -- when Neovim is running in tmux or zellij.
              if vim.env.TERM_PROGRAM == 'tmux' or vim.env.ZELLIJ_PANE_ID then
                vim.defer_fn(function()
                  shell 'open -a qlmanage'
                end, 100)
              end

              assert(jid > 0, 'Failed to start job')
            end,
          },
          ['<C-h>'] = false, -- { 'actions.select', opts = { horizontal = true } },
          ['<C-t>'] = false, -- { 'actions.select', opts = { tab = true } },
          ['<C-p>'] = 'actions.preview',
          ['<C-c>'] = false, -- { 'actions.close', mode = 'n' },
          ['<C-l>'] = false, -- 'actions.refresh',
          ['gl'] = 'actions.refresh',
        },
      }
    end,

    -- Optional dependencies
    dependencies = { 'nvim-tree/nvim-web-devicons' },
  },
  {
    'refractalize/oil-git-status.nvim',
    dependencies = {
      'stevearc/oil.nvim',
    },
    config = true,
  },
}
