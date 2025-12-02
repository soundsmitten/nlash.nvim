return {
  { -- Highlight, edit, and navigate code
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    lazy = false,
    priority = 1000,
    dependencies = {
      { "nvim-treesitter/nvim-treesitter-textobjects", branch = "main" },
    },
    opts = {
      ensure_installed = { "asm", "bash", "c", "go", "swift", "html", "lua", "luadoc", "markdown", "vim", "vimdoc", "diff" },
      auto_install = true,
      highlight = {
        enable = true,
        disable = { "swift" },
        additional_vim_regex_highlighting = { "ruby" },
      },
      indent = { enable = true, disable = { "ruby" } },

      -- Textobjects enabled for plugin consumption (no keymaps)
      textobjects = {
        select = {
          enable = true,
          lookahead = false,
          -- no keymaps
        },
        move = {
          enable = true,
          set_jumps = false,
          -- no keymaps
        },
        swap = { enable = false },
        lsp_interop = { enable = false },
      },
    },
    config = function(_, opts)
      require("nvim-treesitter.install").prefer_git = true
      require("nvim-treesitter.configs").setup(opts)
    end,
  },
}
