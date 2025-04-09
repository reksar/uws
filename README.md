# UNIX workspace

Configures a Linux environment. Some configs work on Cygwin as well.

## Usage

### Setup the Linux environment

`./uws set` - run the main playbook. Same as `./uws set main`.

#### Specify a playbook

`./uws set <playbook>`

Where the `<playbook>` is a playbook file basename or relative path without the
exstension.

##### Examples
`./uws set app`
`./uws set app/qemu`

#### Specify a role

`./uws set roles/<role>`

Where the `<role>` can be a local role either from `playbook/roles/` or from
Ansible collections.

##### Examples

`./uws set roles/hardware` - set the hardware role placed in the `playbook` dir.

`./uws set roles/local.uws.system` - setup the Linux depending on the system
configuration. Using the role from Ansible collection `local.uws`.

### Run tests

Test the Ansible collection at `lib/ansible_collections/local/uws`:
`./uws test ansible`

Test `lib` bash scripts:
`./uws test bash`

Test `util` scripts:
run a `tests/util/*` executable

# Project layout

**uws** - Entry point.

**config/** - Configuration files. Store all in one place.

**util/** - General-purpose executable utility scripts.

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

Most of the util scripts are executable and shows the help when running without
args or with the `-h` arg.

### `util/cryptdisk.sh`

Encrypt the entire disk or partition with LUKS.

### `util/sysdisk.sh`

Partitioning the entire specified disk to be used as the system Linux disk.

Allows to install Linux on the partitioned disk next.

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

### Plugin docs

Using the `ansible-doc` for the local `ansible_collections`:

```sh
. lib/uws/ansible.sh && ensure_ansible && ansible-doc <plugin>
```

### Utility message types (glossary)

Prefixes of a `- name:` values for Ansible tasks.

**/!/** - Ensure. If something needs to be done, try to do it. Fail otherwise.

**/*/** - Setting / option.

**/?/** - Search / read.

**/./** - Store value in variable.

**/../** - Store / transform a collection of values in variable.

**/%/** - Filter a data collection.

**/v/** - Download.

**/>/** - Copy.

**/x/** - Delete.
