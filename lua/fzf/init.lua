local _ = function()
  if fzf1 then fn.jobstop(fzf1.fzf_job) end
  local Fzf = require('fzf.client')
  fzf1 = Fzf.new('127.0.0.1', 6266)
  fzf1:run()
  fzf1:create_win()

  local bt = u.map[fzf1.buf].t
  local n = u.map.n
  do
    bt['<a-;>'] = function() fzf1:toggle_preview() end
    bt['<a-j>'] = function() fzf1:reload('fd -HI --color=always') end
    bt['<c-j>'] = function() fzf1:down() end
    bt['<c-k>'] = function() fzf1:up() end
    bt['<esc>'] = function() fzf1:hide_win() end
    n['  '] = function() fzf1:show_win() end
    bt['<cr>'] = function()
      local fifo = require('fzf.ipc').start(function(data) end, true)
      fzf1:execute_silent(('echo "hehe" > %s'):format(fifo))
    end
    bt['<c-cr>'] = function() fzf1:clear_selection() end
    bt['<s-cr>'] = function() fzf1:clear_selection() end
  end
end

local setup = function() u.map.n[' so'] = _ end

return { setup = setup }
