return {
  'leoluz/nvim-dap-go',
  dependencies = {
    'mfussenegger/nvim-dap',
    'rcarriga/nvim-dap-ui',
  },
  config = function()
    require('dap-go').setup {
      delve = {
        build_flags = '-tags=dynamic',
      },
    }
  end,
}
