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
      ensure_installed = { "asm", "bash", "c", "go", "vim", "vimdoc", "diff", "lua", "luadoc" },
      auto_install = true,
      ignore_install = { "markdown", "markdown_inline" },
      highlight = {
        enable = true,
        disable = { "swift", "markdown", "markdown_inline", "md", "json", "html" }, -- swift is too expensive
        additional_vim_regex_highlighting = { "ruby" },
      },
      indent = { enable = true, disable = { "ruby", "swift" } },

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
      vim.api.nvim_create_autocmd("FileType", {
        pattern = { "markdown", "mdx", "markdown.mdx" },
        callback = function(ev)
          vim.treesitter.stop(ev.buf)
        end,
      })
    end,
  },
}
