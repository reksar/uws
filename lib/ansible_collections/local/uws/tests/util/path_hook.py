# Import this module to use a regular Ansible imports in unit tests, when unit
# tests are running by using the uws local Python venv.
#
# In 'ansible_test/_util/target/pytest/plugins/ansible_pytest_collections.py'
# the function `pytest_configure()` installs the `_AnsibleCollectionFinder`,
# which is doing a real dirt within the `sys.path_hooks`, complementing pytest
# hooks.
#
# After all, a regular imports like `import ansible.<...>` in unit tests does
# not work, because all 'ansible.*' imports are intercepted.

import importlib
import sys

from functools import partial
from operator import methodcaller
from pathlib import Path


SITES = tuple(Path(i) for i in sys.path if i.endswith('/site-packages'))


class RegularAnsibleModuleFinder(importlib.abc.PathEntryFinder):
    def find_spec(fullname, target=None):
        if is_ansible_module(fullname):
            spec_for_name = partial(spec, fullname)
            specs_by_site = map(spec_for_name, SITES)
            specs = filter(None, specs_by_site)
            return next(specs, None)


def spec(fullname, site):
    base_path = site.joinpath(*name_chain(fullname))
    files = filter(methodcaller('is_file'), (
        base_path.with_suffix('.py'),
        base_path.joinpath('__init__.py'),
        base_path.with_name('__init__.py'),
    ))
    file = next(files, None)
    return importlib.util.spec_from_file_location(fullname, file)


def name_chain(fullname):
    return fullname.split('.')


def is_ansible_module(fullname):
    return name_chain(fullname)[0] == 'ansible'


def is_ansible_test_path(path):
    return Path(path).full_match('**/ansible-test-*/**')


def path_hook(path):
    if is_ansible_test_path(path):
        return RegularAnsibleModuleFinder
    raise ImportError(f"Propagate the '{path}' path.", path=path)


sys.path_hooks.insert(0, path_hook)

