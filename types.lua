---@meta

---@class Ya
---@field mgr_emit fun(cmd: string, args: { [integer|string]: Sendable }): nil # Send a command to the [manager] without waiting for the executor to execute.
---@field notify fun(opts: { title: string, content: string, timeout: number?, level: string? }): nil # Send a foreground notification to the user.

---@class Fs
---@field cwd fun(): (Url?, Error?) # Get the current working directory (CWD) of the process.
---@field unique_name fun(url: Url?): (Url?, Error?) # Get a unique name from the given url to ensure it's unique in the filesystem

---@alias Sendable
---| nil
---| boolean
---| number
---| string
---| Url
---| table<Sendable> # table or nested tables, with the above types as values

---@class Error: string

---@see https://yazi-rs.github.io/docs/plugins/types#shared.url
---@class Url
---@field ends_with fun(self: Url, another: Url|string): boolean # Whether the url ends with another Url or a string of url.
---@field parent Url? # The parent directory Url if any, otherwise nil.

---@see https://yazi-rs.github.io/docs/plugins/utils#command
---@class Command<T>: { [string]: T }
---@field args fun(self: self, arg: string[]): self # Append multiple arguments to the command.
---@field cwd fun(self: self, dir: string): self # Set the current working directory of the command.
---@field output fun(self: self): (Output?, Error?) # Spawn the command and wait for it to finish.

---@see https://yazi-rs.github.io/docs/plugins/utils#output
---@class Output
---@field status string # Status of the child process.
---@field stdout string # Stdout of the child process.
---@field stderr string # Stderr of the child process.

---@see https://yazi-rs.github.io/docs/plugins/utils#status
---This object represents the exit status of a child process, and it is created by wait(), or output().
---@class Status
---@field success boolean # Whether the child process exited successfully.
---@field code integer? # Exit code of the child process.
