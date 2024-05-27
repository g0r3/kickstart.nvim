return {
  'rcarriga/nvim-dap-ui',
  dependencies = {
    'mfussenegger/nvim-dap',
    'nvim-neotest/nvim-nio',
    'folke/neodev.nvim',
  },
  config = function()
    require('neodev').setup {
      library = { plugins = { 'nvim-dap-ui' }, types = true },
    }
    require('dapui').setup()
  end,
  keys = {
    {
      mode = 'n',
      '<F7>',
      function()
        require('dapui').toggle()
      end,
      desc = 'Debug: See last session result.',
    },
  },
}
