# UNIX workspace

Configures a Linux environment. Some configs work on Cygwin as well.

## Usage

### Setup Linux environment

`./uws set [playbook]`

Where the `[playbook]` is a playbook file basename or relative path without the
exstension.

Examples:
    * `./uws set` is the same as `./uws set main`
    * `./uws set app`
    * `./uws set app/tmux`

### Run tests

`./uws test [bash|ansible]`

# Layout

**uws** - entry point.

**base** - to init base working environment and Ansible.

**lib** - common scripts to be used in other scripts.

**lib/ansible** - local Ansible modules and plugins.

**util** - general-purpose executable utility scripts.

`tests/bash/run.sh` - test some bash functions from `lib`.

## Util

### `util/sysdisk.sh`

Partitioning the entire specified disk to be used as the system Linux disk.

Allows to install Linux on the partitioned disk next.

Run the `util/sysdisk.sh` without args to see the help.

### `util/arch/install.sh`

Some automatization for installing the Arch Linux to a system disk specified
as argument.

Uses `util/arch/install/settings.sh`. In addition, asks some questions at the
start of the installation.

### `util/terminal/*`

`colortest` - show color palette.

`fonttest-nerd` - show nerd font icons.

`utf8.txt` - a lot of UTF-8 printable characters.

### `util/font/update`

Update some font files in the 'res/font'. Some content may not be affected by
this util. The update process differs for different fonts: for some fonts just
a new version will be downloaded, while some fonts may be patched after.

#### 'util/font/<name>/*'

Entry point to get a new font files:

```bash
make \
  --silent \
  --makefile=<abspath>/uws/util/font/<name>/Makefile \
  --directory=uws/res/font
```

NOTE: The path to a *Makefile* must be absolute. The path to 'res/font' can be
relative when running from the *uws* root dir.

NOTE: This only updates the *uws* resources, it does not install the fonts.
Install with `uws set locale`.

The `util/font/<name>/download <destination dir>` is used to download a font
<name> archive.

# Notes

Copy / edit inplace the system-wide config files.

Make symbolic links to a user config files.

## Ansible playbooks

### Utility message types (glossary)

Prefixes of a `- name:` values.

**/!/** - Ensure. If something needs to be done, try to do it. Fail otherwise.

**/*/** - Setting.

**/?/** - Search.

**/./** - Store value in variable.

**/../** - Store a collection of values in variable. Or map a collection to
           make some data transformation.

**/%/** - Filter a collection.

**/v/** - Download.
