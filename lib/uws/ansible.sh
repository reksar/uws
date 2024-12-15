. "$(cd "$(dirname $BASH_SOURCE[0])/.." && pwd)/notifications.sh"

ensure_ansible() {

  which ansible-playbook &> /dev/null || {

    INFO "Installing Ansible"

    pip install ansible || {
      ERR "Unable to install Ansible!"
      return 1
    }

    which ansible-playbook &> /dev/null || {
      ERR "Ansible is unavailable!"
      return 2
    }
  }

  OK "Ansible found."
  return 0
}
