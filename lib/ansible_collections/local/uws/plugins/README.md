# Plugins Directory

This directory can be used to ship various plugins inside an Ansible
collection. Each plugin is placed in a folder that is named after the type of
plugin it is in. It can also include the `module_utils` and `modules` directory
that would contain module utils and modules respectively.

Here is an example directory of the majority of plugins:

```
└── plugins
    ├── action
    ├── become
    ├── cache
    ├── callback
    ├── cliconf
    ├── connection
    ├── filter
    ├── httpapi
    ├── inventory
    ├── lookup
    ├── module_utils
    ├── modules
    ├── netconf
    ├── shell
    ├── strategy
    ├── terminal
    ├── test
    └── vars
```

A full list of plugin types can be found at
[Working With Plugins](https://docs.ansible.com/ansible-core/2.18/plugins/plugins.html).

# Modules

Modules are callable scripts and starts with a shebang. If it is the Python
module, i.e. shebang is `#!/usr/bin/python` or `#!/usr/bin/env python`,
the `main()` function must be called and must return a JSON result.

# Actions

Actions, instead of modules, does not starts with a shebang and have no
`main()` function.

## Standard implementation

They just implements the `run()` method of `ActionBase` ABC.

The `ActionBase` class has the `_execute_module()` method, but has no method
for running an action. See example in `ansible/plugins/action/shell.py`.

The doc for an action must be placed separatelly in the `plugins/modules`.
For example, the doc for the `shell` action is placed in
`ansible/modules/shell.py`.

## uws implementation

Instead of using the `ActionBase` ABC, use the `ActionModuleBase` from the
`local/uws/plugins/util/action.py` and decorate the `run()` method with the
`@ActionModuleBase.prerun`.
