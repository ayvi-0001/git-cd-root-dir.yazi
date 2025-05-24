# git-cd-root-dir.yazi

A [yazi](https://github.com/sxyazi/yazi) plugin to cd to the root dir of a git repository.

## Install

Run one of the following commands.

### [ya package manager](https://yazi-rs.github.io/docs/cli)

```sh
ya pack -a ayvi-0001/git-cd-root-dir
```

### Linux/WSL/MSYS2/Cygwin

```sh
git clone https://github.com/ayvi-0001/git-cd-root-dir.yazi.git ~/.config/yazi/plugins/git-cd-root-dir.yazi
```

### Windows

```sh
git clone https://github.com/ayvi-0001/git-cd-root-dir.yazi.git %AppData%\yazi\config\plugins\git-cd-root-dir.yazi
```

## Usage

Add one of the following keybinds to your `keymap.toml`.

```toml
# As an inline table:
[manager]
prepend_keymap = [
  { on = ["g", "r"], run = "plugin git-cd-root-dir", desc = "Goto git root directory" }
]

# or as an array of tables:
[[manager.prepend_keymap]]
on = ["g", "r"]
run = "plugin git-cd-root-dir"
desc = "Goto git root directory"
```

The default location is `~/.config/yazi/` on Unix-like systems, and `%AppData%\yazi\config\` on Windows.
