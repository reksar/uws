import os
import re
import subprocess
from pathlib import Path


def is_ansible_doc_available(name):
    """
    Is the documentation `uws doc <name>` available?
    """

    # Similar to the shell `ansible-doc $plugin`.
    #
    # 0th arg passed to the `main()` will be ignored, see:
    # `ansible/cli/__init__.py::parse()`
    read_doc = f"from ansible.cli.doc import main; main(['', '{name}'])"

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

    return result.returncode == 0 \
        and re.match(f"> MODULE.*{name}", result.stdout)
