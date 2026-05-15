--- @since 25.5.6

local M = {}

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

---@param s string
---@return string
local function trim_string(s)
  return s:match("^%s*(.-)%s*$"):gsub("[\n\r]+", " ")
end

---@param content any
---@param level "info"|"warn"|"error"|nil?
local ya_notify = function(content, level)
  ya.notify({
    title = "git-cd-root-dir",
    content = tostring(content),
    level = level,
    timeout = 2.0,
  })
end

---@generic T
---@param v? T
---@param err? any
---@param level? integer
---@return T
local ya_unwrap = function(v, err, level)
  if v == nil then
    ya.err(err)
    ya_notify(err, "error")
    error(err, level)
  end
  return v
end

---@overload fun(): Url
local get_cwd = ya.sync(function()
  return cx.active.current.cwd
end)

---@async
---@param job { args: { [integer|string]: Sendable? } }
function M:entry(job) ---@diagnostic disable-line: unused-local
  local cwd = get_cwd()

  local target_dir ---@type Url?

  local git = Command("git")
  local output, err_output = git:arg({ "rev-parse", "--show-toplevel" }):cwd(tostring(cwd)):output()
  output = ya_unwrap(output, err_output, 1)

  local stdout = trim_string(output.stdout)
  local stderr = trim_string(output.stderr)

  if stdout ~= "" then
    target_dir = Url(stdout)
  else
    if output.stderr ~= "" and output.stderr ~= nil then
      stderr = stderr:match("^fatal:%s+(.-)$") or stderr
      if stderr == "not a git repository (or any of the parent directories): .git" then
        return ya_notify(stderr, "error")
      end
      -- Before confirming we're not in a repo,
      -- check to see if we are in a .git dir, since the result of
      -- rev-parse --show-toplevel will error if its not ran in a work tree.
      local ok, pcall_result = pcall(url_recursive_search, Url(cwd), ".git")
      if ok and pcall_result ~= nil then
        target_dir = Url(pcall_result)
      end
    end
  end

  target_dir = ya_unwrap(target_dir, stderr, 1)

  -- Check if we were already in the root dir.
  if cwd == target_dir then
    return ya_notify("already in the top-level of the working tree", "info")
  end

  -- Try to change dirs. Cloning target_dir since passing through ya.emit transfers ownership
  ya.emit("cd", { Url(target_dir) })

  local latest_cwd = ya_unwrap(get_cwd(), "failed to get latest cwd", 1)

  if cwd ~= latest_cwd and latest_cwd == target_dir then
    -- We've successfully changed directories
    return
  end

  local msg = "fatal: something went wrong"
  ya.err("git-cd-root-dir.yazi", msg, {
    cwd = tostring(cwd),
    latest_cwd = tostring(latest_cwd),
    target_dir = tostring(target_dir),
    stdout = stdout,
    stderr = stderr,
  })
  ya_notify(msg, "error")
end

return M
