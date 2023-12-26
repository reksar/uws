# UNIX workspace

Configures a Linux environment (mostly Debian based). Some configs work on
Cygwin as well.

## Base steps

1. Ensure `sudo`.

2. Ensure `python --version` >= `min_python_version` from `settings.yml`.

    2.1. The default value of `min_python_version` is **3**. Used when the
    `min_python_version` is not set or invalid.

    2.2. If `min_python_version` is **3**, it prefers to install Python with
    the system package manager.

    2.3. Uses `pyenv` to install non-system Python. When unable to install the
    system Python or if `min_python_version` is specified more precisely.

      * Ensure `pyenv`.

      * Install Python with `pyenv`.

## Structure

`uws` - entry point.

`base` - to init base working environment and Ansible.

`lib` - non-executable common scripts. Must be included in other scripts.

`utils` - executable common scripts.

`tests/bash/run.sh` - test some bash functions from `lib`.
