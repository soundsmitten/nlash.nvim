return {
  'github/copilot.vim',
  cmd = 'Copilot',
  event = 'BufWinEnter',
  init = function()
    -- Disable all copilot.vim keymaps; Blink handles acceptance/select.
    vim.g.copilot_no_maps = true
  end,
  config = function()
    -- Disable native copilot.vim ghost text while keeping the LSP provider active.
    vim.api.nvim_create_augroup('github_copilot', { clear = true })
    vim.api.nvim_create_autocmd({ 'FileType', 'BufUnload' }, {
      group = 'github_copilot',
      callback = function(args)
        vim.fn['copilot#On' .. args.event]()
      end,
    })
    vim.fn['copilot#OnFileType']()
  end,
}
