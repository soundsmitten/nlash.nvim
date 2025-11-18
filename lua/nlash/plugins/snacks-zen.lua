return {
  "folke/snacks.nvim",
  opts = {
    zen = { enabled = true },
  },
  keys = {
    {
      "<leader>zz",
      function()
        Snacks.zen()
      end,
      desc = "Toggle Zen Mode",
    },
  },
}
