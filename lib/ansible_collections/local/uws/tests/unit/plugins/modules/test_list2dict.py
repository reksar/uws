import os
import pytest
import re
import subprocess
import ansible_collections.local.uws.tests.util.path_hook
from pathlib import Path
from ansible.errors import AnsibleFilterError
from ansible_collections.local.uws.plugins.filter.list2dict import list2dict


def test_doc():

    plugin = 'local.uws.list2dict'

    # Similar to the shell `ansible-doc $plugin`.
    #
    # 0th arg passed to the `main()` will be ignored, see:
    # `ansible/cli/__init__.py::parse()`
    #
    read_doc = f"from ansible.cli.doc import main; main(['', '{plugin}'])"

    # Prepend `sys.path` with these paths to allow the regular imports.
    # Similar to shell `. lib/uws/ansible.sh && ensure_ansible`.
    site = Path(os.environ['ANSIBLE_TEST_ANSIBLE_LIB_ROOT']).parent
    lib = Path(os.environ['ANSIBLE_COLLECTIONS_PATH'])

    result = subprocess.run(
        [
            'python', '-c', read_doc,
        ],
        env={
            'PYTHONPATH': f"{site}:{lib}",
        },
        capture_output=True,
        text=True,
    )

    assert result.returncode == 0
    assert re.match(f"> MODULE.*{plugin}", result.stdout)


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
