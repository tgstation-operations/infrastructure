# Every age file is encrypted to exactly the keys its secrets.nix lists. A key
# added there without a rekey cannot decrypt the file, and a key removed
# without one still can. Read from the plaintext header, where an ssh
# recipient stanza names its key by the first four bytes of the key's SHA-256.
import base64
import hashlib
import json
import os
import subprocess
import sys


def tag(key):
    blob = base64.b64decode(key.split()[1])
    return base64.b64encode(hashlib.sha256(blob).digest()[:4]).decode().rstrip("=")


def label(key):
    parts = key.split()
    return parts[2] if len(parts) > 2 else f"{parts[0]} ...{parts[1][-8:]}"


def recipients(path):
    with open(path, "rb") as f:
        lines = f.read(1 << 16).split(b"\n")
    if lines[0] != b"age-encryption.org/v1":
        raise ValueError("not a binary age file")
    found = []
    for line in lines[1:]:
        if line.startswith(b"---"):
            return found
        if line.startswith(b"-> "):
            kind, *args = line[3:].decode("ascii", "replace").split(" ")
            if not kind.endswith("-grease"):
                found.append((kind, args[0] if kind.startswith("ssh-") else None))
    raise ValueError("header has no end")


indexes = subprocess.run(
    ["git", "ls-files", "-z", "--", ":(glob)**/secrets.nix"],
    check=True, capture_output=True, text=True,
).stdout.split("\0")

status = 0
for index in filter(None, indexes):
    expr = f"builtins.mapAttrs (_: v: v.publicKeys) (import ./{index})"
    declared = json.loads(subprocess.run(
        ["nix-instantiate", "--eval", "--strict", "--json", "-E", expr],
        check=True, capture_output=True, text=True,
    ).stdout)
    for name, keys in sorted(declared.items()):
        path = os.path.join(os.path.dirname(index), name)
        if not os.path.exists(path):
            continue
        try:
            found = recipients(path)
        except ValueError as e:
            print(f"{path}: {e}")
            status = 1
            continue
        want = {(key.split()[0], tag(key)): key for key in keys}
        have = set(found)
        missing = [label(want[k]) for k in want if k not in have]
        extra = sorted(f"{kind}:{t}" if t else kind for kind, t in have - want.keys())
        if missing or extra:
            status = 1
            print(f"{path}: needs a rekey")
            if missing:
                print(f"  not readable by: {', '.join(sorted(missing))}")
            if extra:
                print(f"  still readable by {len(extra)} unlisted keys: {', '.join(extra)}")
sys.exit(status)
