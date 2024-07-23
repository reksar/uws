import subprocess
from argparse import ArgumentParser
from pathlib import Path


REMOTE_REPO = "rsync://mirror.23m.com/archlinux"
DEFAULT_FILTER = Path(Path(__file__).resolve().parent, "syncrepo.filter")
BASE_RSYNC_ARGS = (
    "--recursive",
    "--hard-links",
    "--safe-links",
    "--copy-links",
    "--times",
    "--delete-after",
    "--delete-excluded",
    "--stats",
    "--human-readable",
    "--info=progress2",
)


def args():
    argp = ArgumentParser(
        description=(
            f"Sync local Arch Linux repo with '{REMOTE_REPO}'." +
            " Uses filter by default, but can sync the whole repo."
        ),
    )
    argp.add_argument(
        "local_repo",
        help="Path to a local Arch repo dir",
    )
    argp.add_argument(
        "-i", "--info",
        dest="dry",
        action="store_true",
        help="Do not sync files, just show info.",
    )
    filter_file = argp.add_mutually_exclusive_group()
    filter_file.add_argument(
        "-f", "--filter",
        dest="filter_file",
        default=DEFAULT_FILTER,
        help=(
            "Path to a file will be used as the filter for 'rsync'." +
            f" Default: '{DEFAULT_FILTER}'."
        ),
    )
    filter_file.add_argument(
        "-w", "--whole",
        dest="filter_file",
        action="store_false",
        help="Do not use a filter, sync the whole repo.",
    )
    return argp.parse_args()


def shell(cmd):
    return subprocess.run(cmd, capture_output=True, shell=True, text=True)


def rsync(local_repo, filter_file=False, dry=False):
    filter_arg = f"--filter='merge {filter_file}'" if filter_file else ""
    dry_arg = "--dry-run" if dry else ""
    options = filter(None, (*BASE_RSYNC_ARGS, filter_arg, dry_arg))
    return shell(" ".join(("rsync", *options, REMOTE_REPO, local_repo)))


def main():
    a = args()
    status = rsync(a.local_repo, a.filter_file, a.dry)
    if status.returncode:
        raise Exception(status.stderr)
    print(status.stdout)


if __name__ == "__main__":
    main()

