--- @since 25.5.28

local M = {}

---Check if var is none. Converted to string first.
---@param v any
---@returns boolean
local isempty = function(v)
  local s = tostring(v)
  return s == nil or s == ""
end

---@param url1 Url|string?
---@param url2 Url|string?
local url_eq = function(url1, url2)
  if type(url1) == "string" then
    url1 = Url(url1) ---@cast url1 Url
  end
  if type(url2) == "string" then
    url2 = Url(url2) ---@cast url2 Url
  end
  return select(1, fs.unique_name(url2)) == select(1, fs.unique_name(url1))
end

---Search parent paths of a Url for a suffix.
---@param path Url
---@param suffix string
---@return Url?
local function url_recursive_search(path, suffix)
  local parent = path.parent
  if path:ends_with(suffix) then
    return parent
  elseif parent then
    return url_recursive_search(parent, suffix)
  else
    return nil
  end
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
    timeout = 2.0,
  }
end

---@async
---@param job { args: { [integer|string]: Sendable? } }
function M:entry(job) ---@diagnostic disable-line: unused-local
  local cwd = fs.cwd()

  local git = Command "git"
  local output, err = git:arg({ "rev-parse", "--show-toplevel" }):cwd(tostring(cwd)):output()

  if not output then
    ya_notify("Error: " .. err, LOGLEVEL.error)
    return
  end

  local result = output.stdout:match("^%s*(.-)%s*$"):gsub("[\n\r]+", " ") --[[@as string]]

  -- Check if we are already in the root dir.
  if url_eq(cwd, result) then
    ya_notify("Already in the root dir of this repo.", LOGLEVEL.info)
    return
  end

  -- Try to change dirs.
  ya.emit("cd", { result })

  local latest_cwd = fs.cwd()

  if not url_eq(cwd, latest_cwd) then
    -- We've changed directories, return.
    return
  end

  -- Before confirming we're not in a repo,
  -- check to see if we are in a .git dir, since the result of
  -- rev-parse --show-toplevel will error if its not ran in a work tree.

  local ok, pcall_result = pcall(url_recursive_search, latest_cwd, ".git")

  if ok and pcall_result ~= nil then
    ya.emit("cd", { pcall_result })
  elseif isempty(result) then
    -- Finally, confirm the initial result is empty, we are not in a git repository.
    ya_notify("Not in a git repository.", LOGLEVEL.error)
  end
end

return M
