import os
import re
import subprocess
from argparse import ArgumentParser
from operator import itemgetter as item
from pathlib import Path


REMOTE_REPO = "rsync://mirror.23m.com/archlinux"
DEFAULT_FILTER = Path(__file__).resolve().parent.joinpath("syncrepo.filter")
PKG_EXT = ".pkg.tar.zst"
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


def args_middleware(args):
    args.local_repo = Path(args.local_repo).resolve()
    args.filter_file = Path(args.filter_file).resolve()
    return args


def preprint(buffer):
    """
    Prints buffers. Returns the printed text.
    """
    def printer(line):
        print(line, end="", flush=True)
        return line
    return "".join(map(printer, buffer))


def shell_proc(cmd):
    return subprocess.Popen(
        cmd,
        shell=True,
        text=True,
        bufsize=1,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
    )


def shell_preprint(cmd):
    with shell_proc(cmd) as proc:
        stdout = preprint(proc.stdout)
        stderr = proc.stderr.read()
    proc.stdout = stdout
    proc.stderr = stderr
    return proc


def rsync(local_repo, filter_file=False, dry=False):
    filter_arg = f"--filter='merge {filter_file}'" if filter_file else ""
    dry_arg = "--dry-run" if dry else ""
    args = filter(None, (*BASE_RSYNC_ARGS, filter_arg, dry_arg))
    return " ".join(("rsync", *args, REMOTE_REPO, str(local_repo)))


def norepos(repo):
    """
    If an Arch Linux repo is fully synced, the repo dirs, such as 'core' or
    'extra' will contain the repo database in addition to packages.

    Norepos - are repo dirs containing packages matching the 'pkg_pattern',
    without a database. There should also be no subdirs in.
    """
    pkg_pattern = re.compile(f"{re.escape(PKG_EXT)}(\\.sig)?$")
    def is_norepo(contents):
        _, dirs, files = contents
        return not dirs and files and all(map(pkg_pattern.search, files))
    return tuple(map(item(0), filter(is_norepo, os.walk(repo))))


def create_repo_db(norepo):
    repo_match = re.search(r"/(\w+)/os/\w+$", norepo)
    if not repo_match:
        raise ValueError(f"Unable to parse repo name '{norepo}'")
    name = repo_match[1]
    return f"repo-add {norepo}/{name}.db.tar.gz {norepo}/*{PKG_EXT}"


def main(local_repo=None, filter_file=False, dry=False):

    assert Path(local_repo).is_dir(), local_repo
    assert not filter_file or Path(filter_file).is_file(), filter_file

    print(f"Syncing '{local_repo}' with '{REMOTE_REPO}' ...")
    if filter_file:
        print(f"Using rsync filter '{filter_file}'")
    proc = shell_preprint(rsync(local_repo, filter_file, dry))
    if proc.returncode:
        raise Exception(proc.stderr)
    print("Synced!")

    print("Checking uncomplete repos ...")
    for repo in norepos(local_repo):
        print(f"Creating repo database in '{repo}'")
        if not dry:
            proc = shell_preprint(create_repo_db(repo))
            if proc.returncode:
                raise Exception(proc.stderr)
    print("Completed!")


if __name__ == "__main__":
    main(**vars(args_middleware(args())))

