import pytest
from collections import namedtuple

import ansible_collections.local.uws.tests.util.path_hook

from ansible_collections.local.uws.plugins.util.filter import get_filter


def test_get_filter_jinja():
    """
    Some filters in YAML can be specified by a simple name, but they are not a
    part of the 'ansible.builtin' collection. They are Jinja filters.
    """

    lower = get_filter('lower')
    assert callable(lower)
    assert lower('Foo BAR') == 'foo bar'

    replace = get_filter('replace')
    assert callable(replace)

    # NOTE: The `do_replace` filter is decorated with the `@pass_eval_context`,
    # this is the mock for that context.
    ContextMock = type('ContextMock', (), {'autoescape': False})

    assert replace(ContextMock(), 'foo bar', 'foo', 'fizz') == 'fizz bar'


def test_get_filter_ansible_builtin():
    """
    Getting an Ansible filter function by a simple name - without the
    collection prefix 'ansible.builtin'. These filters can be found in the
    `ansible/plugins/filter/`.
    """

    basename = get_filter('basename')
    assert callable(basename)
    assert basename('etc/asdf/foo.txt') == 'foo.txt'

    flatten = get_filter('flatten')
    assert callable(flatten)
    test_data = [1, 2, [3, [4, 5]], 6]
    assert flatten(test_data) == [1, 2, 3, 4, 5, 6]
    assert flatten(test_data, 1) == [1, 2, 3, [4, 5], 6]

    ternary = get_filter('ternary')
    assert callable(ternary)
    assert ternary(True, 'yes', 'no') == 'yes'
    assert ternary(False, 'yes', 'no') == 'no'


def test_get_filter_ansible_builtin_prefix():
    """
    Getting an Ansible filter function by a full name - with the collection
    prefix 'ansible.builtin'. These filters can be found in the
    `ansible/plugins/filter/`.
    """

    basename = get_filter('ansible.builtin.basename')
    assert callable(basename)
    assert basename('etc/asdf/foo.txt') == 'foo.txt'

    flatten = get_filter('ansible.builtin.flatten')
    assert callable(flatten)
    test_data = [1, 2, [3, [4, 5]], 6]
    assert flatten(test_data) == [1, 2, 3, 4, 5, 6]
    assert flatten(test_data, 1) == [1, 2, 3, [4, 5], 6]

    ternary = get_filter('ansible.builtin.ternary')
    assert callable(ternary)
    assert ternary(True, 'yes', 'no') == 'yes'
    assert ternary(False, 'yes', 'no') == 'no'
