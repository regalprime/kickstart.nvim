-- debug.lua
--
-- Shows how to use the DAP plugin to debug your code.
--
-- Primarily focused on configuring the debugger for Go, but can
-- be extended to other languages as well. That's why it's called
-- kickstart.nvim and not kitchen-sink.nvim ;)

vim.pack.add {
  'https://github.com/mfussenegger/nvim-dap',
  'https://github.com/rcarriga/nvim-dap-ui',
  'https://github.com/nvim-neotest/nvim-nio',
  'https://github.com/mason-org/mason.nvim',
  'https://github.com/jay-babu/mason-nvim-dap.nvim',
  'https://github.com/leoluz/nvim-dap-go',
}

-- Basic debugging keymaps, feel free to change to your liking!
vim.keymap.set('n', '<F5>', function() require('dap').continue() end, { desc = 'Debug: Start/Continue' })
vim.keymap.set('n', '<F1>', function() require('dap').step_into() end, { desc = 'Debug: Step Into' })
vim.keymap.set('n', '<F2>', function() require('dap').step_over() end, { desc = 'Debug: Step Over' })
vim.keymap.set('n', '<F3>', function() require('dap').step_out() end, { desc = 'Debug: Step Out' })
vim.keymap.set('n', '<leader>b', function() require('dap').toggle_breakpoint() end, { desc = 'Debug: Toggle Breakpoint' })
vim.keymap.set('n', '<leader>B', function() require('dap').set_breakpoint(vim.fn.input 'Breakpoint condition: ') end, { desc = 'Debug: Set Breakpoint' })
-- Toggle to see last session result. Without this, you can't see session output in case of unhandled exception.
vim.keymap.set('n', '<F7>', '<cmd>DapTabToggle<cr>', { desc = 'Debug: See last session result.' })

local dap = require 'dap'
local dapui = require 'dapui'

require('mason-nvim-dap').setup {
  -- Makes a best effort to setup the various debuggers with
  -- reasonable debug configurations
  automatic_installation = true,

  -- You can provide additional configuration to the handlers,
  -- see mason-nvim-dap README for more information
  handlers = {},

  -- You'll need to check that you have the required things installed
  -- online, please don't ask me how to install them :)
  ensure_installed = {
    -- Update this to ensure that you have the debuggers for the langs you want
    -- 'delve',
  },
}

-- Dap UI setup
-- For more information, see |:help nvim-dap-ui|
---@diagnostic disable-next-line: missing-fields
-- dapui.setup {
--   -- Set icons to characters that are more likely to work in every terminal.
--   --    Feel free to remove or use ones that you like more! :)
--   --    Don't feel like these are good choices.
--   icons = { expanded = '▾', collapsed = '▸', current_frame = '*' },
--   ---@diagnostic disable-next-line: missing-fields
--   controls = {
--     icons = {
--       pause = '⏸',
--       play = '▶',
--       step_into = '⏎',
--       step_over = '⏭',
--       step_out = '⏮',
--       step_back = 'b',
--       run_last = '▶▶',
--       terminate = '⏹',
--       disconnect = '⏏',
--     },
--   },
-- }


-- Dap UI setup

dapui.setup({
  icons = {
    expanded = '▾',
    collapsed = '▸',
    current_frame = '*',
  },

  controls = {
    icons = {
      pause = '⏸',
      play = '▶',
      step_into = '⏎',
      step_over = '⏭',
      step_out = '⏮',
      step_back = 'b',
      run_last = '▶▶',
      terminate = '⏹',
      disconnect = '⏏',
    },
  },

  -- Double-click (or Enter) on a frame in the stacks panel jumps to that frame's caller/code.
  element_mappings = {
    stacks = { open = { '<CR>', '<2-LeftMouse>', 'o' }, expand = '<Tab>' },
  },

  -- Android Studio-like debug window: frames/variables column on the left, big console on the right.
  -- Sizes < 1 are fractions of the screen. No code window here: code stays in its own tab.
  layouts = {
    {
      elements = {
        { id = 'stacks', size = 0.3 },
        { id = 'scopes', size = 0.4 },
        { id = 'watches', size = 0.15 },
        { id = 'breakpoints', size = 0.15 },
      },
      size = 0.35,
      position = 'left',
    },
    {
      elements = { { id = 'repl', size = 1 } }, -- program output (flutter log) comes via the REPL; 'console' is only for runInTerminal
      size = 0.65,
      position = 'right',
    },
  },
})



-- Change breakpoint icons
-- vim.api.nvim_set_hl(0, 'DapBreak', { fg = '#e51400' })
-- vim.api.nvim_set_hl(0, 'DapStop', { fg = '#ffcc00' })
-- local breakpoint_icons = vim.g.have_nerd_font
--     and { Breakpoint = '', BreakpointCondition = '', BreakpointRejected = '', LogPoint = '', Stopped = '' }
--   or { Breakpoint = '●', BreakpointCondition = '⊜', BreakpointRejected = '⊘', LogPoint = '◆', Stopped = '⭔' }
-- for type, icon in pairs(breakpoint_icons) do
--   local tp = 'Dap' .. type
--   local hl = (type == 'Stopped') and 'DapStop' or 'DapBreak'
--   vim.fn.sign_define(tp, { text = icon, texthl = hl, numhl = hl })
-- end

-- Debug UI lives in its own tab page (gt / gT to switch), like the Debug window in Android Studio.
local debug_tab, code_tab
local function ui_open()
  if debug_tab and vim.api.nvim_tabpage_is_valid(debug_tab) then return end
  code_tab = vim.api.nvim_get_current_tabpage()
  vim.cmd 'tabnew'
  debug_tab = vim.api.nvim_get_current_tabpage()
  local blank = vim.api.nvim_get_current_win()
  dapui.open()
  if vim.api.nvim_win_is_valid(blank) then vim.api.nvim_win_close(blank, true) end -- panels fill the whole tab
end
local function ui_close()
  dapui.close()
  if debug_tab and vim.api.nvim_tabpage_is_valid(debug_tab) and #vim.api.nvim_list_tabpages() > 1 then
    vim.cmd('tabclose ' .. vim.api.nvim_tabpage_get_number(debug_tab))
  end
  debug_tab = nil
end
local function ui_toggle()
  if debug_tab and vim.api.nvim_tabpage_is_valid(debug_tab) then ui_close() else ui_open() end
end
vim.api.nvim_create_user_command('DapTabToggle', ui_toggle, { desc = 'Toggle debug UI tab' })

-- When stopped, show the source line in the code tab (the debug tab has no code window).
local function show_in_code_tab(bufnr, line, column)
  local function show(win)
    vim.api.nvim_set_current_win(win)
    pcall(vim.api.nvim_win_set_cursor, win, { line, math.max((column or 1) - 1, 0) })
    vim.cmd 'normal! zz'
  end
  for _, tab in ipairs(vim.api.nvim_list_tabpages()) do
    for _, win in ipairs(vim.api.nvim_tabpage_list_wins(tab)) do
      if vim.api.nvim_win_get_buf(win) == bufnr then return show(win) end
    end
  end
  if code_tab and vim.api.nvim_tabpage_is_valid(code_tab) then
    local win = vim.api.nvim_tabpage_get_win(code_tab)
    vim.api.nvim_win_set_buf(win, bufnr)
    show(win)
  end
end
dap.defaults.fallback.switchbuf = show_in_code_tab
-- dap-ui's frame/breakpoint "open" only looks in the current tab (the debug tab has no code window), so redirect it.
require('dapui.util').open_buf = function(bufnr, line, column)
  show_in_code_tab(bufnr, line or 1, column or 1)
  return true
end

dap.listeners.after.event_initialized['dapui_config'] = ui_open
dap.listeners.before.event_terminated['dapui_config'] = ui_close
dap.listeners.before.event_exited['dapui_config'] = ui_close

-- Install golang specific config
require('dap-go').setup {
  delve = {
    -- On Windows delve must be run attached or it crashes.
    -- See https://github.com/leoluz/nvim-dap-go/blob/main/README.md#configuring
    detached = vim.fn.has 'win32' == 0,
  },
}
