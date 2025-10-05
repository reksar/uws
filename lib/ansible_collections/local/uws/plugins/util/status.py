def not_changed(msg='Not changed.'):
    return {
        'msg': msg,
        'rc': 0,
        'changed': False,
        'failed': False,
    }


def fail(msg, rc=1):
    if not rc:
        raise ValueError('Error RC is false!')
    return {
        'msg': msg,
        'rc': rc,
        'changed': False,
        'failed': True,
    }


def is_ok(status):
    """
    The `status` is a dict, that can be empty or have some fields. Most common
    fields are:
        * msg: str
        * failed: bool
        * changed: bool (can be ommited when failed)
        * invocation: dict (args passed to an action)
        * rc: int
        * diff: list[dict,...]
        * _ansible_parsed: bool (WTF?)

    NOTE: I did not find any docs for the `status` and these fields are
    empirically explored.
    """
    return not (status.get('failed', False) and status.get('rc', 0))
