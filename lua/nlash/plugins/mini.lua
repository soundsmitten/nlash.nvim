-- Collection of various small independent plugins/modules
return {
  'echasnovski/mini.nvim',
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
    -- - csaiw) - [S]urround [A]dd [I]nner [W]ord [)]Paren
    -- - csd'   - [S]urround [D]elete [']quotes
    -- - csr)'  - [S]urround [R]eplace [)] [']
    require('mini.surround').setup(
      -- No need to copy this inside `setup()`. Will be used automatically.
      {
        mappings = {
          add = 'csa', -- Add surrounding in Normal and Visual modes
          delete = 'csd', -- Delete surrounding
          find = 'csf', -- Find surrounding (to the right)
          find_left = 'csF', -- Find surrounding (to the left)
          highlight = 'csh', -- Highlight surrounding
          replace = 'csr', -- Replace surrounding

          suffix_last = 'l', -- Suffix to search with "prev" method
          suffix_next = 'n', -- Suffix to search with "next" method
        },
      }
    )

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

    require('mini.move').setup()

    require('mini.sessions').setup()

    -- Sessions
    local function setup_sessions()
      local sessions = require 'mini.sessions'

      -- Derive session name from current working directory
      local function session_name_from_cwd()
        local cwd = vim.loop.cwd()
        if not cwd or cwd == '' then
          return nil
        end
        -- Use the last path segment (project folder name)
        local name = vim.fn.fnamemodify(cwd, ':t')
        -- Normalize to safe filename (no spaces, simple chars)
        name = name:gsub('%s+', '_')
        return name ~= '' and name or nil
      end

      -- Fallback to prompt if cwd doesn't yield a useful name
      local function ensure_session_name()
        local name = session_name_from_cwd()
        if name then
          return name
        end
        return vim.fn.input 'Session name: '
      end

      -- Save (write) the session for this project
      vim.keymap.set('n', '<localleader>ss', function()
        local name = ensure_session_name()
        if name and name ~= '' then
          sessions.write(name)
          vim.notify('Session saved: ' .. name, vim.log.levels.INFO)
        else
          vim.notify('Session save cancelled (no name)', vim.log.levels.WARN)
        end
      end, { desc = 'Session: save (cwd)' })

      -- Load (read) the session for this project
      vim.keymap.set('n', '<localleader>sl', function()
        local name = ensure_session_name()
        if name and name ~= '' then
          sessions.read(name)
          vim.notify('Session loaded: ' .. name, vim.log.levels.INFO)
        else
          vim.notify('Session load cancelled (no name)', vim.log.levels.WARN)
        end
      end, { desc = 'Session: load (cwd)' })

      -- Delete the session for this project
      vim.keymap.set('n', '<localleader>sd', function()
        local name = ensure_session_name()
        if not name or name == '' then
          vim.notify('Session delete cancelled (no name)', vim.log.levels.WARN)
          return
        end
        local confirm = vim.fn.confirm("Delete session '" .. name .. "'?", '&Yes\n&No', 2)
        if confirm == 1 then
          sessions.delete(name)
          vim.notify('Session deleted: ' .. name, vim.log.levels.INFO)
        end
      end, { desc = 'Session: delete (cwd)' })

      -- Configure mini.sessions
      sessions.setup {
        directory = vim.fn.stdpath 'data' .. '/sessions',
        autoread = false, -- don't auto-load on start
        autowrite = true, -- auto-save on exit if a session is active
        force = { delete = true },
        -- verbose = true,
        hooks = {
          post = {
            read = function()
              vim.cmd 'NLXcodebuildRefresh'
            end,
          },
        },
      }

      local function snacks_session_picker()
        local names = require('mini.sessions').read_session_names()
        if #names == 0 then
          vim.notify('No sessions found', vim.log.levels.INFO)
          return nil
        end
        -- Use Snacks picker
        local Snacks = require 'snacks'
        local selected
        Snacks.picker({
          title = 'Sessions',
          items = names,
          -- Simple formatter shows the name directly
          format = function(item)
            return item
          end,
          -- on_confirm gets the picked item
          on_confirm = function(item)
            selected = item
          end,
        }):start()

        -- Snacks picker runs asynchronously; we need to wait until it sets `selected`
        -- A tiny loop yields until user confirms or picker closes.
        -- This keeps it simple without adding extra event wiring.
        vim.wait(30000, function()
          return selected ~= nil
        end, 20, false)
        return selected
      end

      -- Register the custom picker with mini.sessions
      sessions.config = vim.tbl_deep_extend('force', sessions.config, {
        -- mini.sessions uses `select()` which will call `config.selector`.
        selector = snacks_session_picker,
      })
    end
    setup_sessions()

    -- Starter screen
    require('mini.starter').setup {}
    -- ... and there is more!
    --  Check out: https://github.com/echasnovski/mini.nvim
  end,
}
