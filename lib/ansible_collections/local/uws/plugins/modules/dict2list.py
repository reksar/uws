# This is the doc for the related filter plugin.

DOCUMENTATION = r'''
---
name: dict2list

description:
    Makes a list from dict values (by default) or keys.

positional: _input, part

options:
    _input:
        description:
            A dict to be transformed to list.
        type: dict
        required: true
    part:
        description:
            A part of the dict, that should be transformed to list.
        type: str
        required: false
        choices: ['values', 'keys']
        default: 'values'

plugin_type: filter
'''

EXAMPLES = r'''
# a_list: []
a_list: "{{ {'key1': 'val'} | local.uws.dict2list }}"
'''

RETURN = r'''
_value:
    description: A list of values or keys.
    type: list
'''
