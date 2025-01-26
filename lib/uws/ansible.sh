uws="${uws:-$(cd "$(dirname $BASH_SOURCE[0])/../.." && pwd)}"

. "$uws/lib/python.sh"


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

  INFO "Configuring Ansible with env vars."
  # See https://docs.ansible.com/ansible/latest/reference_appendices/config.html
  export ANSIBLE_COLLECTIONS_PATH="$uws/lib"
  ANSIBLE_LIBRARY="$ANSIBLE_COLLECTIONS_PATH/ansible_collections/local/uws"
  ANSIBLE_LIBRARY+="/plugins/modules"
  export ANSIBLE_LIBRARY

  return 0
}
