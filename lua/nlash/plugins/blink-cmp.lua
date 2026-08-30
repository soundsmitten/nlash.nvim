return { -- Autocompletion
  'saghen/blink.cmp',
  event = 'InsertEnter',
  version = '1.*',
  dependencies = {
    -- Snippet Engine
    -- 'L3MON4D3/LuaSnip',

    'onsails/lspkind.nvim', -- vs-code like pictograms
    'folke/lazydev.nvim',
    'fang2hou/blink-copilot',
    'soundsmitten/strudel-blink-cmp.nvim',
  },

  --- @module 'blink.cmp'
  --- @type blink.cmp.Config
  opts = {
    keymap = {
      -- 'default' (recommended) for mappings similar to built-in completions
      --   <c-y> to accept ([y]es) the completion.
      --    This will auto-import if your LSP supports it.
      --    This will expand snippets if the LSP sent a snippet.
      -- 'super-tab' for tab to accept
      -- 'enter' for enter to accept
      -- 'none' for no mappings
      --
      -- For an understanding of why the 'default' preset is recommended,
      -- you will need to read `:help ins-completion`
      --
      -- No, but seriously. Please read `:help ins-completion`, it is really good!
      --
      -- All presets have the following mappings:
      -- <tab>/<s-tab>: move to right/left of your snippet expansion
      -- <c-space>: Open menu or open docs if already open
      -- <c-n>/<c-p> or <up>/<down>: Select next/previous item
      -- <c-e>: Hide menu
      -- <c-k>: Toggle signature help
      --
      -- See :h blink-cmp-config-keymap for defining your own keymap
      -- preset = 'default',

      ['<C-g>'] = { 'select_and_accept' },
      ['<C-y>'] = {},

      -- Tab for snippet navigation with fallback to normal behavior
      ['<Tab>'] = { 'snippet_forward', 'fallback' },
      ['<S-Tab>'] = { 'snippet_backward', 'fallback' },

      -- For more advanced Luasnip keymaps (e.g. selecting choice nodes, expansion) see:
      --    https://github.com/L3MON4D3/LuaSnip?tab=readme-ov-file#keymaps
    },

    appearance = {
      -- 'mono' (default) for 'Nerd Font Mono' or 'normal' for 'Nerd Font'
      -- Adjusts spacing to ensure icons are aligned
      nerd_font_variant = 'mono',
    },

    completion = {
      -- Press `<c-space>` to show the documentation manually.
      -- Scroll docs with <C-b> (up) and <C-f> (down)
      documentation = {
        auto_show = false,
        auto_show_delay_ms = 500,
        window = {
          max_width = 80,
          max_height = 20,
          scrollbar = true, -- Show scrollbar for long docs
        },
      },
    },

    sources = {
      default = { 'lsp', 'buffer', 'path', 'snippets', 'lazydev', 'copilot', 'strudel' }, -- removed 'snippets' for performance.
      providers = {
        copilot = {
          name = 'copilot',
          module = 'blink-copilot',
          score_offset = 90,
          async = true,
        },
        lazydev = { module = 'lazydev.integrations.blink', score_offset = 100 },
        strudel = {
          name = 'strudel',
          module = 'strudel-blink-cmp.source',
          score_offset = 90, -- High priority, below copilot but above LSP
        },
        snippets = {
          score_offset = -30,
        },
      },
    },

    snippets = { preset = 'mini_snippets' },

    -- Blink.cmp includes an optional, recommended rust fuzzy matcher,
    -- which automatically downloads a prebuilt binary when enabled.
    --
    -- By default, we use the Lua implementation instead, but you may enable
    -- the rust implementation via `'prefer_rust_with_warning'`
    --
    -- See :h blink-cmp-config-fuzzy for more information
    fuzzy = { implementation = 'prefer_rust_with_warning' },

    -- Shows a signature help window while you type arguments for a function
    signature = { enabled = true },
  },
}
