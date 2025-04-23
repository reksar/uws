# SEE: doc is in the related module.

from ansible.errors import AnsibleFilterError
from ansible_collections.local.uws.plugins.util.filter import get_filter


def attr_filter(
    _input: dict,
    attr_name: str,
    filter_name: str,
    /,
    *filter_options
) -> dict:

    if filter_name == 'local.uws.attr_filter':
        raise ValueError("Recursive call 'local.uws.attr_filter'!")

    filter_function = get_filter(filter_name)

    if not filter_function:
        raise AnsibleFilterError(f"Filter '{filter_name}' is not found!")

    if attr_name not in _input:
        return _input

    attr_value = _input[attr_name]
    new_value = filter_function(attr_value, *filter_options)
    new_item = {attr_name: new_value}
    return _input | new_item


class FilterModule():

    def filters(self):
        return {'attr_filter': attr_filter}
