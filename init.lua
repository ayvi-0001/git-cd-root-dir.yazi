local F = {}

TIMEOUT_NOTIFY = 2.0

---@param str string
local isempty = function(str)
  return str == nil or str == ""
end

---@param url1 string|Url
---@param url2 string|Url
-- Url: https://yazi-rs.github.io/docs/plugins/types#shared.url
local _url_eq = function(url1, url2)
  if type(url1) == "string" then
    url1 = Url(url1)
  end
  if type(url2) == "string" then
    url2 = Url(url2)
  end
  return (select(1, fs.unique_name(url2)) == fs.unique_name(url1))
end

---@param content string
---@param level string = "info"
local ya_notify = function(content, level)
  ya.notify {
    title = "git-cd-root-dir",
    content = content,
    level = level or "info",
    timeout = TIMEOUT_NOTIFY,
  }
end

-- local get_cwd = ya.sync(function() return tostring(cx.active.current.cwd) end)

function F:entry(job)
  local cwd = select(1, fs.cwd())

  local output =
    select(1, Command("git"):args({ "rev-parse", "--show-toplevel" }):cwd(tostring(cwd)):output())

  local result = output.stdout:match("^%s*(.-)%s*$"):gsub("[\n\r]+", " ")

  -- Check if we are already in the root dir.
  if _url_eq(cwd, result) then
    ya_notify("Already in the root dir of this repo.")
    return
  end

  -- Try to change dirs.
  ya.manager_emit("cd", { result })

  local latest_cwd = select(1, fs.cwd())

  -- We've changed directories, return.
  if not _url_eq(cwd, latest_cwd) then
    return
  end

  -- Before confirming we're not in a repo,
  -- check to see if we are in the .git dir, since the result of
  -- rev-parse --show-toplevel will error if its not ran in a work tree.

  -- Check parent directories to see if we are in .git/
  local function recurse_dir_search(path)
    if path:ends_with ".git" then -- Found the .git dir.
      return path:parent()
    elseif path:parent() ~= nil then -- Keep checking.
      return recurse_dir_search(path:parent())
    else
      return nil
    end
  end

  ok, pcall_result = pcall(recurse_dir_search, latest_cwd)

  if ok and pcall_result ~= nil then
    ya.manager_emit("cd", { pcall_result })
    return
  elseif isempty(result) then
    -- Finally, confirm the initial result is empty,
    -- We are not in a git repository.
    ya_notify("Not in a git repository.", "error")
    return
  end
end

return F
