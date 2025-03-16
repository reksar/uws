# SEE: doc is in the related module.

from __future__ import annotations

import re
from ansible_collections.local.uws.plugins.util.action import ActionModuleBase


class ActionModule(ActionModuleBase):

    @ActionModuleBase.prerun
    def run(self, status):

        file = self.arg('file')
        option = self.arg('option')
        value = self.arg('value', None)
        txt = self.run_lookup_plugin('file', [file])[0]
        regex = self.name_value_re(option)
        pattern = re.compile(regex, flags=re.MULTILINE)
        entries = pattern.findall(txt)

        if int(value is None) < len(entries):
            status = self.sanitize(file, regex)
            if status['rc'] != 0:
                return status

        if value is not None:
            status = self.ensure_option(option, value)

        return status


    def name_value_re(self, option):
        """
        Regex for the `option` name and value pair.
        """

        # Delimiter between the option name and value:
        separator = '='

        # An oneline commet starts with this prefix:
        comment = '#'

        # NOTE: No spaces between the `option` and `separator`.
        return f"^\\s*(?!{comment}\\s*)({option}){separator}(.*)"


    def sanitize(self, file, regex):
        return self.run_module('replace', {
            'path': file,
            'regexp': regex,
            'replace': '',
        })

    def ensure_option(self, option, value):
        # TODO: use lineinfile
        pass

