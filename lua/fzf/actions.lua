-- GENERATED FILES
-- stylua: ignore
return {
  abort = {
    args = false,
    binds = { "ctrl-c", "ctrl-g", "ctrl-q", "esc" }
  },
  accept = {
    args = false,
    binds = { "enter", "double-click" }
  },
  ["accept-non-empty"] = {
    args = false,
    binds = {},
    notes = "same as accept except that it prevents fzf from exiting without selection"
  },
  ["accept-or-print-query"] = {
    args = false,
    binds = {},
    notes = "same as accept except that it prints the query when there's no match"
  },
  ["backward-char"] = {
    args = false,
    binds = { "ctrl-b", "left" }
  },
  ["backward-delete-char"] = {
    args = false,
    binds = { "ctrl-h", "bspace" }
  },
  ["backward-delete-char/eof"] = {
    args = false,
    binds = {},
    notes = "same as backward-delete-char except aborts fzf if query is empty"
  },
  ["backward-kill-word"] = {
    args = false,
    binds = { "alt-bs" }
  },
  ["backward-word"] = {
    args = false,
    binds = { "alt-b", "shift-left" }
  },
  become = {
    args = true,
    binds = {},
    notes = "replace fzf process with the specified command; see below for the details"
  },
  ["beginning-of-line"] = {
    args = false,
    binds = { "ctrl-a", "home" }
  },
  cancel = {
    args = false,
    binds = {},
    notes = "clear query string if not empty, abort fzf otherwise"
  },
  ["change-border-label"] = {
    args = true,
    binds = {},
    notes = "change --border-label to the given string"
  },
  ["change-header"] = {
    args = true,
    binds = {},
    notes = "change header to the given string; doesn't affect --header-lines"
  },
  ["change-multi"] = {
    args = true,
    binds = {},
    notes = "enable multi-select mode with a limit or disable it with 0"
  },
  ["change-preview"] = {
    args = true,
    binds = {},
    notes = "change --preview option"
  },
  ["change-preview-label"] = {
    args = true,
    binds = {},
    notes = "change --preview-label to the given string"
  },
  ["change-preview-window"] = {
    args = true,
    binds = {},
    notes = "change --preview-window option; rotate through the multiple option sets separated by '|'"
  },
  ["change-prompt"] = {
    args = true,
    binds = {},
    notes = "change prompt to the given string"
  },
  ["change-query"] = {
    args = true,
    binds = {},
    notes = "change query string to the given string"
  },
  ["clear-query"] = {
    args = false,
    binds = {},
    notes = "clear query string"
  },
  ["clear-screen"] = {
    args = false,
    binds = { "ctrl-l" }
  },
  ["clear-selection"] = {
    args = false,
    binds = {},
    notes = "clear multi-selection"
  },
  close = {
    args = false,
    binds = {},
    notes = "close preview window if open, abort fzf otherwise"
  },
  ["delete-char"] = {
    args = false,
    binds = { "del" }
  },
  ["delete-char/eof"] = {
    args = false,
    binds = { "ctrl-d" },
    notes = "same as delete-char except aborts fzf if query is empty"
  },
  deselect = {
    args = false,
    binds = {}
  },
  ["deselect-all"] = {
    args = false,
    binds = {},
    notes = "deselect all matches"
  },
  ["disable-search"] = {
    args = false,
    binds = {},
    notes = "disable search functionality"
  },
  down = {
    args = false,
    binds = { "ctrl-j", "ctrl-n", "down" }
  },
  ["enable-search"] = {
    args = false,
    binds = {},
    notes = "enable search functionality"
  },
  ["end-of-line"] = {
    args = false,
    binds = { "ctrl-e", "end" }
  },
  execute = {
    args = true,
    binds = {},
    notes = "see below for the details"
  },
  ["execute-silent"] = {
    args = true,
    binds = {},
    notes = "see below for the details"
  },
  first = {
    args = false,
    binds = {},
    notes = "move to the first match; same as pos(1)"
  },
  ["forward-char"] = {
    args = false,
    binds = { "ctrl-f", "right" }
  },
  ["forward-word"] = {
    args = false,
    binds = { "alt-f", "shift-right" }
  },
  ["half-page-down"] = {
    args = false,
    binds = {}
  },
  ["half-page-up"] = {
    args = false,
    binds = {}
  },
  ["hide-header"] = {
    args = false,
    binds = {}
  },
  ["hide-preview"] = {
    args = false,
    binds = {}
  },
  ignore = {
    args = false,
    binds = {}
  },
  jump = {
    args = false,
    binds = {},
    notes = "EasyMotion-like 2-keystroke movement"
  },
  ["kill-line"] = {
    args = false,
    binds = {}
  },
  ["kill-word"] = {
    args = false,
    binds = { "alt-d" }
  },
  last = {
    args = false,
    binds = {},
    notes = "move to the last match; same as pos(-1)"
  },
  ["next-history"] = {
    args = false,
    binds = {},
    notes = "ctrl-n on --history"
  },
  ["next-selected"] = {
    args = false,
    binds = {},
    notes = "move to the next selected item"
  },
  ["offset-down"] = {
    args = false,
    binds = {},
    notes = "similar to CTRL-E of Vim"
  },
  ["offset-middle"] = {
    args = false,
    binds = {},
    notes = "place the current item is in the middle of the screen"
  },
  ["offset-up"] = {
    args = false,
    binds = {},
    notes = "similar to CTRL-Y of Vim"
  },
  ["page-down"] = {
    args = false,
    binds = { "pgdn" }
  },
  ["page-up"] = {
    args = false,
    binds = { "pgup" }
  },
  pos = {
    args = true,
    binds = {},
    notes = "move cursor to the numeric position; negative number to count from the end"
  },
  ["prev-history"] = {
    args = false,
    binds = {},
    notes = "ctrl-p on --history"
  },
  ["prev-selected"] = {
    args = false,
    binds = {},
    notes = "move to the previous selected item"
  },
  preview = {
    args = true,
    binds = {},
    notes = "see below for the details"
  },
  ["preview-bottom"] = {
    args = false,
    binds = {}
  },
  ["preview-down"] = {
    args = false,
    binds = { "shift-down" }
  },
  ["preview-half-page-down"] = {
    args = false,
    binds = {}
  },
  ["preview-half-page-up"] = {
    args = false,
    binds = {}
  },
  ["preview-page-down"] = {
    args = false,
    binds = {}
  },
  ["preview-page-up"] = {
    args = false,
    binds = {}
  },
  ["preview-top"] = {
    args = false,
    binds = {}
  },
  ["preview-up"] = {
    args = false,
    binds = { "shift-up" }
  },
  print = {
    args = true,
    binds = {},
    notes = "add string to the output queue and print on exit"
  },
  put = {
    args = true,
    binds = {},
    notes = "put the given string to the prompt"
  },
  rebind = {
    args = true,
    binds = {},
    notes = "rebind bindings after unbind"
  },
  ["refresh-preview"] = {
    args = false,
    binds = {}
  },
  reload = {
    args = true,
    binds = {},
    notes = "see below for the details"
  },
  ["reload-sync"] = {
    args = true,
    binds = {},
    notes = "see below for the details"
  },
  ["replace-query"] = {
    args = false,
    binds = {},
    notes = "replace query string with the current selection"
  },
  select = {
    args = false,
    binds = {}
  },
  ["select-all"] = {
    args = false,
    binds = {},
    notes = "select all matches"
  },
  ["show-header"] = {
    args = false,
    binds = {}
  },
  ["show-preview"] = {
    args = false,
    binds = {}
  },
  toggle = {
    args = false,
    binds = { "(right-click)" }
  },
  ["toggle+down"] = {
    args = false,
    binds = { "ctrl-i", "(tab)" }
  },
  ["toggle+up"] = {
    args = false,
    binds = { "btab", "(shift-tab)" }
  },
  ["toggle-all"] = {
    args = false,
    binds = {},
    notes = "toggle all matches"
  },
  ["toggle-header"] = {
    args = false,
    binds = {}
  },
  ["toggle-in"] = {
    args = false,
    binds = {},
    notes = "--layout=reverse* ? toggle+up : toggle+down"
  },
  ["toggle-out"] = {
    args = false,
    binds = {},
    notes = "--layout=reverse* ? toggle+down : toggle+up"
  },
  ["toggle-preview"] = {
    args = false,
    binds = {}
  },
  ["toggle-preview-wrap"] = {
    args = false,
    binds = {}
  },
  ["toggle-search"] = {
    args = false,
    binds = {},
    notes = "toggle search functionality"
  },
  ["toggle-sort"] = {
    args = false,
    binds = {}
  },
  ["toggle-track"] = {
    args = false,
    binds = {},
    notes = "toggle global tracking option (--track)"
  },
  ["toggle-track-current"] = {
    args = false,
    binds = {},
    notes = "toggle tracking of the current item"
  },
  ["toggle-wrap"] = {
    args = false,
    binds = { "ctrl-/", "alt-/" }
  },
  ["track-current"] = {
    args = false,
    binds = {},
    notes = "track the current item; automatically disabled if focus changes"
  },
  transform = {
    args = true,
    binds = {},
    notes = "transform states using the output of an external command"
  },
  ["transform-border-label"] = {
    args = true,
    binds = {},
    notes = "transform border label using an external command"
  },
  ["transform-header"] = {
    args = true,
    binds = {},
    notes = "transform header using an external command"
  },
  ["transform-preview-label"] = {
    args = true,
    binds = {},
    notes = "transform preview label using an external command"
  },
  ["transform-prompt"] = {
    args = true,
    binds = {},
    notes = "transform prompt string using an external command"
  },
  ["transform-query"] = {
    args = true,
    binds = {},
    notes = "transform query string using an external command"
  },
  unbind = {
    args = true,
    binds = {},
    notes = "unbind bindings"
  },
  ["unix-line-discard"] = {
    args = false,
    binds = { "ctrl-u" }
  },
  ["unix-word-rubout"] = {
    args = false,
    binds = { "ctrl-w" }
  },
  ["untrack-current"] = {
    args = false,
    binds = {},
    notes = "stop tracking the current item; no-op if global tracking is enabled"
  },
  up = {
    args = false,
    binds = { "ctrl-k", "ctrl-p", "up" }
  },
  yank = {
    args = false,
    binds = { "ctrl-y", "ACTION", "COMPOSITION" }
  }
}
