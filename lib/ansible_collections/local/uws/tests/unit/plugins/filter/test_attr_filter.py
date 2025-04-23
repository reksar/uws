import pytest

import ansible_collections.local.uws.tests.util.path_hook

from ansible.errors import AnsibleFilterError
from ansible_collections.local.uws.tests.util import is_ansible_doc_available
from ansible_collections.local.uws.plugins.filter.attr_filter import attr_filter


def test_doc():
    assert is_ansible_doc_available('local.uws.attr_filter')


def test_jinja_filters():

    assert attr_filter({'txt': 'Foo BAR'}, 'txt', 'lower') \
        == {'txt': 'foo bar'}

    original = {'x': 1, 'y': [2, 3, 4]}
    result = attr_filter(original, 'y', 'reverse')
    assert tuple(result['y']) == (4, 3, 2)


def test_ansible_simple_filters():

    assert attr_filter({'int': 1, 'bool': 1}, 'bool', 'ansible.builtin.bool') \
        == {'int': 1, 'bool': True}

    original = {'full': '/etc/asdf/foo.txt', 'base': '/etc/asdf/foo.txt'}
    expected = {'full': '/etc/asdf/foo.txt', 'base': 'foo.txt'}
    assert attr_filter(original, 'base', 'basename') == expected


def test_ansible_parametric_filters():

    assert attr_filter({'x': [1, 2, [3, [4, 5]], 6]}, 'x', 'flatten', 1) \
        == {'x': [1, 2, 3, [4, 5], 6]}

    assert attr_filter({'x': 'foo bar'}, 'x', 'regex_replace', 'foo', 'fizz') \
        == {'x': 'fizz bar'}


def test_returns_original_if_attr_not_exists():
    original = {'a': 1, 'b': 2}
    assert attr_filter(original, 'c', 'bool') == original


def test_returns_original_if_attr_not_passed():
    original = {'a': 1, 'b': 2}
    assert attr_filter(original, '', 'bool') == original


def test_error_on_invalid_filter():

    with pytest.raises(AnsibleFilterError):
        attr_filter({}, '', 'not_existing_filter')

    with pytest.raises(AnsibleFilterError):
        attr_filter({'x': 1}, '', 'not_a_filter')


def test_error_on_recursive_call():

    with pytest.raises(ValueError):
        attr_filter({}, '', 'local.uws.attr_filter')

    with pytest.raises(ValueError):
        attr_filter({'x': 1}, 'a', 'local.uws.attr_filter')
