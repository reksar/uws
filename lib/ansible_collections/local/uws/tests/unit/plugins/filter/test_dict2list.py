import pytest

import ansible_collections.local.uws.tests.util.path_hook

from ansible.errors import AnsibleFilterError
from ansible_collections.local.uws.tests.util import is_ansible_doc_available
from ansible_collections.local.uws.plugins.filter.dict2list import dict2list


def test_doc():
    assert is_ansible_doc_available('local.uws.list2dict')


def test_list_from_values_by_default():
    src = {'key1': 'val1', 'key2': 'val2', 'key3': 'val3'}
    assert dict2list(src) == ['val1', 'val2', 'val3']


def test_list_from_values():
    src = {'key1': 'val1', 'key2': 'val2', 'key3': 'val3'}
    assert dict2list(src, 'values') == ['val1', 'val2', 'val3']


def test_list_from_keys():
    src = {'key1': 'val1', 'key2': 'val2', 'key3': 'val3'}
    assert dict2list(src, 'keys') == ['key1', 'key2', 'key3']


def test_empty_list_from_empty_dict():
    assert dict2list({}) == []
    assert dict2list({}, 'values') == []
    assert dict2list({}, 'keys') == []
