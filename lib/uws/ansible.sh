uws="${uws:-$(cd "$(dirname $BASH_SOURCE[0])/../.." && pwd)}"

. "$uws/lib/python.sh"


configure_ansible() {

  # See https://docs.ansible.com/ansible/latest/reference_appendices/config.html
  #
  # Default paths starts with '/home/<user>/.ansible' and '/usr/share/ansible',
  # see `ansible-config dump`. They will be overridden with the env vars below.

  INFO "Configuring Ansible with env vars."

  venv_python="$(ls $uws/venv/lib)"
  venv_site="$uws/venv/$venv_python/site-packages"
  export ANSIBLE_HOME="$venv_site/ansible"

  ansible_collections="$ANSIBLE_HOME/collections"
  uws_collections="$uws/lib"
  export ANSIBLE_COLLECTIONS_PATH="$ansible_collections:$uws_collections"

  #local_uws="$uws_collections/ansible_collections/local/uws"

  #ansible_modules="$ANSIBLE_HOME/plugins/modules"
  #uws_modules="$local_uws/plugins/modules"
  #export ANSIBLE_LIBRARY="$ansible_modules:$uws_modules"

  #ansible_module_utils="$ANSIBLE_HOME/plugins/module_utils"
  #uws_module_utils="$local_uws/plugins/module_utils"
  #export ANSIBLE_MODULE_UTILS="$ansible_module_utils:$uws_module_utils"

  #ansible_actions="$ANSIBLE_HOME/plugins/action"
  #collection_actions="$local_uws/plugins/action"
  #export ANSIBLE_ACTION_PLUGINS="$ansible_actions:$collection_actions"
}


ensure_ansible() {

  ensure_venv "$uws/venv" || return 1

  which ansible-playbook &> /dev/null || {

    INFO "Installing Ansible"

    pip install ansible || {
      ERR "Unable to install Ansible!"
      return 2
    }

    which ansible-playbook &> /dev/null || {
      ERR "Ansible is unavailable!"
      return 3
    }
  }

  OK "Ansible found."

  configure_ansible

  return 0
}
