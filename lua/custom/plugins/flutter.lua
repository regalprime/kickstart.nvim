return {
  {
    "nvim-flutter/flutter-tools.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "stevearc/dressing.nvim",
    },
    ft = "dart",
    config = function()
      require("flutter-tools").setup({
        widget_guides = {
          enabled = true,
        },

        closing_tags = {
          enabled = true,
        },

        dev_log = {
          enabled = true,
        },

        outline = {
          auto_open = false,
        },
      })
    end,
  },
}