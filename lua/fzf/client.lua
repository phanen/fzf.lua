---@class Fzf
---@field client HttpClient
---@field win integer?
---@field buf integer?
---@field fzf_job integer?
---@field fifo string?
---@field cmd string[]?
local Fzf = {}

local api, fn, uv = vim.api, vim.fn, vim.uv

local action_dispatch = function(key)
  key = key:gsub('_', '-')
  return require('fzf.actions')[key]
      and function(self, cmd)
        local data = key .. (cmd and (':' .. cmd) or '')
        self.client:post(data)
      end
    or nil
end

Fzf.new = function(ip, port)
  local obj = { client = require('fzf.http'):new(ip, port) }
  return setmetatable(obj, {
    __index = function(self, key)
      rawset(self, key, Fzf[key] or action_dispatch(key))
      return rawget(self, key)
    end,
  })
end

local event_dispatch = function(info)
  local ok, gen_info = pcall(loadstring, info)
  assert(ok and gen_info, print(info))
  ---@diagnostic disable-next-line: need-check-nil
  info = gen_info()
  -- u.pp(info.event)
  -- u.pp(info.selected)
  -- u.pp(info._query)
end

function Fzf:run(opts)
  opts = opts or {}
  self.fifo = require('fzf.ipc').start(event_dispatch)
  local encode = require('fzf.ipc').encode
  -- local events = require('fzf.events')
  local events = { 'change' }
  self.cmd = vim.iter(events):fold(
    { 'fzf', '--multi', '--ansi', '--listen', tostring(self.client.port) },
    function(acc, event)
      acc[#acc + 1] = '--bind'
      acc[#acc + 1] = ('%s:execute-silent:echo > %s "%s" &'):format(event, self.fifo, encode(event))
      vim.print(acc[#acc])
      return acc
    end
  )
  self.buf = api.nvim_create_buf(false, true)
  self.fzf_job = api.nvim_buf_call(
    self.buf,
    function() return fn.jobstart(self.cmd, { term = true }) end
  )
end

function Fzf:create_win()
  self.win = api.nvim_open_win(self.buf, true, {
    relative = 'editor',
    row = 10,
    col = 20,
    width = 80,
    height = 30,
    style = 'minimal',
    border = vim.g.border,
  })
  vim.cmd.startinsert()
end

function Fzf:hide_win() -- win_set_config?
  if not self.win or api.nvim_buf_is_valid(self.win) then return end
  api.nvim_win_close(self.win, true)
  self.win = nil
end

function Fzf:show_win()
  if self.win and api.nvim_buf_is_valid(self.win) then return end
  self:create_win()
end

return Fzf
