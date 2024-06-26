-- https://github.com/m4xshen/hardtime.nvim

return {
  'm4xshen/hardtime.nvim',
  dependencies = { 'MunifTanjim/nui.nvim', 'nvim-lua/plenary.nvim' },
  opts = {},
  config = function()
    require('hardtime').setup {
      disabled_filetypes = { 'neo-tree', 'lazy' },
    }
  end,
}
