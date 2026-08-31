-- local util = require 'nlash.util'

return {
  'stevearc/conform.nvim',
  tag = 'v8.3.0',
  event = { 'BufReadPre', 'BufNewFile' },
  config = function()
    local conform = require 'conform'

    conform.setup {
      formatters_by_ft = {
        lua = { 'stylua' },
        swift = { 'swiftformat' },
        cs = { 'csharpier' },
        go = { 'goimports' },
        javascript = { 'prettier' },
        javascriptreact = { 'prettier' },
        typescript = { 'prettier' },
        typescriptreact = { 'prettier' },
        kotlin = { 'ktlint' },
      },

      -- format_on_save = function(bufnr)
      --   if util.isWorkMachine() then
      --     return nil
      --   end
      --   local ft = vim.bo[bufnr].filetype
      --   local timeout = ft == 'kotlin' and 5000 or 500
      --   return { timeout_ms = timeout, lsp_fallback = true }
      -- end,

      log_level = vim.log.levels.ERROR,

      formatters = {
        swiftformat = {
          command = 'swiftformat',
          args = function(self, ctx)
            local args = { '--stdinpath', '$FILENAME' }
            local project_config = vim.fs.find({ '.swiftformat' }, { path = ctx.dirname, upward = true })[1]
            if not project_config then
              table.insert(args, 1, '~/.config/nvim/nlash.swiftformat')
              table.insert(args, 1, '--config')
            end
            return args
          end,
          stdin = true,
          condition = function(ctx)
            return vim.fs.basename(ctx.filename) ~= 'README.md'
          end,
        },
        golines = {
          command = 'golines',
          args = { '-w', '$FILENAME' },
          condition = function(ctx)
            return vim.fs.basename(ctx.filename) ~= 'README.md'
          end,
        },
        csharpier = {
          command = 'dotnet',
          args = { 'csharpier', '--fast', '--no-cache', '--write-stdout', '$FILENAME' },
          stdin = true,
          condition = function(ctx)
            return vim.fs.basename(ctx.filename) ~= 'README.md'
          end,
        },
      },
      vim.keymap.set({ 'n', 'v' }, '<leader>ff', function()
        local ft = vim.bo.filetype
        conform.format {
          lsp_fallback = true,
          async = false,
          timeout_ms = ft == 'kotlin' and 5000 or 500,
        }
      end, { desc = 'Format file or range (in visual mode)' }),
    }
  end,
}
