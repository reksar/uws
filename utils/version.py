import sys
min_version = sys.argv[1]
sys.exit(int(sys.version_info[:3] < tuple(map(int, min_version.split(".")))))
