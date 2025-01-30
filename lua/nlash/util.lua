local M = {}

-- https://nanotipsforvim.prose.sh/prevent-duplicate-keybindings
M.uniqueKeymap = function(modes, lhs, rhs, opts)
  if not opts then
    opts = {}
  end
  if opts.unique == nil then
    opts.unique = true
  end
  vim.keymap.set(modes, lhs, rhs, opts)
end

M.runGoProgram = function()
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

return M
