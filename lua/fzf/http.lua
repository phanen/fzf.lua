-- TODO: libcurl or luvit...

---@class HttpClient
---@field addr string
---@field ip string
---@field port integer
local Client = {}

---@param ip string
---@param port integer
---@return HttpClient
function Client:new(ip, port)
  local addr = ('%s:%d'):format(ip, port)
  return setmetatable({
    ip = ip,
    port = port,
    addr = addr,
  }, { __index = self })
end

---@param callback function
function Client:get(callback)
  ---@diagnostic disable-next-line: param-type-mismatch
  vim.system({ 'curl', '-XGET', self.addr }, callback)
end

---@param data string
---@param callback function
function Client:post(data, callback)
  if _debug then vim.print({ 'curl', '-XPOST', self.addr, '-d', data }) end
  ---@diagnostic disable-next-line: param-type-mismatch
  vim.system({ 'curl', '-XPOST', self.addr, '-d', data }, callback)
end

return Client
