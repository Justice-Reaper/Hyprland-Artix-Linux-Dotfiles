#!/usr/bin/env python3
"""Print every Icons Font icon in the terminal.

The terminal renders them via fontconfig fallback, so the font has to be
installed (fc-cache included) for them to show.

The name -> codepoint map is read live from icon-chars.sh, which
build-waybar-icons-font.py generates, so this list never goes out of sync
with the font when icons are added, removed or reordered.
"""

import os
import re
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
MAP = os.path.join(HERE, "icon-chars.sh")

LINE = re.compile(r"^ICON_(?P<name>[A-Z0-9_]+)=\$'\\U(?P<cp>[0-9A-Fa-f]{8})'")

icons = []
with open(MAP) as fh:
    for line in fh:
        m = LINE.match(line.strip())
        if m:
            icons.append(("ICON_" + m.group("name"), int(m.group("cp"), 16)))

if not icons:
    sys.exit(f"no icons found in {MAP}")

print(f"{'icon':^7} {'codepoint':<10} name")
print("-" * 50)
for name, cp in icons:
    print(f"   {chr(cp)}    U+{cp:05X}   {name}")

print()
print(f"total: {len(icons)} icons")
print("all together:")
print(" ".join(chr(cp) for _, cp in icons))
