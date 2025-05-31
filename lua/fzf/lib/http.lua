-- TODO: libcurl or luvit...

---@class fzf.HttpClient
---@field ip string
---@field port integer
---@field _addr string?
local M = {}

---@param opts {ip: string?, port: number?}
---@return fzf.HttpClient
function M.new(opts)
  local obj = setmetatable({
    ip = opts.ip or 'localhost',
    port = opts.port,
  }, { __index = M })
  return obj
end

function M:addr()
  if self._addr then return self._addr end
  assert(self.ip and self.port, 'IP and port must be set before getting address')
  self._addr = ('%s:%d'):format(self.ip, self.port)
end

---@param args table?
---@param callback function
function M:get(args, callback)
  local args_str = vim.iter(args or {}):map(function(k, v) return ('?%s=%s'):format(k, v) end):join('')
  local addr = self:addr() .. args_str
  vim.system({ 'curl', '-XGET', addr }, {}, callback)
end

---@param data string
---@param callback? function
function M:post(data, callback) vim.system({ 'curl', '-XPOST', self:addr(), '-d', data }, {}, callback) end

return M
