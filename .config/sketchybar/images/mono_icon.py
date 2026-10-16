#!/usr/bin/env python3
"""Turn an app icon into a white monochrome icon matching sketchybar-app-font.

The white parts of the icon are cut out and the rest becomes white, shaded by
its brightness. Writes <name>.png (focused) and <name>_dim.png (unfocused).

Usage: mono_icon.py <app.icns> <name>
"""

import os
import subprocess
import sys
import tempfile

from PIL import Image

SIZE = 64
SHADE = 0.5  # how much brighter areas fade
DIM = 0.3  # matches the unfocused workspace label alpha

icns, name = sys.argv[1], sys.argv[2]
out_dir = os.path.dirname(os.path.abspath(__file__))

with tempfile.TemporaryDirectory() as tmp:
    src = os.path.join(tmp, "src.png")
    subprocess.run(
        ["sips", "-s", "format", "png", "-Z", str(SIZE), icns, "--out", src],
        check=True,
        capture_output=True,
    )
    icon = Image.open(src).convert("RGBA")

alphas = []
for r, g, b, a in icon.getdata():
    white = max(0.0, (min(r, g, b) - 150) / 105)
    lum = (0.299 * r + 0.587 * g + 0.114 * b) / 255
    alphas.append(a * (1 - SHADE * lum) * (1 - white))
peak = max(alphas)

for suffix, scale in (("", 1.0), ("_dim", DIM)):
    out = Image.new("RGBA", icon.size, (255, 255, 255, 0))
    out.putdata([(255, 255, 255, int(255 * v / peak * scale)) for v in alphas])
    out.save(os.path.join(out_dir, f"{name}{suffix}.png"))
