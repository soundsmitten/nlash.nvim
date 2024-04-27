return {
    "stevearc/conform.nvim",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
    local conform = require("conform")
    
    conform.setup({
      formatters_by_ft = {
        lua = { 'stylua' },
        swift = { "swiftformat", },
      },
      format_on_save = false,
      --      format_on_save = function()
      --        return { timeout_ms = 500, lsp_fallback = true }
      --      end,
      log_level = vim.log.levels.ERROR,
      
      formatters = {
        swiftformat = {
          command = "swiftformat",
          args = { "--config", "~/.config/nvim/nlash.swiftformat", "--stdinpath", "$FILENAME" },
          stdin = true,
          condition = function(ctx)
          return vim.fs.basename(ctx.filename) ~= "README.md"
          end
        },
      },
      vim.keymap.set({ "n", "v" }, "<leader>ff", function()
        conform.format({
          lsp_fallback = true,
          async = false,
          timeout_ms = 500,
        })
        end, { desc = "Format file or range (in visual mode)" })
    })
    end,
  }

