# This is the doc for the related filter plugin.

DOCUMENTATION = r'''
---
name: attr_filter

description:
    Apply the specified filter to the dict item, specified by a key name.
    If the specified key is not exists in the dict, the resulting dict will be
    same as the original.

positional: _input, attr_name, filter_name

options:
    _input:
        description:
            A dict, which item should be filtered.
        type: dict
        required: true
    attr_name:
        description:
            The key name, which corresponding item should be filtered.
        type: str
        required: true
    filter_name:
        description:
            A filter name.
        type: str
        required: true

plugin_type: filter
'''

EXAMPLES = r'''
original_dict:
    key1: item1
    key2: ITEM2

# new_dict == {key1: item1, key2: item2}
new_dict: "{{ original_dict | attr_filter('key2', 'lower') }}"
'''

RETURN = r'''
_value:
    description: A dict with the filtered item.
    type: dict
'''
