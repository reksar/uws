# Unix workspace

Many users use a dotfiles repo to store their settings for Unix. Here is the
next evolutionary step of their solution: automation with Ansible.

The main purpose is to configure an Arch Linux desktop (or laptop, or even
tablet) for personal use. But it is possible to use a separate Ansible role to
configure a separate part of an Unix system.

Some configs work on Cygwin as well.

Some configs are depends on the hardware configuration, that must be done first.

# Usage

## Examples

```bash
# Show help:
./uws

# Setup the desktop (default target):
./uws set

# Setup the workstation (configure system without a GUI):
./uws set roles/workstation

# Configure bash on the remote host via SSH:
./uws set roles/bash admin@10.10.1.1:2222

# Run tasks from the 'tasks/app/vim.yml' file found in all roles in 'local.uws'
# namespace:
./uws set tasks/app/vim

# Local alias for ansible-doc:
./uws doc -h

# List all Ansible plugins:
./uws doc -l

# List Ansible local plugins:
./uws doc -l local.uws

# Show help for the 'local.uws.config_option' Ansible plugin:
./uws doc local.uws.config_option

# Run all tests:
./uws test

# Run tests for the Python util scripts:
./uws test py

# Run tests for bash utils:
./uws test sh

# Test (unit and integration) the 'local.uws' Ansible collection:
./uws test ansible
```

Some Ansible tasks may require a *sudo* password to `become` a root. You can
put it to the `.become` file at the project root. Otherwise Ansible will ask
for it.

Global settings for playbooks and roles: `config/uws.yml`. Other settings are
stored in a role 'vars/'.

# CLI tools

The `wallpaper` to set an arbitrary wallpaper file or pick one (by name or
randomly) from `~/.local/share/wallpapers/`.

## Notes

All executables that should be available in `$PATH`, should be installed to the
`/usr/local/bin` in according with *FHS*.

# Project layout

**uws** - Entry point.

**config/** - Configuration files. Store all in one place.

**lib/** - Library of scripts to be included in other scripts. **NOTE:** strive
to only **define** common functions here. Make them clear and without the
side-effects, like user messages.
  * **ansible_collections/** - local Ansible collections.

**res/** - Resources and assets.

**tests/**
  * **bash/** - Tests the bash scripts from **util/**, **lib/**.
    * **run.sh** - Entry point.
  * **util/** - tests for utility scripts.

**base** - to init working the base environment and Ansible.
*NOTE: Refactoring is needed.*

## Util

General-purpose executable utility scripts.

### `util/disk/`

`encrypt.sh` - encrypt the entire disk or partition with LUKS.

`system.sh` - partitioning the entire specified disk to be used as the system
disk for Linux.

`release.sh` - easely free and release a specified disk when it busy and not
available for partitioning and encryption.

### `util/grub.sh`

GRUB setup on a specified system disk, partitioned using `util/disk/system.sh`
or similar way.

### `util/arch/install.sh`

Some automatization for installing the Arch Linux to a system disk specified
as argument.

Uses `util/arch/install/settings.sh`. In addition, asks some questions at the
start of the installation.

### `util/terminal/`

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

## Ansible collections

### Utility message types (glossary)

Prefix in the Ansible task `- name:` value:

**/!/** - Ensure. If something needs to be done, try to do it. Fail otherwise.

**/*/** - Setting / option.

**/?/** - Search / read.

**/./** - Store value in variable.

**/../** - Store / transform a collection of values in variable.

**/%/** - Filter a data collection.

**/v/** - Download.

**/>/** - Copy.

**/x/** - Delete.
