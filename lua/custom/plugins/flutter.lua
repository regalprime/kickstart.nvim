
-- ~/.config/nvim/lua/custom/plugins/flutter.lua

vim.pack.add({
  "https://github.com/nvim-lua/plenary.nvim",
  "https://github.com/stevearc/dressing.nvim",
  "https://github.com/mfussenegger/nvim-dap",
  "https://github.com/nvim-neotest/nvim-nio",
  "https://github.com/rcarriga/nvim-dap-ui",
  "https://github.com/nvim-flutter/flutter-tools.nvim",
})

local ok, flutter_tools = pcall(require, "flutter-tools")

if not ok then
  vim.notify(
    "Không thể nạp flutter-tools.nvim: " .. tostring(flutter_tools),
    vim.log.levels.ERROR
  )
  return
end

flutter_tools.setup({
  flutter_path = "/Users/koolsoftmac/FlutterSDK/flutter_stable/bin/flutter",

  debugger = {
    enabled = true,
    exception_breakpoints = { "uncaught" },
  },

  widget_guides = {
    enabled = true,
  },

  closing_tags = {
    enabled = true,
  },

  -- Off: its auto-opened 40%-width split squeezed the code window. Program output is in the dap-ui console tab.
  dev_log = {
    enabled = false,
  },

  outline = {
    auto_open = false,
  },
})

flutter_tools.setup_project({
  {
    name = "Development",
    flavor = "dev",
    target = "lib/main/main_dev.dart",
  },
  {
    name = "Production",
    flavor = "prod",
    target = "lib/main/main_prod.dart",
  },
})
