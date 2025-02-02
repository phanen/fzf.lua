local M = {}

local fn, uv = vim.fn, vim.uv

---@param handler function
---@return string
M.start = function(handler)
  local fifo = fn.tempname()
  vim.system { 'mkfifo', fifo }:wait()
  -- stupid, but we don't need care about chunking...
  local function restart()
    return vim.system({ 'cat', fifo }, {}, function(obj)
      handler(obj.stdout)
      return restart()
    end)
  end
  restart()
  -- TODO: handle chunk/delimeter?, make it robust
  -- uv.fs_open(fifo, 'r', 438, function(open_err, fd)
  --   if open_err then error(open_err) end
  --   local pipe = assert(uv.new_pipe())
  --   pipe:open(fd)
  --   assert(uv.fs_open(fifo, 'w', 438)) -- an idle writer keep reader alive
  --   pipe:read_start(function(read_err, chunk)
  --     if read_err then error(read_err) end
  --     if not chunk then error('chunk is nil') end
  --     handler(chunk)
  --   end)
  -- end)
  return fifo
end

---@param event string
---@return string
M.encode = function(event)
  -- https://github.com/junegunn/fzf/blob/6c0ca4a64a4e2f8697dfa830dcae56c1d7ddca51/src/terminal.go#L1051
  -- FIXME(upstream): when no entries, {+} cmd not executed (workaround by always append a {q})
  -- TODO: {+} cannot be format-print
  -- a) use {+f}, but it's auto deleted after subshell die, then need to spawn other cli tools...
  -- b) selected is not always needed (only on e.g. enter/ctrl-t..., so we can just don't handle it separately?)
  local lua_chunk = ([==[return {
  event = '%s',
  selected = [[%s]],
  _query = %s,
  action = '$FZF_ACTION',
  border_label = '$FZF_BORDER_LABEL',
  columns = $FZF_COLUMNS,
  key = '$FZF_KEY',
  lines = $FZF_LINES,
  match_count = $FZF_MATCH_COUNT,
  port = $FZF_PORT,
  pos = $FZF_POS,
  preview_columns = '$FZF_PREVIEW_COLUMNS',
  preview_label = '$FZF_PREVIEW_LABEL',
  preview_left = '$FZF_PREVIEW_LEFT',
  preview_lines = '$FZF_PREVIEW_LINES',
  preview_top = '$FZF_PREVIEW_TOP',
  prompt = '$FZF_PROMPT',
  query = '$FZF_QUERY',
  select_count = $FZF_SELECT_COUNT,
  total_count = $FZF_TOTAL_COUNT,
  info = '$FZF_INFO',
}]==]):format(event, '{+}', '{q}')
  return lua_chunk
end

return M
