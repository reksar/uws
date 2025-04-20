import ansible_collections.local.uws.tests.util.path_hook

from ansible_collections.local.uws.tests.util import assert_doc


def test_doc():
    assert_doc('local.uws.config_option')
