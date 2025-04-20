import os
import pytest
import re
import subprocess
import ansible_collections.local.uws.tests.util.path_hook
from pathlib import Path


def assert_doc(name):
    """
    Assetions to check that the documentation `uws doc <name>` is available.

    Import this in the tests and run it in a test function where these
    assertions should be checked.
    """

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
