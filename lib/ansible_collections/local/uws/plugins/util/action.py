import functools
from ansible.plugins.action import ActionBase


class PluginMixin:

    def run_module(self, module: str, args: dict):
        return self._execute_module(
            module_name=module,
            module_args=args,
            task_vars=self.task_vars,
            tmp=self.tmp,
        )

    def run_lookup_plugin(self, plugin: str, args: dict):
        return self._shared_loader_obj.lookup_loader.get(
            plugin,
            task=self._task.copy(),
            connection=self._connection,
            play_context=self._play_context,
            loader=self._loader,
            templar=self._templar,
            shared_loader_obj=self._shared_loader_obj,
        ).run(args, variables=self.task_vars)


    def run_action_plugin(self, plugin: dict, args: dict):
        task = self._task.copy()
        task.args = args
        return self._shared_loader_obj.action_loader.get(
            plugin,
            task=task,
            connection=self._connection,
            play_context=self._play_context,
            loader=self._loader,
            templar=self._templar,
            shared_loader_obj=self._shared_loader_obj,
        ).run(task_vars=self.task_vars)


class ActionModuleBase(ActionBase, PluginMixin):

    def prerun(run):
        """
        Wraps the `run` function of an Ansible action to do some Ansible shit
        before. The `run` function accepts the initial `status`, passed by
        Ansible, and returns it changed/unchanged or replaced.
        """
        @functools.wraps(run)
        def ansible_shit(self, tmp=None, task_vars=None):
            self.tmp = tmp
            self.task_vars = task_vars
            status = super(ActionModuleBase, self).run(tmp, task_vars)
            return run(self, status)
        return ansible_shit


    @property
    def arg(self):
        return self._task.args.get
