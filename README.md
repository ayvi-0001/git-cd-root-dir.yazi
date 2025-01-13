# git-cd-root-dir.yazi

A [yazi](https://github.com/sxyazi/yazi) plugin to cd to the root dir of a git repository.

## Install

Run one of the following commands.

```sh
# ya package manager
ya pack -a ayvi-0001/git-cd-root-dir

# Linux
git clone https://github.com/ayvi-0001/git-cd-root-dir.yazi.git ~/.config/yazi/plugins/git-cd-root-dir.yazi

# Windows
git clone https://github.com/ayvi-0001/git-cd-root-dir.yazi.git %AppData%\yazi\config\plugins\git-cd-root-dir.yazi
```

## Usage

Add the following keybind to your `keymap.toml`.

```toml
# as an inline-table
[manager]
prepend_keymap = [
  { on = ["g", "r"], run = "plugin git-cd-root-dir", desc = "cd to git repo root directory" }
]

# or as an array of tables
[[manager.prepend_keymap]]
on = ["g", "r"]
run = "plugin git-cd-root-dir"
desc = "cd to git repo root directory"
```
