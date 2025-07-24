# Features

Battery status in the `tmux` status line (see below).

## Hotkeys
Prefix: `Alt+\`
New window: `Alt+L`
Next / prev window: `Alt+.` / `Alt+,`
Move window: `Alt+;` / `Alt+'`
Horizontal / vertical split: `Alt+-` / `Alt+=`
Kill pane: `Alt+Z`
Next / prev pane: `Ctrl+.` / `Alt+,`
Move pane: `Ctrl+;` / `Ctrl+'`
Resize pane: `Alt+[Arrow]`

# Config

Quick setup: `./uws set tasks/app/tmux`.

Main tasks: `roles/workstation/tasks/app/tmux.yml`.

The `config/tmux.conf` is the Jinja template.

Instead of default "{{var}}" Jinja placeholder, the "<<var>>" is used.

## Available template vars

### `<<battery>>`

When a `battery` system executable is available, it is considered the battery
status util. The `<<battery>>` will be replaced with the part of the status
line, that is contains the `tmux` call to `battery` util and its `stdout` will
be shown inplace.

When no `battery` executable found, the `<<battery>>` placeholder will be
replaced with the empty string.

### `<<temperature>>`

By analogue with the `<<battery>>`, this is the status of the CPU temperature.
