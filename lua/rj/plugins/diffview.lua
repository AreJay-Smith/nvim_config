return {
  "sindrets/diffview.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
  },
  config = function()
    local keymap = vim.keymap
    keymap.set("n", "<leader>gd", "<cmd>DiffviewOpen<cr>", { desc = "Git diffview open" })
    keymap.set("n", "<leader>gh", "<cmd>DiffviewFileHistory %<cr>", { desc = "Git file history" })
    keymap.set("n", "<leader>gx", "<cmd>DiffviewClose<cr>", { desc = "Git diffview close" })
  end,
}
