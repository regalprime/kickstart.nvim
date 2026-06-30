vim.pack.add {
  { src = gh "okuuva/auto-save.nvim" },
}

require("auto-save").setup {
  enabled = true,
}