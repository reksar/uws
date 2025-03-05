#!/usr/bin/python

# Make coding more python3-ish, this is required for contributions to Ansible.
from __future__ import (absolute_import, division, print_function)
__metaclass__ = type


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
            Option name. Will be the unique within the file. All existing
            options with the specified name will be removed before adding a new
            entry.
        type: str
        required: true
    value:
        description:
            Option value. Will be ignored when state is "absent". When empty
            and the state is "present", the "<option>=" line will be added
            (see EXAMPLES).
        type: str
    state:
        description:
            Add or remove the option.
        type: str
        choices: [present, absent]
        default: present
'''

EXAMPLES = r'''
- name: Remove all entries of `ll` alias
  local.uws.config_option:
    file: ~/.bash_aliases
    option: alias ll
    state: absent

# Instead of previous example, the state is "present" by default and the
# "alias ll=" will be added to ~/.bash_aliases instead of removing the alias.
- name: Add alias with the empty value
  local.uws.config_option:
    file: ~/.bash_aliases
    option: alias ll

# The "alias ll='ls -l --color=auto'" line will be added.
- name: Add bash alias `ll`
  local.uws.config_option:
    file: ~/.bash_aliases
    option: alias ll
    value: "'ls -l --color=auto'"
'''

RETURN = r'''#'''


from ansible.plugins.action import ActionBase


class ActionModule(ActionBase):

    def run(self, tmp=None, task_vars=None):

        super(ActionModule, self).run(tmp, task_vars)
        module_args = self._task.args.copy()

        return self._execute_module(
            module_name='lineinfile',
            module_args=module_args,
            task_vars=task_vars,
            tmp=tmp,
        )
