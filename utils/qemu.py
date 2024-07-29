import argparse
import os
import re
import stat
import subprocess
from functools import cache
from functools import lru_cache
from functools import partial
from functools import reduce
from itertools import chain
from itertools import filterfalse
from itertools import repeat
from itertools import starmap
from operator import and_
from operator import is_
from operator import attrgetter as attr
from operator import contains
from operator import itemgetter
from operator import methodcaller as method
from pathlib import Path

item_0 = itemgetter(0)
item_1 = itemgetter(1)


QEMU_SYSTEM="qemu-system-"
QEMU_SYSTEM_ALIASES = {
    "x64": "x86_64",
    "x86": "i386",
    "x32": "i386",
}
RAM_DEFAULT = "2G"


class ArgParser(argparse.ArgumentParser):

    def __init__(self):

        super().__init__(
            description="QEMU runner",
            usage=(
                "qemu [system] {options} {-h | --help}\n" +
                "testing: python -m doctest qemu.py {-v}"
            ),
        )

        system_choices = QemuSystem.available_choices()
        additional_system_help = system_choices and (
            f"There are '{QEMU_SYSTEM}*' executables are available, so you" +
            f" can also specify one of these values: {system_choices}."
        ) or ""

        # NOTE: Ommiting the `choices` arg here allows to specify an arbitrary
        # QEMU system executable.
        self.add_argument(
            "system",
            help=f"QEMU system executable. {additional_system_help}",
        )

        self.add_argument(
            "-cdrom",
            metavar="path",
            help="Path to a CD-ROM ISO image or physical drive.",
        )

        self.add_argument(
            "-disk",
            metavar=("path", "size"),
            nargs="+",
            action="append",
            help="Physical disk device or disk image path.",
        )

        # TODO
        """
        self.add_argument(
            "-flash",
            metavar="path",
            action="append",
            help="Physical USB flash drive or disk image path.",
        )
        """

        self.add_argument(
            "-ram",
            metavar="size",
            default=RAM_DEFAULT,
            help=f"RAM size. Default: '{RAM_DEFAULT}'.",
        )

        self.add_argument(
            "-port",
            metavar="host_port:guest_port",
            help="Port forwarding.",
        )

        # SEE: https://www.qemu.org/docs/master/system/introduction.html#virtualisation-accelerators
        self.add_argument(
            "-accel",
            metavar="type",
            default=QemuSystem.default_accel(),
            help=(
                f"Virtualization acceleration." +
                f" Default is '{QemuSystem.default_accel()}'." +
                 " Set 'no' to disable."
            ),
        )

        self.add_argument(
            "-bios",
            metavar="file",
            nargs="?",
            default=True,
            help=(
                "Boots via UEFI by default. You can specify a BIOS file or" +
                " ommit the file path to boot via default QEMU BIOS."
            ),
        )


    def separate(self):
        args, argv = self.parse_known_args()
        kwargs = args._get_kwargs()
        is_option = pipe(self.is_option_name, item_0)
        positionals = tuple(filterfalse(is_option, kwargs))
        options = tuple(filter(is_option, kwargs))
        return positionals, options, argv


    @cache
    def is_option_name(self, name):
        return name in self.option_names()


    @lru_cache(maxsize=1)
    def option_names(self):
        option_re = re.compile(f"^[{self.prefix_chars}]+(.*)")
        matches = map(option_re.fullmatch, self._option_string_actions.keys())
        return tuple(map(item_1, matches))


class PositionalsAdapter:

    @staticmethod
    def adapt(name, value):
        """
        >>> PositionalsAdapter.adapt("unknown", "value")
        'value'
        """
        default = lambda _: value
        adapter = getattr(PositionalsAdapter, name, default)
        return adapter(value)


    @staticmethod
    def system(value):
        if value not in QemuSystem.available_choices():
            raise Exception(f"Unknown QEMU system '{value}'")
        return f"{QEMU_SYSTEM}{QEMU_SYSTEM_ALIASES.get(value, value)}"


class OptionAdapter:

    @staticmethod
    def adapt(name, value):
        """
        >>> OptionAdapter.adapt("unknown_option", "some value")
        ('-unknown_option', 'some value')
        >>> OptionAdapter.adapt("unknown_option", ("some", "values"))
        ('-unknown_option', 'some', '-unknown_option', 'values')
        >>> OptionAdapter.adapt("ram", "2G")
        ('-m', '2G')
        >>> OptionAdapter.adapt("accel", "kvm")
        ('-accel', 'kvm')
        >>> OptionAdapter.adapt("accel", "no")
        ''
        """
        regular = OptionAdapter.to_regular(name, value)
        return regular and OptionAdapter.to_shell(*regular) or ""


    @staticmethod
    def to_regular(name, value):
        """
        >>> OptionAdapter.to_regular("unknown_option", "some value")
        ('unknown_option', 'some value')
        >>> OptionAdapter.to_regular("unknown_option", ("some", "values"))
        ('unknown_option', ('some', 'values'))
        >>> OptionAdapter.to_regular("ram", "2G")
        ('m', '2G')
        """
        default = lambda _: (name, value)
        adapter = getattr(OptionAdapter, name, default)
        return adapter(value)


    @staticmethod
    def to_shell(name, value):
        """
        >>> OptionAdapter.to_shell("name", "value")
        ('-name', 'value')
        >>> OptionAdapter.to_shell("name", ("value1", "value2"))
        ('-name', 'value1', '-name', 'value2')
        """
        assert type(value) in (str, bool, list, tuple), type(value)
        values = type(value) in (str, bool) and (value,) or value
        assert all(type(i) in (str, bool) for i in values)
        names = repeat(f"-{name}", len(values))
        return tuple(chain.from_iterable(zip(names, values)))


    @staticmethod
    def accel(value: str):
        """
        >>> OptionAdapter.accel("no")
        False
        >>> OptionAdapter.accel("kvm")
        ('accel', 'kvm')
        """
        return (value != "no") and ("accel", value)


    @staticmethod
    def disk(pathlist: list):
        return "drive", [QemuDisk(path)() for path in pathlist]


    @staticmethod
    def cdrom(path: str):
        return "drive", QemuDrive(path).qemu_options()


    @staticmethod
    def port(ports: str):
        """
        >>> OptionAdapter.port("2222:22")
        ('nic', 'user,hostfwd=tcp::2222-:22')
        """
        host, guest = ports.split(":")
        return "nic", f"user,hostfwd=tcp::{host}-:{guest}"


    @staticmethod
    def ram(size: str):
        """
        >>> OptionAdapter.ram("2G")
        ('m', '2G')
        """
        return "m", size


    @staticmethod
    def bios(value):
        return Bios.adapt(value)


class Middleware:
    """
    To handle a bunch of related args.
    """

    @staticmethod
    def args(positionals, options, argv):
        return Middleware.boot(positionals, options, argv)


    @staticmethod
    def boot(positionals, options, argv):
        """
        >>> Middleware.boot([],[],["-cdrom", "CD.iso", "-boot", "d"])
        ([], [], ['-cdrom', 'CD.iso', '-boot', 'd'])
        >>> Middleware.boot([],[],["-boot", "c"])
        ([], [], ['-boot', 'c'])
        >>> Middleware.boot([],[],["-cdrom", "CD.iso"])
        ([], [], ['-cdrom', 'CD.iso', '-boot', 'once=d'])
        """

        def has(name):
            return any((
                Middleware.has_option(options, name),
                Middleware.has_argv(argv, name),
            ))

        if has("cdrom") and not has("boot"):
            return positionals, options, argv + ["-boot", "once=d"]
        return positionals, options, argv


    @staticmethod
    def has_option(options, name):
        """
        >>> Middleware.has_option([("n1", "v1"), ("n2", "v2")], "nope")
        False
        >>> Middleware.has_option([("n1", "v1"), ("n2", "v2")], "v1")
        False
        >>> Middleware.has_option([("n1", "v1"), ("n2", "v2")], "n1")
        True
        """
        names = map(item_0, options)
        return name in names


    @staticmethod
    def has_argv(argv, name):
        """
        >>> Middleware.has_argv(["a", "b", "c"], "nope")
        False
        >>> Middleware.has_argv(["a", "b", "c"], "a")
        False
        >>> Middleware.has_argv(["a", "-b", "c"], "b")
        True
        """
        names = filter(method("startswith", "-"), argv)
        return f"-{name}" in names


class QemuSystem:

    @staticmethod
    @lru_cache(maxsize=1)
    def available():
        qemu_system = re.compile(f"^{QEMU_SYSTEM}(\w+)$")
        qemu_matches = filter(None, map(qemu_system.fullmatch, exe_names()))
        return tuple(map(item_1, qemu_matches))


    @staticmethod
    @lru_cache(maxsize=1)
    def available_aliases(available_systems):
        defined_systems = QEMU_SYSTEM_ALIASES.values()
        defined_aliases = QEMU_SYSTEM_ALIASES.keys()
        system_by_alias = QEMU_SYSTEM_ALIASES.get
        is_system_available = partial(contains, available_systems)
        aliased_systems = tuple(filter(is_system_available, defined_systems))
        is_system_aliased = partial(contains, aliased_systems)
        is_alias_available = pipe(is_system_aliased, system_by_alias)
        return tuple(filter(is_alias_available, defined_aliases))


    @staticmethod
    def available_choices():
        systems = QemuSystem.available()
        aliases = QemuSystem.available_aliases(systems)
        return *aliases, *systems


    @staticmethod
    @lru_cache(maxsize=1)
    def default_accel():
        # TODO: whpx for Windows, tcg for ARM x32
        return "kvm"


class DiskImageMixin:

    def format(self):
        ext = self.extension()
        return ext.startswith("qcow") and ext or "raw"


    def extension(self):
        match = re.search("\.(qcow2?|img|iso)$", self.path.suffix)
        return match and match[1] or ""


class QemuDrive(DiskImageMixin):

    def __init__(self, path):
        self.path = Path(path)
        self.is_dir = self.path.is_dir
        self.is_file = self.path.is_file
        assert self.path.exists(), path


    def qemu_options(self):
        return ",".join((
            self.file(),
            self.format(),
            *filter(None, (
                self.media(),
                self.interface(),
            )),
        ))


    def file(self):
        opt = self.is_dir() and "fat:rw:" or ""
        return f"file={opt}{self.path}"


    def format(self):
        return f"format={super().format()}"


    def media(self):
        if self.is_cdrom():
            return "media=cdrom"
        if self.is_disk():
            return "media=disk"


    def interface(self):
        if self.is_disk() and self.is_device():
            return "if=ide"


    def is_disk(self):
        return not self.is_cdrom() and any((
            self.is_device(),
            self.is_dir(),
            self.extension(),
        ))


    def is_cdrom(self):
        return mime_type(str(self.path)).strip().endswith("iso9660-image")


    def is_device(self):
        return self.path.is_block_device() or self.path.is_char_device()


class QemuDisk(DiskImageMixin):

    def __init__(self, options):
        i = iter(options)
        self.path = Path(next(i))
        self.size = next(i, "")


    def __call__(self):
        self.ensure()
        return QemuDrive(self.path).qemu_options()


    def ensure(self):
        if self.path.exists():
            return
        if not self.size:
            if self.path.match("/dev/*"):
                raise FileNotFoundError(f"No disk device: '{self.path}'!")
            raise ValueError(
                f"Unable to create the '{self.path}' disk image, because" +
                f" the size is not provided!"
            )
        if not is_exe("qemu-img"):
            raise FileNotFoundError("No 'qemu-img' cmd!")
        status = shell(
            "qemu-img",
            "create",
            "-f",
            self.format(),
            str(self.path),
            self.size
        )
        if status.returncode:
            raise Exception(status.stderr.decode())


class Bios:

    default_file = Path("qemu", "OVMF.fd")

    @staticmethod
    def adapt(arg):
        bios = Bios.default() or Bios.local() if arg is True else arg
        if bios:
            return "bios", bios
        print("ERR: Unable to use a BIOS/UEFI!")


    @staticmethod
    def default():
        # TODO: crossplatform
        usr_share = Path("/usr/share")
        bios = usr_share.joinpath(Bios.default_file)
        if bios.is_file():
            print("INFO: Using default QEMU UEFI.")
            return str(bios)
        print(f"WARN: Unable to use default UEFI '{bios}'!")


    @staticmethod
    def local():

        config = Sys.config_home()
        if not config:
            print("ERR: Unable to detect a home config path!")
            return

        bios = config.joinpath(Bios.default_file)
        if Path(bios).is_file():
            print("INFO: Using local UEFI.")
            return bios

        # TODO: Try to get OVMF from
        # https://www.qemu-advent-calendar.org/2014/download/qemu-xmas-uefi-zork.tar.xz

        print(f"WARN: Unable to use local UEFI '{bios}'!")


class Sys:

    default_config_dir = ".config"

    @staticmethod
    def config_home():
        return Sys.config_home_from_env() or Sys.config_home_heuristic()


    @staticmethod
    def config_home_from_env():
        for env, postprocess in (
            (
                "XDG_CONFIG_HOME",
                lambda x: x,
            ),
            (
                "HOME",
                lambda x: (x, Bios.default_config_dir),
            ),
            (
                "XDG_CONFIG_DIRS",
                lambda x: x.split(":")[0],
            ),
        ):
            path = os.getenv(env)
            if path:
                return Path(postprocess(path))
            print(f"WARN: no ${env} env var!")


    @staticmethod
    def config_home_heuristic():
        home_match = re.match(r"(/home/\w+)/", __file__)
        if home_match:
            return Path(home_match[1], Sys.default_config_dir)
        print("WARN: current script has not a '/home/<user>/' prefix!")


def pipe(*functions):
    """
    `pipe(f2,f1)(x)` is the same as the composition `f2(f1(x))`, e.g.:
    >>> pipe(bin,ord)('!') == bin(ord('!'))
    True
    """
    return partial(reduce, lambda x, f: f(x), functions[::-1])


def shell(*cmd):
    return subprocess.run((cmd), capture_output=True, text=True)


def has_exe_stat(file: str | Path):
    return os.path.isfile(file) and os.stat(file).st_mode & stat.S_IXUSR


def is_exe(exe: str | Path):
    return has_exe_stat(exe) or any(filter(str(exe).__eq__, exe_names()))


@lru_cache(maxsize=1)
def exe_names():
    files = chain.from_iterable(map(os.scandir, os.get_exec_path()))
    exe_files = filter(has_exe_stat, files)
    return tuple(map(os.path.basename, exe_files))


def mime_type(file: str):
    # TODO: crossplatform
    assert is_exe("file")
    status = shell("file", "--mime-type", "--brief", file)
    if status.returncode:
        raise Exception(status.stderr.decode())
    return status.stdout


def shell_args():

    def to_shell(adapter, kwargs):
        return starmap(adapter, filter(item_1, kwargs))

    positionals, options, argv = Middleware.args(*ArgParser().separate())
    shell_positionals = to_shell(PositionalsAdapter.adapt, positionals)
    shell_options = to_shell(OptionAdapter.adapt, options)
    return *shell_positionals, *chain.from_iterable(shell_options), *argv


def main():
    args = shell_args()
    print("Running QEMU", args)
    status = shell(*args)
    print(status.returncode and status.stderr or status.stdout)


if __name__ == "__main__":
    main()

