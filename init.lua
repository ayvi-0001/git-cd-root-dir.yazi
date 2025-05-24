---@diagnostic disable: undefined-global

---@module 'ya', 'fs'
---@diagnostic disable-next-line: unknown-cast-variable
---@cast ya Ya
---@diagnostic disable-next-line: unknown-cast-variable
---@cast fs Fs

local M = {}

---@type number
TIMEOUT_NOTIFY = 2.0

---Check if var is none. Converted to string first.
---@param v any
---@returns boolean
local isempty = function(v)
  local s = tostring(v)
  return s == nil or s == ""
end

---@param url1 (Url|string)?
---@param url2 (Url|string)?
local _url_eq = function(url1, url2)
  if type(url1) == "string" then
    url1 = Url(url1) --[[@as Url]]
  end
  if type(url2) == "string" then
    url2 = Url(url2) --[[@as Url]]
  end
  return select(1, fs.unique_name(url2)) == select(1, fs.unique_name(url1))
end

---@enum LogLevel
LOGLEVEL = {
  info = "info",
  warn = "warn",
  error = "error",
}

---@param content string
---@param level LogLevel?
local ya_notify = function(content, level)
  ya.notify {
    title = "git-cd-root-dir",
    content = content,
    level = level or LOGLEVEL.info,
    timeout = TIMEOUT_NOTIFY,
  }
end

---@async
---@param job { args: string[]? }
function M:entry(job) ---@diagnostic disable-line: unused-local
  local cwd = fs.cwd()

  local cmd = Command "git" --[[@as Command]]
  local output = cmd:args({ "rev-parse", "--show-toplevel" }):cwd(tostring(cwd)):output()

  if not output then
    return
  end

  local result = output.stdout:match("^%s*(.-)%s*$"):gsub("[\n\r]+", " ") --[[@as string]]

  -- Check if we are already in the root dir.
  if _url_eq(cwd, result) then
    ya_notify("Already in the root dir of this repo.", LOGLEVEL.info)
    return
  end

  -- Try to change dirs.
  ya.mgr_emit("cd", { result })

  local latest_cwd = fs.cwd()

  if not _url_eq(cwd, latest_cwd) then
    -- We've changed directories, return.
    return
  end

  -- Before confirming we're not in a repo,
  -- check to see if we are in a .git dir, since the result of
  -- rev-parse --show-toplevel will error if its not ran in a work tree.

  ---Search parent paths of a Url for a suffix.
  ---@param path Url
  ---@param suffix string
  ---@return Url?
  local function recurse_dir_search(path, suffix)
    local parent = path.parent
    if path:ends_with(suffix) then
      return parent
    elseif parent then
      return recurse_dir_search(parent, suffix)
    else
      return nil
    end
  end

  local ok, pcall_result = pcall(recurse_dir_search, latest_cwd, ".git")

  if ok and pcall_result ~= nil then
    ya.mgr_emit("cd", { pcall_result })
  elseif isempty(result) then
    -- Finally, confirm the initial result is empty, we are not in a git repository.
    ya_notify("Not in a git repository.", LOGLEVEL.error)
  end
end

return M
