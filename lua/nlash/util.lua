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

return M
