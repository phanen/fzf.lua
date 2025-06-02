local fn, uv = vim.fn, vim.uv
local Bridge = require('fzf.bridge')
local Term = require('fzf.lib.term')
local utils = require('fzf.utils')
-- local win = require('fzf.lib.win').new({
--   config = { zindex = 100, row = 0.30, width = 0.95, height = 0.7, style = 'minimal' },
-- })

---@class fzf.Client
---@field bridge? fzf.Bridge
---@field opts? fzf.Config
---@field term? term.Term
---@field win? win.Win
---@field buf? integer
---@field job? integer
---@field cmd? string[]
---@field act? fzf.Act
---@field cwd? string
local M = {}

---@param opts fzf.Config
---@return fzf.Client
function M.new(opts)
  local obj = setmetatable({}, { __index = M })
  opts = opts or {}
  obj.cwd = uv.cwd()
  obj._init_cwd = obj.cwd
  obj.opts = opts
  obj.win = win
  local bridge = Bridge.new(opts)
  obj.bridge = bridge
  obj.term = Term.new({
    bo = { ft = 'fzf' }, -- handle terminal mode by ourself
    env = {
      FZF_DEFAULT_COMMAND = opts.fd_cmd,
      FZF_DEFAULT_OPTS_FILE = vim.env.FZF_DEFAULT_OPTS_FILE or '',
      -- FZF_DEFAULT_OPTS_FILE = '',
      FZF_DEFAULT_OPTS = vim.env.FZF_DEFAULT_OPTS .. [[
      --listen --ansi --height=100% --multi --exact
      --preview-window 'hidden:nowrap:border-left:right:60%,<36(hidden:nowrap:border-left:down:45%)'
      #--preview-window 'nowrap:right:60%,<36(hidden:nowrap:down:45%)'
      -d ":"
      ]] .. bridge:gen_binds(),
    },
    cmd = { 'fzf' }, -- we don't have any commands
    auto_close = true,
  })
  return obj
end

function M:run() self.term:spawn() end

function M:destory() self.term:destory() end

local Popup = require('nui.popup')
local Layout = require('nui.layout')

function M:win_close()
  -- self:win_close()
  self.layout:unmount()
end

function M:win_open()
  local buf = self.term:get_buf()
  if not buf then return end
  -- self.win:open(buf)
  if not self.layout then
    self.popup_fzf, self.popup_preview =
      Popup({
        enter = true,
        bufnr = buf,
        border = 'double',
      }), Popup({
        bufnr = vim.api.nvim_create_buf(false, true), -- make it unmanaged
        border = 'double',
      })
    self.layout = Layout(
      {
        position = '35%',
        size = {
          width = '95%',
          height = '70%',
        },
      },
      Layout.Box({
        Layout.Box(self.popup_fzf, { size = '40%' }),
        Layout.Box(self.popup_preview, { size = '60%' }),
      }, { dir = 'row' })
    )
  end
  self.layout:mount()
  vim.cmd.startinsert()
end

-- setqflist is slow since lua-vim bridge
-- TODO: write formatted lines to file then read file as qf
-- timer...
local function setqflist(list)
  local qf_size = math.min(#list, 20000)
  local chunk_cap = math.min(512, qf_size)
  local chunk, size = {}, 0
  local new_list = true
  coroutine.wrap(function()
    local co = coroutine.running()
    for i = 1, qf_size do
      size = size + 1
      chunk[size] = list[i]
      if size == chunk_cap or i == qf_size then
        local t0 = uv.hrtime()
        fn.setqflist({}, new_list and ' ' or 'a', { items = chunk })
        local t = (uv.hrtime() - t0) / 1000000
        new_list = false
        vim.defer_fn(function()
          chunk, size = {}, 0
          coroutine.resume(co)
        end, t * 2.5)
        coroutine.yield()
      end
    end
  end)()
end

local function setqflist0(list)
  local tmpfile = fn.tempname()
  uv.fs_open(tmpfile, 'a', 438, function(err, fd)
    coroutine.wrap(function()
      local co = coroutine.running()
      if err then error(err) end
      for _, e in ipairs(list) do
        uv.fs_write(fd, e.filename .. ':' .. e.lnum .. ': \n', -1, function(w_err)
          if w_err then error(w_err) end
          coroutine.resume(co)
        end)
        coroutine.yield()
      end
      vim.schedule(function() vim.cmd('cfile ' .. tmpfile) end)
    end)()
  end)
end

function M:sel_to_qf()
  self:win_close()
  -- need a selected changed event (e.g. when use select-all)?
  utils.read_file('/tmp/t2', function(selected)
    if selected[#selected] == '' then selected[#selected] = nil end
    -- self.bridge:get(function(resp)
    self.bridge.act:clear_selection()
    -- local selected = #resp.selected >= 1 and resp.selected or { resp.current ~= vim.NIL and resp.current or nil }
    if #selected == 0 then return end
    vim.schedule(function()
      local list = vim
        .iter(selected)
        :map(function(e)
          -- e.filename = e.text
          -- e.lnum = 1
          -- e.text = ''
          -- local file = utils.parse_line(e.text)
          local file = utils.parse_line(e)
          local text = file.stripped:match(':%d+:%d?%d?%d?%d?:?(.*)$')
          e = {}
          e.bufnr = file.bufnr
          e.filename = file.bufname or file.path or file.uri
          e.lnum = file.line > 0 and file.line or 1
          e.col = file.col
          e.text = text
          return e
        end)
        :totable()
      -- local qf_items = vim.iter(selected):map(function(e) return e.text .. ':1:0: ' end):totable()
      -- fn.setqflist({}, ' ', { title = 'fzf', lines = qf_items })
      setqflist(list)
      -- setqflist0(list)
      vim.cmd.copen()
    end)
  end)
end

function M:edit_or_tabedit()
  self:win_close()
  -- {+f} is faster?
  self.bridge.act:clear_selection()
  utils.read_file('/tmp/t2', function(selected)
    if selected[#selected] == '' then selected[#selected] = nil end
    -- self.bridge:get(function(resp)
    self.bridge.act:clear_selection()
    -- local selected = #resp.selected >= 1 and resp.selected or { resp.current ~= vim.NIL and resp.current or nil }
    if #selected == 0 then return end
    vim.schedule(function()
      if #selected == 1 then
        -- local r = utils.parse_line(selected[1].text)
        local r = utils.parse_line(selected[1])
        vim.cmd.edit(r.line and r.line > 0 and ('+%s %s'):format(r.line, r.path) or r.path)
      elseif #selected > 1 then
        vim.iter(selected):each(function(e)
          -- local r = utils.parse_line(e.text)
          local r = utils.parse_line(e)
          vim.schedule_wrap(vim.cmd.tabedit)(r.line and r.line > 0 and ('+%s %s'):format(r.line, r.path) or r.path)
        end)
      end
    end)
  end)
end

function M:tabedit()
  utils.read_file('/tmp/t2', function(selected)
    if selected[#selected] == '' then selected[#selected] = nil end
    -- self.bridge:get(function(resp)
    self.bridge.act:clear_selection()
    -- local selected = #resp.selected >= 1 and resp.selected or { resp.current ~= vim.NIL and resp.current or nil }
    if #selected == 0 then return end
    vim.schedule(function()
      vim.iter(selected):each(function(e)
        -- local r = utils.parse_line(e.text)
        local r = utils.parse_line(e)
        vim.cmd.tabedit(r.line and r.line > 0 and ('+%s %s'):format(r.line, r.path) or r.path)
      end)
      self:win_close()
    end)
  end)
end

function M:files(_opts)
  self.bridge.act:pos('1')
  self.bridge.act:clear_query()
  self.bridge.act:clear_selection()
  self:win_open()
  local cwd = uv.cwd()
  if self.picker == 'lgrep' then
    self.bridge.act:unbind('change')
    self.bridge.act:enable_search()
  elseif self.picker == 'files' and cwd == self.cwd then
    return
  end
  self.bridge:listen_on({ 'focus' }, function(info)
    vim.schedule(function()
      local file = utils.parse_line(info.match:sub(2, -2))
      local ft = vim.filetype.match({ filename = file.path, buf = file.bufnr })
      utils.read_file(
        file.path,
        vim.schedule_wrap(function(lines)
          if vim.bo.ft ~= ft then vim.bo[self.popup_preview.bufnr].ft = ft end
          vim.api.nvim_buf_set_lines(self.popup_preview.bufnr, 0, -1, false, lines)
        end)
      )
    end)
    -- u.pp(self.popup_preview.bufnr)
    -- self.layout
  end)
  self.picker = 'files'
  -- self.bridge.act:change_nth('1..')
  self.cwd = cwd
  vim.defer_fn(function()
    self.bridge.act:change_preview(self.opts.bat_cmd .. ' {}')
    self.bridge.act:reload(self.opts.fd_cmd)
  end, 10)
end

function M:lgrep(_opts)
  local cwd = uv.cwd()
  self.bridge.act:pos('1')
  self.bridge.act:clear_query()
  self.bridge.act:clear_selection()
  self:win_open()
  -- TODO: async...
  if self.picker ~= 'lgrep' then
    -- self.bridge.act:toggle_sort()
    -- self.bridge
    self.bridge.act:toggle_search()
    self.bridge.act:rebind('change')
  elseif self.picker == 'lgrep' and cwd == self.cwd then
    return
  end
  self.picker = 'lgrep'
  self.cwd = uv.cwd()
  -- self.bridge.act:reload('echo a:b')

  -- local base_preview_win = 'nowrap:right:60%,<36(hidden:nowrap:down:45%)'
  -- self.bridge.act:change_preview_window(('%s:%s'):format(base_preview_win, '+{2}/2'))
  -- self.bridge.act:change_preview((self.opts.bat_cmd .. ' --highlight-line={2}' .. ' {1}'))
  self.bridge.act:reload(':')
  self.bridge:listen_on({ 'change' }, function(info)
    self.bridge.act:reload(('%s -e %q'):format(self.opts.rg_cmd, info.query))
    -- self.bridge.act:change_preview_window(('%s:%s'):format(base_preview_win, '+{2}/2'))
    -- self.bridge.act:change_preview((self.opts.bat_cmd .. ' --highlight-line={2}' .. ' {1}'))
  end)
  -- self.bridge:listen_on({ 'zero' }, function() self.bridge.act:change_preview('echo ""') end)
  -- self._last_preview_cmd = (self.opts.bat_cmd .. ' %q'):format(file.path)
  -- self.bridge.act:change_preview((self.opts.bat_cmd .. ' --highlight-line={2}' .. ' {1}'))
  -- self.bridge:listen_on({ 'focus' }, function()
  --   utils.read_file('/tmp/t2', function(lines)
  --     vim.schedule(function()
  --       local file = utils.parse_line(lines[1])
  --       -- self.bridge.act:preview((self.opts.bat_cmd .. ' %q'):format(file.path))
  --       -- no flick
  --       -- TODO: we need concat request... with `+`
  --       self.bridge.act:change_preview_window(('%s:%s'):format(base_preview_win, ('+%s/2'):format(file.line)))
  --       self.bridge.act:change_preview(
  --         (self.opts.bat_cmd .. ' --highlight-line=%s' .. ' %q'):format(file.line, file.path)
  --       )
  --     end)
  --   end)
  -- end)
  -- self.bridge.act:change_preview(function() end)
end

return M
