return {

  { -- Linting
    'mfussenegger/nvim-lint',
    event = { 'BufReadPost', 'BufWritePost', 'BufNewFile' },
    config = function()
      local lint = require 'lint'
      lint.linters_by_ft = {
        -- the markdown linter is super obnoxious.
        -- markdown = { 'markdownlint' },
        swift = { 'swiftlint' },
        go = { 'golangcilint' },
      }

      -- To allow other plugins to add linters to require('lint').linters_by_ft,
      -- instead set linters_by_ft like this:
      -- lint.linters_by_ft = lint.linters_by_ft or {}
      -- lint.linters_by_ft['markdown'] = { 'markdownlint' }
      --
      -- However, note that this will enable a set of default linters,
      -- which will cause errors unless these tools are available:
      -- {
      --   clojure = { "clj-kondo" },
      --   dockerfile = { "hadolint" },
      --   inko = { "inko" },
      --   janet = { "janet" },
      --   json = { "jsonlint" },
      --   markdown = { "vale" },
      --   rst = { "vale" },
      --   ruby = { "ruby" },
      --   terraform = { "tflint" },
      --   text = { "vale" }
      -- }
      --
      -- You can disable the default linters by setting their filetypes to nil:
      -- lint.linters_by_ft['clojure'] = nil
      -- lint.linters_by_ft['dockerfile'] = nil
      -- lint.linters_by_ft['inko'] = nil
      -- lint.linters_by_ft['janet'] = nil
      -- lint.linters_by_ft['json'] = nil
      -- lint.linters_by_ft['markdown'] = nil
      -- lint.linters_by_ft['rst'] = nil
      -- lint.linters_by_ft['ruby'] = nil
      -- lint.linters_by_ft['terraform'] = nil
      -- lint.linters_by_ft['text'] = nil

      -- SwiftLint is comparatively expensive, so run it only when a Swift file
      -- is opened or saved. Keep the more eager behavior for other linters.
      local lint_augroup = vim.api.nvim_create_augroup('lint', { clear = true })
      vim.api.nvim_create_autocmd({ 'BufReadPost', 'BufWritePost' }, {
        group = lint_augroup,
        pattern = '*.swift',
        callback = function()
          lint.try_lint 'swiftlint'
        end,
      })

      vim.api.nvim_create_autocmd({ 'BufEnter', 'BufWritePost', 'BufReadPost', 'InsertLeave', 'TextChanged' }, {
        group = lint_augroup,
        callback = function()
          if vim.bo.filetype ~= 'swift' then
            lint.try_lint()
          end
        end,
      })

      vim.keymap.set('n', '<leader>ml', function()
        require('lint').try_lint()
      end, { desc = 'Lint file' })
    end,
  },
}
