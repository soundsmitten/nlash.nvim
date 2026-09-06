return {
  { -- Highlight, edit, and navigate code
    -- NOTE: `main` is a full, incompatible rewrite of nvim-treesitter.
    -- There is no `nvim-treesitter.configs`/`opts` table anymore; everything
    -- (install, highlight, indent, fold) is wired up manually below.
    -- https://github.com/nvim-treesitter/nvim-treesitter (main branch README)
    'nvim-treesitter/nvim-treesitter',
    branch = 'main',
    build = ':TSUpdate',
    lazy = false,
    priority = 1000,
    dependencies = {
      { 'nvim-treesitter/nvim-treesitter-textobjects', branch = 'main' },
    },
    config = function()
      local ts = require 'nvim-treesitter'

      -- Parsers we always want available, regardless of filetype auto-install below.
      local ensure_installed = { 'asm', 'bash', 'c', 'go', 'vim', 'vimdoc', 'diff', 'lua', 'luadoc' }
      local installed = ts.get_installed 'parsers'
      local missing = vim.tbl_filter(function(lang)
        return not vim.list_contains(installed, lang)
      end, ensure_installed)
      if #missing > 0 then
        ts.install(missing)
      end

      -- Textobjects enabled for plugin consumption (no keymaps).
      require('nvim-treesitter-textobjects').setup {
        select = { lookahead = false },
        move = { set_jumps = false },
      }

      -- Filetypes to skip highlighting for.
      local highlight_disabled = {
        swift = true, -- too expensive
        -- markdown = true,
        -- markdown_inline = true,
        -- md = true,
        -- json = true,
        -- html = true,
      }

      local indent_disabled = {
        ruby = true,
        swift = true,
      }

      -- Best-effort replacement for the old `auto_install = true` option: if a
      -- parser is available upstream but not installed yet, kick off an async
      -- install so it's ready next time the filetype is opened.
      local function try_auto_install(lang)
        if vim.list_contains(ts.get_installed 'parsers', lang) then
          return
        end
        if vim.list_contains(ts.get_available(), lang) then
          ts.install(lang)
        end
      end

      vim.api.nvim_create_autocmd('FileType', {
        group = vim.api.nvim_create_augroup('nlash-treesitter', { clear = true }),
        callback = function(ev)
          local ft = vim.bo[ev.buf].filetype

          local lang = vim.treesitter.language.get_lang(ft) or ft

          if not highlight_disabled[ft] then
            local ok = pcall(vim.treesitter.start, ev.buf, lang)
            if not ok then
              try_auto_install(lang)
            end
          else
            try_auto_install(lang)
          end

          -- Old config additionally layered vim regex highlighting on top for ruby.
          if ft == 'ruby' then
            vim.bo[ev.buf].syntax = 'on'
          end

          if not indent_disabled[ft] then
            vim.bo[ev.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
          end
        end,
      })
    end,
  },
}
