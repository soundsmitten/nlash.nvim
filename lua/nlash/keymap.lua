-- See `:help mapleader`
--  NOTE: Must happen before plugins are loaded (otherwise wrong leader will be used)
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Set to true if you have a Nerd Font installed and selected in the terminal
vim.g.have_nerd_font = true

-- clear highlight on esc.
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

-- Diagnostic keymaps
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = 'Go to previous [D]iagnostic message' })
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = 'Go to next [D]iagnostic message' })
vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, { desc = 'Show diagnostic [E]rror messages' })

local function run_go_program()
  local job_id = vim.fn.jobstart('go run .', {
    on_exit = function(_, exit_code)
      print('Go program exited with code: ' .. exit_code)
    end,
    on_stdout = function(_, data)
      print('Output: ' .. vim.inspect(data))
    end,
    on_stderr = function(_, data)
      print('Error: ' .. vim.inspect(data))
    end,
  })

  if job_id == 0 then
    print 'Failed to start job'
  elseif job_id == -1 then
    print 'Invalid arguments'
  else
    print('Go program started with job ID: ' .. job_id)
  end
end

vim.keymap.set('n', '<leader>gr', run_go_program, { desc = 'Run Go program' })
