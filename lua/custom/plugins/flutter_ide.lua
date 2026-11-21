-- Android Studio-like Flutter UX (keymaps + hot reload on save + DAP signs).
-- Pure add-on: only sets buffer-local maps on dart files; touches no existing config.
-- Loaded after flutter.lua (alphabetical order in custom/plugins/init.lua).

local ok, cmds = pcall(require, 'flutter-tools.commands')
if not ok then return end

local dap = require 'dap'

-- Breakpoint / stopped-line signs (like the red dot in Android Studio)
vim.api.nvim_set_hl(0, 'DapBreak', { fg = '#e51400' })
vim.api.nvim_set_hl(0, 'DapStop', { fg = '#ffcc00' })
for name, text in pairs { Breakpoint = '●', BreakpointCondition = '◆', BreakpointRejected = '⊘', LogPoint = '◇', Stopped = '▶' } do
  local hl = name == 'Stopped' and 'DapStop' or 'DapBreak'
  vim.fn.sign_define('Dap' .. name, { text = text, texthl = hl, numhl = hl })
end

local group = vim.api.nvim_create_augroup('flutter-ide', { clear = true })

vim.api.nvim_create_autocmd('FileType', {
  group = group,
  pattern = 'dart',
  callback = function(ev)
    local function map(lhs, rhs, desc) vim.keymap.set('n', lhs, rhs, { buffer = ev.buf, desc = 'Flutter: ' .. desc }) end

    -- Run / lifecycle (Run, Hot Reload, Hot Restart, Stop)
    map('<leader>fr', '<cmd>FlutterRun<cr>', 'Run/Debug app')
    map('<leader>fh', function() cmds.reload() end, 'Hot reload')
    map('<leader>fH', function() cmds.restart() end, 'Hot restart')
    map('<leader>fq', function() cmds.quit() end, 'Stop app')
    map('<leader>fd', '<cmd>FlutterDevices<cr>', 'Select device')
    map('<leader>fe', '<cmd>FlutterEmulators<cr>', 'Launch emulator')
    map('<leader>fa', '<cmd>FlutterAttach<cr>', 'Attach to running app')

    -- Flutter Inspector
    map('<leader>fi', function() cmds.inspect_widget() end, 'Select Widget Mode (inspector)')
    map('<leader>fv', function() cmds.visual_debug() end, 'Debug paint (layout guides)')
    map('<leader>fP', function() cmds.performance_overlay() end, 'Performance overlay')
    map('<leader>fR', function() cmds.repaint_rainbow() end, 'Repaint rainbow')
    map('<leader>fs', function() cmds.slow_animations() end, 'Slow animations')
    map('<leader>fo', '<cmd>FlutterOutlineToggle<cr>', 'Widget tree outline')
    map('<leader>ft', function() cmds.open_dev_tools() end, 'Open DevTools (full inspector/profiler)')
    map('<leader>fl', function() require('dapui').float_element('repl', { enter = true }) end, 'Floating debug console (log)')

    -- Debugger (F-keys for step/continue are already in init.lua)
    map('<leader>fb', function() dap.toggle_breakpoint() end, 'Toggle breakpoint')
    map('<leader>fB', function() dap.set_breakpoint(vim.fn.input 'Condition: ') end, 'Conditional breakpoint')
    map('<leader>fu', '<cmd>DapTabToggle<cr>', 'Toggle debug UI (own tab)')
    map('<leader>fE', function() require('dapui').eval() end, 'Evaluate expression')
    map('<S-F5>', function() dap.terminate() end, 'Stop debugging')
  end,
})

-- Hot reload on save (Android Studio default). Skipped while paused at a breakpoint.
vim.api.nvim_create_autocmd('BufWritePost', {
  group = group,
  pattern = '*.dart',
  callback = function()
    local s = dap.session()
    if cmds.is_running() and not (s and s.stopped_thread_id) then cmds.reload(true) end
  end,
})
