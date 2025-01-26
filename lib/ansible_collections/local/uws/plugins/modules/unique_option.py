#!/usr/bin/python

# Make coding more python3-ish, this is required for contributions to Ansible.
from __future__ import (absolute_import, division, print_function)
__metaclass__ = type


DOCUMENTATION = r'''
---
module: unique_option

short_description: Ensure a config option is unique within the config file.

description:
    Like the "ansible.builtin.lineinfile" module, but ensures that only one
    option with the specified name is exists. If the option is already exists,
    it will be rewritten. But, if there are several options are exists, they
    will be deleted. This is the difference from the
    "ansible.builtin.lineinfile", that can only rewrite the first or last line.

options:
    file:
        description: A config file.
        required: true
        type: str
    line:
        description:
            Option line "<option>=<value>", where <option> must be unique
            within the file.
        required: true
        type: str
'''

EXAMPLES = r'''
- name: Add bash alias `ll`
  unique_option:
    file: ~/.bash_aliases
    line: alias ll='ls -l --color=auto'
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
