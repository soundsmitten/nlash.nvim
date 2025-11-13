-- return { -- You can easily change to a different colorscheme.
--   -- Change the name of the colorscheme plugin below, and then
--   -- change the command in the config to whatever the name of that colorscheme is.
--   --
--   -- If you want to see what colorschemes are already installed, you can use `:Telescope colorscheme`.
--   "idr4n/github-monochrome.nvim",
--   priority = 1000, -- Make sure to load this before all the other start plugins.
--   opts = {
--     transparent = true,
--   },
--   init = function()
--     -- Load the colorscheme here.
--     -- Like many other themes, this one has different styles, and you could load
--     -- any other, such as 'tokyonight-storm', 'tokyonight-moon', or 'tokyonight-day'.
--     vim.cmd.colorscheme 'github-monochrome-tokyonight'
--
--     -- You can configure highlights by doing something like:
--     -- vim.cmd.hi 'Comment gui=none'
--   end,
-- }
return {
  'svin24/accent.nvim',
  config = function()
    require('accent').setup {
      -- color to use, removing this line uses a random accent color
      accent_color = 'orange',
      --      custom_accent = {
      --        fg = '#FF0000', -- Hex foreground
      --        bg = '#AA0000', -- Hex background
      --        ctermfg = 196, -- Terminal foreground
      --        ctermbg = 124, -- Terminal background
      --      },


      -- makes the background and some text colours darker.
      accent_darken = false,

      -- inverts the colour of the status line text.
      invert_status = false,

      -- sets the accent colour using a hash of the current directory
      auto_cwd_color = false,

      -- stops the background colour being set, which will use the terminal default
      no_bg = true,
    }
    vim.cmd.colorscheme 'accent'
  end,
}
