# NOTE: This is the doc for the related action plugin.

from __future__ import annotations


DOCUMENTATION = r'''
---
module: config_option

short_description:
    Ensure a config option is unique within the config file.

description:
    Like the "ansible.builtin.lineinfile" module, but ensures that only one
    option with the specified name is exists. If the option is already exists,
    it will be rewritten. But, if there are several options are exists, they
    will be deleted. This is the difference from the
    "ansible.builtin.lineinfile", that can only rewrite the first or last line.

options:
    file:
        description: A config file of INI format.
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
'''

EXAMPLES = r'''
- name: Remove all entries of `ll` alias
  local.uws.config_option:
    file: ~/.bash_aliases
    option: alias ll

# Instead of previous example, the "alias ll=" will be added.
- name: Add alias with the empty value
  local.uws.config_option:
    file: ~/.bash_aliases
    option: alias ll
    value: ""

# The "alias ll='ls -l --color=auto'" line will be added.
- name: Add bash alias `ll`
  local.uws.config_option:
    file: ~/.bash_aliases
    option: alias ll
    value: "'ls -l --color=auto'"
'''

RETURN = r'''#'''
