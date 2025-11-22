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

M.safeKeymapDel = function(mode, lhs)
  pcall(vim.keymap.del, mode, lhs)
end

M.messagesToBuffer = function()
  local messages = vim.fn.execute('messages')
  local bufnr = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, vim.split(messages, '\n'))
  vim.api.nvim_win_set_buf(0, bufnr)
  vim.bo[bufnr].buftype = 'nofile'
  vim.bo[bufnr].filetype = 'messages'
end

return M
