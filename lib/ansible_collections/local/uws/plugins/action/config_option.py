# SEE: doc is in the related module.

from __future__ import annotations

import re
from ansible_collections.local.uws.plugins.util.action import ActionModuleBase


class ActionModule(ActionModuleBase):

    @ActionModuleBase.prerun
    def run(self, status):

        file = self.arg('file')
        value = self.arg('value', None)
        option = self.arg('option')

        # Separator between the option name and value:
        separator = '='

        # An oneline commet starts with this prefix:
        comment = '#'

        # Regex for the `option` name and value pair.
        # NOTE: No spaces between the `option` and `separator`.
        regex = f"^\\s*(?!{comment}\\s*)({option}){separator}(.*)"

        pattern = re.compile(regex, flags=re.MULTILINE)
        txt = self.run_lookup_plugin('file', [file])[0]
        entries = pattern.findall(txt)

        if int(value is None) < len(entries):
            status = self.sanitize(file, regex)
            if status['rc'] != 0:
                return status

        if value is not None:
            status = self.lineinfile(file, f"{option}{separator}{value}")

        return status


    def sanitize(self, file, regex):
        return self.run_module('replace', {
            'path': file,
            'regexp': regex,
            'replace': '',
        })

    def lineinfile(self, file, line):
        return self.run_module('lineinfile', {
            'path': file,
            'line': line,
        })

