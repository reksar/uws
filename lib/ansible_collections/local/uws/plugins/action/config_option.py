# NOTE: The doc is in the related module.

from __future__ import annotations
#from ansible.errors import AnsibleActionFail
from ansible.plugins.action import ActionBase


class ActionMixin:

    def _execute_action(self, name, args=None, task_vars=None):

        action = self._shared_loader_obj.action_loader.get(
            name,
            task=self._subtask(args),
            connection=self._connection,
            play_context=self._play_context,
            loader=self._loader,
            templar=self._templar,
            shared_loader_obj=self._shared_loader_obj,
        )

        return action.run(task_vars=task_vars)

    def _subtask(self, args=None):

        task = self._task.copy()

        if args is not None:
            task.args = args

        return task


class ActionModule(ActionBase, ActionMixin):

    def run(self, tmp=None, task_vars=None):
        super(ActionModule, self).run(tmp, task_vars)

        value = self._task.args.get('value', None)

        return self._execute_action('debug', args={'msg': value}, task_vars=task_vars)
