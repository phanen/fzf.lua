local fn, uv = vim.fn, vim.uv

---@alias fzf.InfoCb fun(info: fzf.Info, obj: fzf.Fifo)
---@alias fzf.StopCb fun()

---@class fzf.Fifo
---@field name string
---@field handler fzf.InfoCb
---@field stop fzf.StopCb
local M = {}

---@param opts {handler: fzf.InfoCb}
---@return fzf.Fifo
M.new = function(opts)
  local obj = setmetatable({}, { __index = M })
  obj.handler = opts.handler
  obj.name, obj.stop = obj:start()
  return obj
end

---@return string, fzf.StopCb
function M:start()
  local fifo = fn.tempname()
  vim.system { 'mkfifo', fifo }:wait()
  local r_fd, w_fd -- an idle writer keep reader alive https://github.com/neovim/neovim/issues/32332
  local stop = function()
    if r_fd then uv.fs_close(r_fd) end
    if w_fd then uv.fs_close(w_fd) end
    uv.fs_unlink(fifo)
  end
  uv.fs_open(fifo, 'w', -1, function(open_err, fd)
    w_fd = fd
    if open_err then
      stop()
      error(open_err)
    end
  end)
  uv.fs_open(fifo, 'r', 438, function(open_err, fd)
    if open_err then
      stop()
      error(open_err)
    end
    local pipe = assert(uv.new_pipe())
    pipe:open(fd)
    local acc = ''
    pipe:read_start(function(read_err, chunk)
      if read_err then error(read_err) end
      if not chunk then
        if not pipe:is_closing() then pipe:close() end
        return
      end
      acc = acc .. chunk
      local cur, nex = chunk:match('^(return %b{})(.*)$')
      if cur then
        acc = assert(nex)
        self.handler(require('fzf.utils').deserialize(cur), self)
      end
    end)
  end)
  return fifo, stop
end

return M
