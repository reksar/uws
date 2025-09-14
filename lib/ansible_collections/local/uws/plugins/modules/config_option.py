# This is the doc for the related action plugin.

from __future__ import annotations


DOCUMENTATION = r'''
---
name: config_option

short_description:
    Ensure a config option is unique within the config or INI file.

description:
    Like the "ansible.builtin.lineinfile" module, but ensures that no more than
    one option with the specified name is exists in the config file. If the
    option value is not provided, then option will be removed. Otherwise, the
    option will be added or changed. If there are several options with the same
    specified name are exists, they will be removed before adding a new entry.
    This is the difference from the "lineinfile", that can only rewrite the
    first or the last occurence. A config file is expected to be either of
    format of the plain "key=value" pair per line, or the INI format (same as
    the "key=value" pairs, but have sections in addition).

options:
    file:
        description: A config file of INI format or similar.
        type: path
        required: true
    option:
        description:
            Option name. Will be the unique within the file.
        type: str
        required: true
    value:
        description:
            Option value. All existing options with the specified `option` name
            will be deleted, excluding the one with the specified `value`.
            If the value is not provided, then all `option`s will be deleted.
            To set an empty config '<option>=', set the empty string here.
        type: str
    section:
        description:
            INI section name without the brackets. Must be unique within the
            file. If provided, the INI section will be created if not exists,
            then the option will be added to this section and removed from
            others.
        type: str
'''

EXAMPLES = r'''
- name: Remove all entries of `ll` alias
  local.uws.config_option:
    file: ~/.bash_aliases
    option: alias ll

# Instead of previous example, the "alias ll=" will be added.
- name: Add the `ll` alias with the empty value
  local.uws.config_option:
    file: ~/.bash_aliases
    option: alias ll
    value: ""

# The "alias ll='ls -l --color=auto'" line will be added.
- name: Add the `ll` alias
  local.uws.config_option:
    file: ~/.bash_aliases
    option: alias ll
    value: "'ls -l --color=auto'"

- name: Add the "option=''" to 'some.conf' file
  local.uws.config_option:
    file: some.conf
    option: option
    value: "''"

- name: Add the 'db_user=root' to [database] INI section
  local.uws.config_option:
    file: valid.ini
    section: database
    option: db_name
    value: root
'''

RETURN = r'''#'''
