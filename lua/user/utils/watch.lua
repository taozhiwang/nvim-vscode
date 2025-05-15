local utils = require("user.utils")
local M = {}

---@class Watcher
---@field bufnr number
---@field fname string
---@field watch uv_fs_event_t

M.busy_watchers = {} ---@type table[Watcher]
M.idle_watchers = {} ---@type table[Watcher]

local function on_change(err, fname, status)
  fname = vim.fn.fnamemodify(fname, ":p")
  local w = M.busy_watchers[fname]
  if not w then
    return
  end
  local bufnr = w.bufnr
  if not vim.bo[bufnr].modified then
    pcall(vim.cmd, "checktime")
  end
end

function M.start_watch(buf, fname)
  fname = fname or vim.api.nvim_buf_get_name(buf)
  if M.busy_watchers[fname] then
    return
  end
  if #M.idle_watchers == 0 then
    table.insert(M.idle_watchers, { watch = vim.loop.new_fs_event() })
  end
  local watcher = M.idle_watchers[#M.idle_watchers]
  table.remove(M.idle_watchers, #M.idle_watchers)
  watcher.bufnr = buf
  watcher.watch:start(
    fname,
    {},
    vim.schedule_wrap(function(...)
      on_change(...)
    end)
  )
  M.busy_watchers[fname] = watcher
end

function M.stop_watch(buf, fname)
  fname = fname or vim.api.nvim_buf_get_name(buf)
  local watcher = M.busy_watchers[fname]
  if not watcher then
    return
  end
  M.busy_watchers[fname] = nil
  watcher.watch:stop()
  table.insert(M.idle_watchers, watcher)
end

function M.stop_all()
  for f, w in pairs(M.busy_watchers) do
    w.watch:stop()
    M.busy_watchers[f] = nil
    table.insert(M.idle_watchers, w)
  end
end

function M.buf_win_enter()
  local wins = vim.api.nvim_tabpage_list_wins(0)
  local bufs = {}
  -- start watch new buf show in win
  for _, w in ipairs(wins) do
    local b = vim.api.nvim_win_get_buf(w)
    if utils.is_real_file(b) then
      local f = vim.api.nvim_buf_get_name(b)
      M.start_watch(b, f)
      bufs[f] = b
    end
  end
  -- stop watch buf that is hidden
  for f, w in pairs(M.busy_watchers) do
    if not bufs[f] then
      M.stop_watch(w.bufnr, f)
    end
  end
end

return M
