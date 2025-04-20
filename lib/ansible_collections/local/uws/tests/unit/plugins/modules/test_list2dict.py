import pytest

import ansible_collections.local.uws.tests.util.path_hook

from ansible.errors import AnsibleFilterError
from ansible_collections.local.uws.tests.util import assert_doc
from ansible_collections.local.uws.plugins.filter.list2dict import list2dict


def test_doc():
    assert_doc('local.uws.list2dict')


def test_valid_data():

    assert list2dict(['item'], keys=['key']) \
        == {'key': 'item'}

    assert list2dict([1, 2, 3], keys=['a', 'b', 'c']) \
        == {'a': 1, 'b': 2, 'c': 3}


def test_empty():
    assert list2dict([], []) == {}


def test_not_enough_keys():

    with pytest.raises(AnsibleFilterError) as err:
        list2dict([1, 2], keys=[])

    with pytest.raises(AnsibleFilterError) as err:
        list2dict([1, 2], keys=['key'])


def not_enough_items():

    with pytest.raises(AnsibleFilterError) as err:
        list2dict([], keys=['key'])

    with pytest.raises(AnsibleFilterError) as err:
        list2dict([1, 2], keys=['key', 'yet another key', 'and keeeey'])
