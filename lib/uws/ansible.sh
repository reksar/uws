uws="$(cd "$(dirname $(readlink -f $BASH_SOURCE[0]))/../.." && pwd)"

. "$uws/lib/python.sh"


configure_ansible() {

  # See https://docs.ansible.com/ansible/latest/reference_appendices/config.html
  #
  # Default paths starts with '/home/<user>/.ansible' and '/usr/share/ansible',
  # see `ansible-config dump`. They will be overridden with the env vars below.

  INFO "Configuring Ansible with env vars."

  local venv_python="$(ls $uws/venv/lib)"
  local venv_site="$uws/venv/$venv_python/site-packages"
  export ANSIBLE_HOME="$venv_site/ansible"

  local ansible_collections="$ANSIBLE_HOME/collections"
  local lib="$uws/lib"
  export ANSIBLE_COLLECTIONS_PATH="$ansible_collections:$lib"

  local uws_collection="$lib/ansible_collections/local/uws"

  local default_roles_paths="$ANSIBLE_HOME/roles:/usr/share/ansible/roles"
  local default_roles_paths+=":/etc/ansible/roles"
  local uws_roles_path="$uws_collection/roles"
  export ANSIBLE_ROLES_PATH="$uws_roles_path:$default_roles_paths"
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
