local Fifo = require('fzf.fifo')
local Http = require('fzf.lib.http')
local cap = require('fzf.capabilities')
local utils = require('fzf.utils')

---@class fzf.Bridge
---@field fifo fzf.Fifo
---@field http fzf.HttpClient
---@field act fzf.Act
---@field on table
---@field _on table
local M = {}

---@param opts fzf.Config
---@return fzf.Bridge
M.new = function(opts)
  local obj = setmetatable({}, { __index = M })
  obj.http = Http.new({})
  obj._on = {}
  obj.on = {
    -- for http client?
    start = function(info)
      obj.http.port = assert(info.port)
      -- local fd_cmd = 'fd --color=always --type f --follow -E .git'
      -- obj.act:reload(fd_cmd)
      -- obj.act:change_preview('printf "%s\n" {+}')
      obj.act:unbind('change')
    end,
    -- for preview?
    focus = function(info)
      -- u.pp(info)
      -- vim.schedule(function() obj.entries = vim.fn.readfile('/tmp/tmp') end)
    end,
    -- for live grep?
    change = function(info)
      -- if _G.fzf.picker == 'lgrep' then
      -- u.pp('here')
      -- obj._selected = vim.fn.readfile(info.selected)
      -- obj.act:preview('file ')
      -- end
      -- obj.entries = vim.fn.readfile('/tmp/tmp')
      -- u.pp(s)
      -- obj.act:change_preview(('echo "{} (changed)"'):format(s))
      -- u.pp(info.query)
    end,
  }
  obj.fifo = Fifo.new({
    handler = function(info)
      -- vim.print(info.event)
      local cb = obj.on[info.event]
      if cb then cb(info, obj.fifo) end
      cb = obj._on[info.event]
      if cb then cb(info, obj.fifo) end
    end,
  })
  obj.act = obj:gen_act()
  return obj
end

---@param events string|string[]|nil
---@param cb fzf.InfoCb|nil
function M:listen_on(events, cb)
  events = events or cap.events
  ---@cast events string[]
  events = type(events) == 'string' and { events } or events
  for _, event in pairs(events) do
    self._on[event] = cb
  end
end

local alias = {
  exec_silent = 'execute-silent',
}

---@alias fzf.Act { [string]: function }
---@return fzf.Act
function M:gen_act()
  local actions = cap.actions
  local http = self.http
  local caller = setmetatable({}, {
    __index = function(tbl, name)
      if not self._fix_freeze then
        http:post('')
        self._fix_freeze = true
      end
      name = name:gsub('_', '-')
      name = alias[name] or name
      if not actions[name] then error('Unknown action: ' .. name) end
      tbl[name] = function(_, arg)
        if not arg then
          http:post(name)
        elseif type(arg) == 'string' then
          http:post(name .. ':' .. arg)
        elseif type(arg) == 'function' then
          -- local new_fifo = Fifo.new({
          --   handler = function(info, fifo)
          --     fifo.stop()
          --     arg(info, fifo)
          --   end,
          -- })
        end
      end
      return tbl[name]
    end,
  })
  return caller
end

-- https://github.com/junegunn/fzf/blob/6c0ca4a64a4e2f8697dfa830dcae56c1d7ddca51/src/terminal.go#L1051
-- when no entries, cmd with {+} won't be expand/execute, to force expand/execute {+} we need always append a {q}
-- TODO: {+} cannot be format-print
-- a) use {+f}, but it's auto deleted after subshell die, then need to spawn other cli tools...
-- b) selected is not always needed (only on e.g. enter/ctrl-t..., so we can just don't handle it separately?)
---@param event string
---@return string
function M:build_payload(event)
  return utils.serialize(vim.tbl_extend('force', cap.envs, {
    -- FIXME: when query? match? selected? contain \, {}...
    _ = '{q}',
    selected = '{+f}',
    match = '{}',
    event = event,
  }))
end

---@class fzf.Item
---@field index integer
---@field text string

---@class fzf.Response
---@field current fzf.Item
---@field matchCount integer
---@field matches fzf.Item[]
---@field position integer
---@field progress integer
---@field query string
---@field reading boolean
---@field selected fzf.Item[]
---@field sort boolean
---@field totalCount integer

---@param cb fun(resp: fzf.Response)
function M:get(cb)
  self.http:get({ limit = 100000 }, function(obj)
    cb(vim.json.decode(obj.stdout)) --
  end)
end

---@return string
function M:gen_binds()
  local name = self.fifo.name
  local events = cap.events
  return vim
    .iter(events)
    :map(function(e)
      local s = ('cp {+f} /tmp/t2; echo > %s %q &'):format(name, self:build_payload(e))
      return ('--bind=%s:execute-silent:%s'):format(e, vim.fn.shellescape(s))
    end)
    :join('\n')
end

return M
