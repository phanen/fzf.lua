local uv = vim.uv

local M = {}

---@param data string
---@return fzf.Info
M.deserialize = function(data)
  -- vim.print(data)
  return assert(loadstring(data), data)()
end

---@param payload table
---@return string
M.serialize = function(payload)
  return ([[return %s]]):format(vim.inspect(payload))
  -- return [[return { port = '$FZF_PORT', event = "start" }]]
end

---@alias fzf.Entry { [string]: any }

---@param line string
---@return fzf.Entry
M.parse_line = function(line)
  -- TODO: cwd may change.. indepent-of, should set in action/event
  return require('fzf-lua.path').entry_to_file(line, { cwd = uv.cwd() })
end

---@param filename string
---@param cb fun(lines: string[])
M.read_file = function(filename, cb)
  uv.fs_open(filename, 'r', 438, function(err, fd)
    if err then error(err) end
    local close = function()
      uv.fs_close(fd, function(c_err)
        if c_err then error(c_err) end
      end)
    end
    uv.fs_read(fd, 1024, -1, function(r_err, data)
      if r_err then
        close()
        error(r_err)
      end
      if not data or #data == 0 then
        close()
        error('empty file')
      end
      cb(vim.split(data, '\n'))
      close()
    end)
  end)
end

return M
