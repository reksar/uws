# SEE: doc is in the related module.

from ansible.errors import AnsibleFilterError


def list2dict(_input: list, keys: list[str]) -> dict:
    if len(keys) != len(_input):
        raise AnsibleFilterError("Unequal keys and items length!")
    return dict(zip(keys, _input))


class FilterModule():
    def filters(self):
        return {'list2dict': list2dict}
