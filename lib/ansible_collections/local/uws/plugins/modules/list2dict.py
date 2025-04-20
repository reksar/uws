# This is the doc for the related filter plugin.

DOCUMENTATION = r'''
---
module: list2dict

short_description:
    Adds the specified key names to a list items.

description:
    Convert a list to dict by adding the specified key names to the list items.
    A list length must be qeual to the specified keys amount.

positional: _input

options:
    _input:
        description:
            A list to be transformed to dict.
        type: list
        required: true
    keys:
        description:
            Key names to be associated with the `_input` list items.
        type: list
        required: true

plugin_type: filter
'''

EXAMPLES = r'''
# a_dict == {'a': 1, 'b': 2, 'c': 3}
a_dict: "{{ [1, 2, 3] | local.uws.list2dict(keys=['a', 'b', 'c']) }}"
'''

RETURN = r'''
_value:
    description: A generated dict.
    type: dict
'''
