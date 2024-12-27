return {
  "folke/which-key.nvim",
  event = "VeryLazy",
  init = function()
    vim.g.timeout = true
    vim.o.timeoutlen = 500
  end,
  opts = {
    -- your configuration comes here
    -- or leave it empty too use the default settings
    -- refer to the configuration section below
  },
}
