# Features

The `tmux` status line can contain status of system temperature and battery,
depending on the available system executables.

## Hotkeys
Prefix: `Alt+\`
Command prompt: `Alt+I`
New window: `Alt+L`
Next / prev window: `Alt+.` / `Alt+,`
Move window: `Alt+;` / `Alt+'`
Horizontal / vertical split: `Alt+-` / `Alt+=`
Kill pane: `Alt+Z`
Next / prev pane: `Ctrl+.` / `Ctrl+,`
Move pane: `Ctrl+;` / `Ctrl+'`
Resize pane: `Alt+[Arrow]`
Move pane to the specified window: `Alt+M`

### Useful defaults
List hotkeys: `Prefix+?`
Detach: `Prefix+D`
Rename current session: `Prefix+$`
Switch layout: `Prefix+Space`

[See how to bind an UTF-8 character over 8-bit:]
(https://superuser.com/questions/517836/tmux-trying-to-bind-utf8-key)

# Useful commands
Switch layout: `next-layout`
Create new session: `new` or `new -s <name>`
List sessions: `ls`
Attach session: `attach -t <session>`
Rename current session: `rename-session <new name>`
Rename arbitrary session: `rename-session -t <current name> <new name>`
Rename current window: `rename-window <new name>`

# Config

Run: `./uws set roles/tmux`.

Note that the `templates/tmux.conf` is the Jinja template! The "<<var>>"
Jinja placeholder is used instead of default "{{var}}"!

## Template vars

### `<<battery>>`

When a `battery` system executable is available, it is considered the battery
status util. The `<<battery>>` will be replaced with the part of the status
line, that is contains the `tmux` call to `battery` util and its `stdout` will
be shown inplace.

When no `battery` executable found, the `<<battery>>` placeholder will be
replaced with the empty string.

### `<<temperature>>`

By analogue with the `<<battery>>`, this is the status of the CPU temperature.
