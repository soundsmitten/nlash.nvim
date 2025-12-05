-- Custom prompts for sidekick.nvim
return {
  -- defaults
  changes = 'Can you review my changes?',
  diagnostics = 'Can you help me fix the diagnostics in {file}?\n{diagnostics}',
  diagnostics_all = 'Can you help me fix these diagnostics?\n{diagnostics_all}',
  document = 'Add documentation to {function|line}',
  explain = 'Explain {this}',
  fix = 'Can you fix {this}?',
  optimize = 'How can {this} be optimized?',
  review = 'Can you review {file} for any issues or improvements?',
  tests = 'Can you write tests for {this}?',

  pr = "Compare my changes to the main branch and help me submit a PR via gh CLI. I have already pushed the branch to my fork, DO NOT push code. Please pull request template inside of the .github directory, if available. If there are checkboxes when using the template, check them all",
  commit = 'Help me write a commit based on staged changes. Please use git commit guidelines inside of the .github directory, if available.',

  -- context prompts
  buffers = '{buffers}',
  file = '{file}',
  line = '{line}',
  position = '{position}',
  quickfix = '{quickfix}',
  selection = '{selection}',
  ['function'] = '{function}',
  class = '{class}',
  arglist = function()
    local files = {}

    for i = 0, vim.fn.argc() - 1 do
      local file = vim.fn.argv(i)
      if file and file ~= '' and file ~= '.' then
        -- Make path relative to cwd
        local relative_path = vim.fn.fnamemodify(file, ':.')
        table.insert(files, '@' .. relative_path)
      end
    end

    return table.concat(files, ' ')
  end,
}
