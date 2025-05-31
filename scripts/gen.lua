#!/usr/bin/env -S nvim -l

local get_indent = function(line) return (line:match('^%s+') or ''):len() end

local get_man_range = function(start_pat, end_pat)
  local res = vim.system { 'sh', '-c', ('fzf --man | awk "/%s/,/%s/ { print }"'):format(start_pat, end_pat) }:wait()
  return vim.split(res.stdout, '\n', { trimempty = true })
end

local parse_lines = function(lines)
  return vim
    .iter(lines)
    :map(function(line)
      local action, remain = line:match('^(%S+)(.-)$')
      local name, args = action:match('^([^()]+)(%S-)$')
      name = name or action
      args = args:gsub('%s', ''):len() > 0 and true or false
      local bind_notes = remain:gsub('^%s+', '')
      bind_notes = vim.split(bind_notes, '%s+', { trimempty = true })
      local n_id = vim.iter(bind_notes):enumerate():find(function(_, v) return v:match('^%(.*[^)]$') end)
      local binds = n_id and vim.iter(bind_notes):take(n_id - 1):totable() or bind_notes
      local notes = n_id and vim.iter(bind_notes):skip(n_id - 1):join(' '):match('^%((.*)%)$')
      return { name = name, args = args, binds = binds, notes = notes }
    end)
    :fold({}, function(acc, v)
      acc[v.name] = v
      v.name = nil
      return acc
    end)
end

local gen = {}
gen.actions = function()
  local lines = get_man_range('AVAILABLE ACTIONS:', 'ACTION COMPOSITION')
  local skip = 4
  local indent = get_indent(lines[skip + 1])
  lines = vim.iter(lines):skip(skip):fold({}, function(acc, line)
    local cur_indent = get_indent(line)
    line = line:gsub('^%s+', ''):gsub('%s+$', '')
    if cur_indent == indent then
      acc[#acc + 1] = line
    else
      local prev = acc[#acc]
      line = (prev:match('\u{2010}$') and (prev:gsub('\u{2010}$', '')) or (prev .. ' ')) .. line
      acc[#acc] = line
    end
    return acc
  end)
  local actions = parse_lines(lines)
  return actions
end

gen.events = function()
  local lines = get_man_range('AVAILABLE EVENTS:', 'AVAILABLE ACTIONS:')
  local skip = 1
  local indent = get_indent(lines[skip + 1])
  local events = vim
    .iter(lines)
    :skip(skip)
    :filter(function(line) return get_indent(line) == indent end)
    :map(function(line) return (line:gsub('^%s+', ''):gsub('%s+$', '')) end)
    :fold({}, function(acc, k)
      acc[k] = true
      return acc
    end)
  -- :map(function(line) return vim.inspect((line:gsub('^%s+', ''):gsub('%s+$', ''))) end):join('|')
  return events
end

gen.keys = function()
  local lines = get_man_range('AVAILABLE KEYS:', 'AVAILABLE EVENTS:')
  local skip, rskip = 1, 3
  local indent = get_indent(lines[skip + 1])
  local keys = vim
    .iter(lines)
    :skip(skip)
    :rskip(rskip)
    :filter(function(line) return get_indent(line) == indent end)
    :map(function(v) return vim.split(v, '%s+', { trimempty = true }) end)
    :totable()
  return keys
end

gen.envs = function()
  local lines = get_man_range('ENVIRONMENT VARIABLES EXPORTED TO CHILD PROCESSES', 'EXTENDED SEARCH MODE')
  local skip, rskip = 2, 1
  return vim
    .iter(lines)
    :skip(skip)
    :rskip(rskip)
    :map(function(line) return line:match('%s+(FZF_[_A-Z]+)') end)
    :fold({}, function(acc, v)
      acc[v:gsub('FZF_', ''):lower()] = '$' .. v
      return acc
    end)
end

print('-- GENERATED FILE')
print('-- stylua: ignore start')
print('---@class fzf.Capabilities')
print('local M = {}')
print('\n')
print(('M.%s = %s'):format('actions', vim.inspect(gen.actions())))
print('\n')
print(('M.%s = %s'):format('events', vim.inspect(gen.events())))
print('\n')
print(('M.%s = %s'):format('envs', vim.inspect(gen.envs())))
print('\n')
print('return M')
