"""Cut the sprites sprites.toml lists out of a tgstation checkout.

Usage: nix run .#website-sprites -- <tgstation checkout>, from the
repository's root. The checkout must be at the revision sprites.toml names,
so that the sprites can be cut again exactly as they are.
"""

import pathlib
import re
import subprocess
import sys
import tomllib

from PIL import Image

MANIFEST = pathlib.Path("website/sprites/sprites.toml")
OUT = pathlib.Path("website/static/sprites")
# The order a state's directions come in within each of its frames.
DIRS = ["south", "north", "east", "west",
        "southeast", "southwest", "northeast", "northwest"]


def read_dmi(path):
    """Return a .dmi's image and its states' first image indices and dirs."""
    image = Image.open(path)
    meta = image.info["Description"]
    width = int(re.search(r"\twidth = (\d+)", meta).group(1))
    height = int(re.search(r"\theight = (\d+)", meta).group(1))
    states, index = {}, 0
    for block in re.split(r"\nstate = ", meta)[1:]:
        name = re.match(r'"(.*)"', block).group(1)
        dirs = int(re.search(r"\tdirs = (\d+)", block).group(1))
        frames = int(re.search(r"\tframes = (\d+)", block).group(1))
        states.setdefault(name, (index, dirs))
        index += dirs * frames
    return image.convert("RGBA"), width, height, states


def cut(checkout, sprite):
    image, width, height, states = read_dmi(checkout / sprite["icon"])
    columns = image.width // width
    out = Image.new("RGBA", (width, height))
    for layer in sprite["layers"]:
        first, dirs = states[layer]
        direction = min(DIRS.index(sprite.get("dir", "south")), dirs - 1)
        index = first + sprite.get("frame", 0) * dirs + direction
        x, y = index % columns * width, index // columns * height
        out.alpha_composite(image.crop((x, y, x + width, y + height)))
    if sprite.get("trim"):
        out = out.crop(out.getbbox())
    return out


def main():
    checkout = pathlib.Path(sys.argv[1])
    manifest = tomllib.loads(MANIFEST.read_text())
    revision = subprocess.run(
        ["git", "-C", checkout, "rev-parse", "HEAD"],
        check=True, capture_output=True, text=True,
    ).stdout.strip()
    if revision != manifest["revision"]:
        sys.exit(f"{checkout} is at {revision}, not {manifest['revision']}")
    OUT.mkdir(exist_ok=True)
    for name, sprite in manifest["sprites"].items():
        cut(checkout, sprite).save(OUT / f"{name}.webp", lossless=True)


if __name__ == "__main__":
    main()
