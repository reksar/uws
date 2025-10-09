# SEE: doc is in the related module.

from __future__ import annotations

import os
import re
import ansible_collections.local.uws.plugins.util.status as action_status
from base64 import b64decode
from ansible_collections.local.uws.plugins.util.action import ActionModuleBase


class ActionModule(ActionModuleBase):

    @ActionModuleBase.prerun
    def run(self, status):

        self.setup()

        status = self.ensure_file()
        if status:
            return status

        status = self.ensure_section()
        if not action_status.is_ok(status):
            return status

        return self.ensure_option()


    def setup(self):

        self.file = str(self.arg('file'))
        self.option = str(self.arg('option'))
        self.section = str(self.arg('section', ''))

        raw_value = self.arg('value', None)
        self.value = None if raw_value is None else str(raw_value)

        # Separator between the `option` name and `value`.
        # NOTE: No spaces around the separator.
        self.separator = '='

        # An oneline commet in the config file should start with this prefix.
        # TODO: Allow it after the option value in the same line.
        self.comment = '#'

        re_opt = re.escape(self.option)
        re_sep = re.escape(self.separator)
        re_val = re.escape(self.value or '')

        # The specified `option` with any value.
        self.re_option = rf'^\s*({re_opt}){re_sep}.*'

        # The specified `option` with the specified `value`.
        self.re_option_value = rf'^\s*({re_opt}{re_sep}{re_val}\b)'

        self.re_section = rf'^\s*(\[{re.escape(self.section)}\])'

        # Any line that is not starts with '['.
        re_not_section = r'(?:(?!^\s*\[).*\n)'

        # The specified `option` with any value inside the specified `section`.
        self.re_option_in_section = (
            rf'{self.re_section}\s*\n{re_not_section}*?{self.re_option}'
        )


    def ensure_section(self):

        if not self.section or self.entry_count(self.re_section) == 1:
            return action_status.not_changed()

        # TODO: Remove all related options when removing the section.
        status = self.remove(self.re_section)
        if not action_status.is_ok(status):
            return status

        return self.write(f"[{self.section}]")


    def ensure_option(self):

        status = self.remove_excess_options()
        if not action_status.is_ok(status) or self.value is None:
            return status

        # Here we got 0 or 1 option entry.

        with_value_count = self.entry_count(self.re_option_value)
        assert with_value_count in (0, 1)

        in_section_count = self.entry_count(self.re_option_in_section)
        assert in_section_count in (0, 1)

        is_already_set = with_value_count and not self.section

        is_already_set_in_section = (
            self.section and in_section_count and with_value_count
        )

        if is_already_set or is_already_set_in_section:
            return status

        # Here we got 0 or 1 `option` entry that is not set, i.e. its `value`
        # differs from the specified one.

        status = self.remove(self.re_option)
        if not action_status.is_ok(status):
            return status

        new_option_value = f"{self.option}{self.separator}{self.value}"
        return self.write(new_option_value, bool(self.section))


    def remove_excess_options(self):
        """
        WARN: Don't always remove all existing entries to maintain idempotency!
        """

        # Count entries of the specified `option` name.
        total_count = self.entry_count(self.re_option)

        # Count entries of the specified `option` with the specified `value`.
        with_value_count = self.entry_count(self.re_option_value)

        # Count entries of the specified `option` name with any value inside
        # the specified INI `section`.
        #
        # NOTE: If there are several `option` name entries within the specified
        # `section`, the count will be 1 anyway. The count can be > 1 when
        # there are several sections with the same name are exists and contains
        # the `option`.
        in_section_count = self.entry_count(self.re_option_in_section)

        # When `value` is not specified but the `section` is, it is needed to
        # remove only the `option` from the specified section, but all other
        # `option` entries must not be changed.
        #
        # TODO: Do not change entries outside the `section`.
        is_need_to_unset_in_section = (
            self.value is None and self.section and in_section_count
        )

        # When `value` and `section` are not specified, it is needed to remove
        # all the `option` entries.
        is_need_to_unset = (
            self.value is None and not self.section and total_count
        )

        # When there are several `option` entries.
        #
        # TODO: Take into acctount the section.
        has_option_duplicates = total_count > 1

        # When there are several `option` and `value` duplicates.
        has_entire_duplicates = self.value is not None and with_value_count > 1

        is_need_to_remove = any((
            is_need_to_unset_in_section,
            is_need_to_unset,
            has_option_duplicates,
            has_entire_duplicates,
        ))

        return (
            self.remove(self.re_option) if is_need_to_remove
            else action_status.not_changed()
        )


    def remove(self, regex):
        return self.run_module('replace', {
            'path': self.file,
            'regexp': regex,
            'replace': '',
        })


    def write(self, line, use_section=False):
        return self.run_module('lineinfile', {
            'path': self.file,
            'line': line,
            'insertafter': (use_section and self.re_section) or 'EOF',
        })


    def entry_count(self, regex):
        pattern = re.compile(regex, flags=re.MULTILINE)
        entries = pattern.findall(self.config_text())
        return len(entries)


    def config_text(self):

        # The file lookup only works on local host.
        if 'local' in self._connection.ansible_aliases:
            return self.run_lookup_plugin('file', [self.file])[0]

        # WARN: The result is not a standard module execution status!
        result = self.run_module('slurp', {'src': self.file})

        if not 'content' in result:
            raise LookupError(f"Cannot read the remote file '{self.file}'.")

        if result.get('encoding') != 'base64':
            raise ValueError(f"Cannot decode the remote file '{self.file}'.")

        return b64decode(result['content']).decode('utf-8')


    def ensure_file(self):
        if os.path.exists(self.file):
            if os.path.isdir(self.file):
                return action_status.fail('Got a dir instead of a file!')
        else:

            if self.value is None:
                return action_status.not_changed()

            try:
                os.makedirs(os.path.dirname(self.file), exist_ok=True)
                open(self.file, 'x').close()
            except Exception as e:
                return action_status.fail(repr(e))
