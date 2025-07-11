-- Collection of various small independent plugins/modules
return {
  'echasnovski/mini.nvim',
  event = 'VeryLazy',
  config = function()
    -- Better Around/Inside textobjects
    --
    -- Examples:
    --  - va)  - [V]isually select [A]round [)]paren
    --  - yinq - [Y]ank [I]nside [N]ext [']quote
    --  - ci'  - [C]hange [I]nside [']quote
    require('mini.ai').setup { n_lines = 500 }

    -- require('mini.pairs').setup {
    --   modes = { insert = true, command = false, terminal = false },
    --   -- skip autopair when next character is one of these
    --   skip_next = [=[[%w%%%'%[%"%.%`%$]]=],
    --   -- skip autopair when the cursor is inside these treesitter nodes
    --   skip_ts = { 'string' },
    --   -- skip autopair when next character is closing pair
    --   -- and there are more closing pairs than opening pairs
    --   skip_unbalanced = true,
    --   -- better deal with markdown code blocks
    --   markdown = true,
    -- }

    -- Add/delete/replace surroundings (brackets, quotes, etc.)
    --
    -- - saiw) - [S]urround [A]dd [I]nner [W]ord [)]Paren
    -- - sd'   - [S]urround [D]elete [']quotes
    -- - sr)'  - [S]urround [R]eplace [)] [']
    require('mini.surround').setup()

    -- navigation with [ ]
    require('mini.bracketed').setup {
      window = { suffix = '' },
    }

    -- improved F, f, t, T commands.
    -- require('mini.jump').setup {
    --   mappings = {
    --     repeat_jmp = '',
    --   },
    -- }

    -- split and join args
    require('mini.splitjoin').setup()

    -- Simple and easy statusline.
    --  You could remove this setup call if you don't like it,
    --  and try some other statusline plugin
    local statusline = require 'mini.statusline'
    -- set use_icons to true if you have a Nerd Font
    statusline.setup { use_icons = vim.g.have_nerd_font }

    -- You can configure sections in the statusline by overriding their
    -- default behavior. For example, here we set the section for
    -- cursor location to LINE:COLUMN
    ---@diagnostic disable-next-line: duplicate-set-field
    statusline.section_location = function()
      return '%2l:%-2v'
    end

    require("mini.move").setup()

    -- ... and there is more!
    --  Check out: https://github.com/echasnovski/mini.nvim
  end,
}
