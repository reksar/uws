# Ansible Collection `local.uws`.

# Testing

All tests are designed to run locally using the Python venv.

[See](https://docs.ansible.com/ansible/latest/dev_guide/developing_collections_testing.html#testing-collections)

# Unit tests

To run unit tests in current project configuration, the `` is required.

## Adding unit tests

> You must place unit tests in the appropriate `tests/unit/plugins/` directory.
> For example, you would place tests for `plugins/module_utils/foo/bar.py` in
> `tests/unit/plugins/module_utils/foo/test_bar.py` or
> `tests/unit/plugins/module_utils/foo/bar/test_bar.py`. 

> You can specify Python requirements in the `tests/unit/requirements.txt`.

> # Adding integration tests

> You must place integration tests in the appropriate
> `tests/integration/targets/` directory.
>
> For module integration tests, you can
> use the module name alone. For example, you would place integration tests for
> `plugins/modules/foo.py` in a directory called
> `tests/integration/targets/foo/`.
>
> For non-module plugin integration tests,
> you must add the plugin type to the directory name. For example, you would
> place integration tests for `plugins/connections/bar.py` in a directory
> called `tests/integration/targets/connection_bar/`. For lookup plugins, the
> directory must be called `lookup_foo`, for inventory plugins,
> `inventory_foo`, and so on.

> You can write two different kinds of integration tests:
>
> * Ansible role tests run with `ansible-playbook` and validate various
>   aspects of the module. They can depend on other integration tests (usually
>   named `prepare_bar` or `setup_bar`, which prepare a service or install a
>   requirement named `bar` in order to test module `foo`) to set-up required
>   resources, such as installing required libraries or setting up server
>   services.
>
> * `runme.sh` tests run directly as scripts. They can set up inventory files,
>   and execute `ansible-playbook` or `ansible-inventory` with various
>   settings.
