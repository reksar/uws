import ansible_collections.local.uws.tests.util.path_hook

from ansible_collections.local.uws.tests.util import is_ansible_doc_available


def test_doc():
    assert is_ansible_doc_available('local.uws.config_option')
