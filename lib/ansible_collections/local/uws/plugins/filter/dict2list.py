# SEE: doc is in the related module.

from ansible.errors import AnsibleFilterError


def dict2list(_input: dict, part: str = 'values') -> list:
    if part not in ('values', 'keys'):
        raise ValueError("Invalid part! Must be 'values' or 'keys'.")
    return list(getattr(_input, part)())


class FilterModule():
    def filters(self):
        return {'dict2list': dict2list}
