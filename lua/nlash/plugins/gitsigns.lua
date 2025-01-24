return { -- Adds git related signs to the gutter, as well as utilities for managing changes
  'lewis6991/gitsigns.nvim',
  config = function()
    require('gitsigns').setup {
      signs = {
        add = { text = '+' },
        change = { text = '~' },
        delete = { text = '_' },
        topdelete = { text = '‾' },
        changedelete = { text = '~' },
      },
      signs_staged = {
        add = { text = '▒' },
        change = { text = '▒' },
        delete = { text = '▒' },
        topdelete = { text = '▒' },
        changedelete = { text = '▒' },
      },

      -- Keymaps are based on mini.diff's defaults for nav and staging actions.
      on_attach = function(bufnr)
        local function map(mode, l, r, opts)
          opts = opts or {}
          opts.buffer = bufnr
          vim.keymap.set(mode, l, r, opts)
        end
        local gitsigns = require 'gitsigns'

        -- Navigation

        map('n', '[H', function()
          if vim.wo.diff then
            vim.cmd.normal { '[c', bang = true }
          else
            gitsigns.nav_hunk 'prev'
          end
        end, { desc = 'Navigate to first hunk' })

        map('n', '[h', function()
          if vim.wo.diff then
            vim.cmd.normal { '[c', bang = true }
          else
            gitsigns.nav_hunk 'prev'
          end
        end, { desc = 'Navigate to previous hunk' })

        map('n', ']h', function()
          if vim.wo.diff then
            vim.cmd.normal { ']c', bang = true }
          else
            gitsigns.nav_hunk 'next'
          end
        end, { desc = 'Navigate to next hunk' })

        map('n', ']H', function()
          if vim.wo.diff then
            vim.cmd.normal { ']c', bang = true }
          else
            gitsigns.nav_hunk 'next'
          end
        end, { desc = 'Navigate to last hunk' })

        -- Actions

        map('n', 'gh', gitsigns.stage_hunk, { desc = 'Stage hunk' })
        map('n', 'gH', gitsigns.reset_hunk, { desc = 'Reset hunk' })

        map('v', 'gh', function()
          gitsigns.stage_hunk { vim.fn.line '.', vim.fn.line 'v' }
        end, { desc = 'Stage hunk' })

        map('v', 'gH', function()
          gitsigns.reset_hunk { vim.fn.line '.', vim.fn.line 'v' }
        end, { desc = 'Reset hunk' })

        -- map('n', '<leader>gb', gitsigns.stage_buffer)
        -- map('n', '<leader>gB', gitsigns.reset_buffer)
        map('n', '<leader>hp', gitsigns.preview_hunk, { desc = 'Preview hunk' })
        map('n', '<leader>hi', gitsigns.preview_hunk_inline, { desc = 'Preview hunk inline' })

        map('n', '<leader>hQ', function()
          gitsigns.setqflist 'all'
        end, { desc = 'Quickfix list all hunks' })

        map('n', '<leader>hq', gitsigns.setqflist, { desc = 'Quickfix list hunk' })

        -- Toggles
        map('n', '<leader>tb', gitsigns.toggle_current_line_blame)
        map('n', '<leader>tw', gitsigns.toggle_word_diff)

        -- Text object
        map({ 'o', 'x' }, 'gh', ':<C-U>Gitsigns select_hunk<CR>')
      end,
    }
  end,
}
