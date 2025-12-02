return {
  'folke/sidekick.nvim',
  opts = function()
    -- Load custom prompts from file
    local custom_prompts = {}
    local prompts_file = vim.fn.stdpath 'config' .. '/prompts.lua'
    if vim.fn.filereadable(prompts_file) == 1 then
      local ok, prompts = pcall(dofile, prompts_file)
      if ok and prompts then
        custom_prompts = prompts
      end
    end

    return {
      nes = { enabled = false }, -- disable Next Edit Suggestions
      cli = {
        prompts = custom_prompts,
        mux = {
          backend = 'zellij',
          enabled = true,
        },
      },
    }
  end,
  keys = {
    {
      '<c-.>',
      function()
        require('sidekick.cli').toggle()
      end,
      desc = 'Sidekick Toggle',
      mode = { 'n', 't', 'i', 'x' },
    },
    {
      '<leader>aa',
      function()
        require('sidekick.cli').toggle()
      end,
      desc = 'Sidekick Toggle CLI',
    },
    {
      '<leader>as',
      function()
        require('sidekick.cli').select()
      end,
      -- Or to select only installed tools:
      -- require("sidekick.cli").select({ filter = { installed = true } })
      desc = 'Select CLI',
    },
    {
      '<leader>ad',
      function()
        require('sidekick.cli').close()
      end,
      desc = 'Detach a CLI Session',
    },
    {
      '<leader>at',
      function()
        require('sidekick.cli').send { msg = '{this}' }
      end,
      mode = { 'x', 'n' },
      desc = 'Send This',
    },
    {
      '<leader>af',
      function()
        require('sidekick.cli').send { msg = '{file}' }
      end,
      desc = 'Send File',
    },
    {
      '<leader>av',
      function()
        require('sidekick.cli').send { msg = '{selection}' }
      end,
      mode = { 'x' },
      desc = 'Send Visual Selection',
    },
    {
      '<leader>ap',
      function()
        require('sidekick.cli').prompt()
      end,
      mode = { 'n', 'x' },
      desc = 'Sidekick Select Prompt',
    },
    -- Example of a keybinding to open Claude directly
    -- {
    --   "<leader>ac",
    --   function() require("sidekick.cli").toggle({ name = "claude", focus = true }) end,
    --   desc = "Sidekick Toggle Claude",
    -- },
  },
}
