from operator import methodcaller
from jinja2.filters import FILTERS
from ansible.plugins.list import list_plugins


def find_plugin_name(name, plugins: dict):
    has_name = methodcaller('endswith', f".{name}")
    matched_names = filter(has_name, plugins.keys())
    return next(matched_names, None)


def get_ansible_filter(name):
    fullname = '.' in name and name
    collections = None if fullname else ('ansible.builtin', 'ansible.legacy')
    plugins = list_plugins('filter', collections)
    plugin_name = fullname or find_plugin_name(name, plugins)
    plugin = plugins.get(plugin_name)
    if plugin:
        file, instance = plugin
        return instance.j2_function


def get_filter(name):
    return FILTERS.get(name) or get_ansible_filter(name)
