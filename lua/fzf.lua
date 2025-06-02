local M = {}

M.create = function()
  if _G.fzf then _G.fzf:destory() end
  _G.fzf = require('fzf.client').new({
    rg_cmd = [[rg --pcre2 --column --line-number --no-heading --color=always --smart-case --max-columns=4096]],
    fd_cmd = 'fd --color=always --type f --follow -E .git',
    bat_cmd = 'bat --color=always --style=numbers,changes',
  })
  _G.fzf:run()
  local buf = _G.fzf.term:get_buf()
  vim.keymap.set('t', '<a-;>', function() _G.fzf.bridge.act:toggle_preview() end, { buffer = buf })
  -- we list is huge... http request also become slow?? no no not correct
  vim.keymap.set('t', '<c-j>', function() _G.fzf.bridge.act:down() end, { buffer = buf })
  vim.keymap.set('t', '<c-k>', function() _G.fzf.bridge.act:up() end, { buffer = buf })
  vim.keymap.set('t', '<esc>', function() _G.fzf:win_close() end, { buffer = buf })
  vim.keymap.set('t', '<a-l>', function() _G.fzf.bridge.act:clear_selection() end, { buffer = buf })
  vim.keymap.set('t', '<c-s>', function() _G.fzf:sel_to_qf() end, { buffer = buf })
  -- FIXME: not correct? sync?
  vim.keymap.set('t', '<cr>', function() _G.fzf:edit_or_tabedit() end, { buffer = buf })
  vim.keymap.set('t', '<c-t>', function() _G.fzf:tabedit() end, { buffer = buf })
end

M.setup = function()
  vim.keymap.set('n', ' u', function() _G.fzf:win_open() end)
  vim.keymap.set('n', ' o', function()
    M.create()
    _G.fzf:win_open()
  end)
  vim.keymap.set('n', '<c-n>', function()
    if not _G.fzf then
      M.create()
      vim.defer_fn(function() _G.fzf:lgrep() end, 20)
      return
    end
    _G.fzf:lgrep()
    -- wait for create and 'start' event
  end)
  vim.keymap.set('n', '<c-l>', function()
    if not _G.fzf then
      M.create()
      vim.defer_fn(function() _G.fzf:files() end, 20)
      return
    end
    _G.fzf:files()
  end)
end

return M
