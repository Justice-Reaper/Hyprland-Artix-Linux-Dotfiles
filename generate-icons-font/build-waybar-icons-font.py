#!/usr/bin/env fontforge -lang=py -script
# Builds Icons Font.ttf from scratch, using only the SVGs found in the
# ./icons folder next to this script. Icons are assigned sequential codepoints starting at U+F5000
# in alphabetical order (folder/file), with no gaps and nothing inherited
# from any previous font.
#
# U+F5000+ sits in the Supplementary Private Use Area-A (plane 15), past the
# Nerd Fonts patching range (U+F0001-U+F1AF0), so patched fonts can never
# overwrite these icons.
#
# Normalization applied to every glyph (MDI and Material Symbols alike):
#   - ink (bounding box) height scaled to exactly 1700 font units
#   - left and right side bearings = 0 (advance = ink width)
#   - vertically centered in the line box
#
# Line metrics are fixed at 2048 upm (ascent 1901, descent 483, linegap 0) so the
# icon line height stays consistent in waybar.

import fontforge
import psMat
import glob
import math
import os
import re
import sys

# Resolved relative to this script's folder, so the bundle rebuilds after a fresh
# clone without depending on ~/Downloads or ~/fonts-work.
HERE = os.path.dirname(os.path.abspath(__file__))
SVG_DIR = os.path.join(HERE, "icons")
# the generated font lives in the repo's fonts/ folder, one level up
OUT = os.path.join(HERE, "..", "fonts", "Icons Font.ttf")
MAP_OUT = os.path.join(HERE, "icon-chars.sh")

EM = 2048
TARGET_HEIGHT = 1700
FIRST_CP = 0xF5000

# line metrics at 2048 upm
LINE_ASCENT = 1901
LINE_DESCENT = 483

# center the glyph between -LINE_DESCENT and LINE_ASCENT
Y_MIN = -LINE_DESCENT + (LINE_ASCENT + LINE_DESCENT - TARGET_HEIGHT) // 2

# per-icon orientation tweaks (glyph name -> degrees, applied around center)
ROTATE = {"ethernet": 180}


def icon_name(path):
    base = os.path.splitext(os.path.basename(path))[0]
    base = re.sub(r"_24dp_[0-9A-Fa-f]{6}_(FILL[01])_wght400_GRAD0_opsz24", r"_\1", base)
    return re.sub(r"[^A-Za-z0-9]+", "_", base).strip("_").lower()


def split_pinched(c):
    # A "figure eight" contour visits the same on-curve point twice (e.g. the
    # inner detail of MDI's security icon). FontForge mis-orients those as a
    # whole, losing the holes, so split them into independent contours.
    pts = list(c)
    seen = {}
    for i, p in enumerate(pts):
        if not p.on_curve:
            continue
        key = (round(p.x, 2), round(p.y, 2))
        if key in seen:
            j = seen[key]
            return pts[j:i], pts[i:] + pts[:j]
        seen[key] = i
    return None


def rebuild_contour(pts):
    nc = fontforge.contour()
    nc.is_quadratic = False
    for p in pts:
        nc += p
    nc.closed = True
    return nc


def split_pinched_contours(g):
    queue = list(g.foreground)
    out = []
    splits = 0
    while queue:
        c = queue.pop(0)
        r = split_pinched(c)
        if r:
            splits += 1
            queue.extend(rebuild_contour(part) for part in r)
        else:
            out.append(c)
    if splits:
        lay = fontforge.layer()
        for c in out:
            lay += c
        g.foreground = lay
        # correctDirection must run before any removeOverlap: the split
        # parts inherit the wrong orientation and need re-nesting first
        g.correctDirection()
    return splits


svgs = sorted(glob.glob(os.path.join(SVG_DIR, "*", "*.svg")))
if not svgs:
    print("no SVGs found in", SVG_DIR)
    sys.exit(1)

font = fontforge.font()
font.encoding = "UnicodeFull"
font.ascent = 1638
font.descent = 410
font.em = EM
font.fontname = "Icons Font"
font.familyname = "Icons Font"
font.fullname = "Icons Font Regular"
font.weight = "Regular"

font.os2_typoascent_add = False
font.os2_typodescent_add = False
font.os2_winascent_add = False
font.os2_windescent_add = False
font.hhea_ascent_add = False
font.hhea_descent_add = False
font.os2_typoascent = LINE_ASCENT
font.os2_typodescent = -LINE_DESCENT
font.os2_typolinegap = 0
font.os2_winascent = LINE_ASCENT
font.os2_windescent = LINE_DESCENT
font.hhea_ascent = LINE_ASCENT
font.hhea_descent = -LINE_DESCENT
font.hhea_linegap = 0

mapping = []
errors = 0
for i, svg in enumerate(svgs):
    cp = FIRST_CP + i
    g = font.createChar(cp, icon_name(svg))
    g.importOutlines(svg)
    n = split_pinched_contours(g)
    if n:
        print("U+%05X %s: %d pinched contour(s) split" % (cp, g.glyphname, n))
    g.removeOverlap()
    g.correctDirection()
    if g.glyphname in ROTATE:
        g.transform(psMat.rotate(math.radians(ROTATE[g.glyphname])))
        print("U+%05X %s: rotated %d degrees" % (cp, g.glyphname, ROTATE[g.glyphname]))
    xmin, ymin, xmax, ymax = g.boundingBox()
    h = ymax - ymin
    if h <= 0:
        print("EMPTY GLYPH:", svg)
        errors += 1
        continue
    g.transform(psMat.scale(TARGET_HEIGHT / h))
    # put points at the curve extrema and snap to integers, so the bbox is
    # exact and the bearings end up at exactly 0 (no sub-unit residue)
    g.addExtrema("all")
    g.round()
    xmin, ymin, xmax, ymax = g.boundingBox()
    g.transform(psMat.translate(-xmin, Y_MIN - ymin))
    g.removeOverlap()
    g.correctDirection()
    g.round()
    xmin, ymin, xmax, ymax = g.boundingBox()
    g.width = int(round(xmax))
    mapping.append((cp, g.glyphname))
    print("U+%05X %-25s w=%4d ink=(%.0f,%.0f,%.0f,%.0f) h=%.0f"
          % (cp, g.glyphname, g.width, xmin, ymin, xmax, ymax, ymax - ymin))

if errors:
    print("aborting, %d errors" % errors)
    sys.exit(1)

font.generate(OUT)

# TrueType uses the opposite winding convention to PostScript; the cubic ->
# quadratic conversion can leave some contours flipped. Re-open the generated
# file, fix direction there, and regenerate so the shipped TTF validates clean.
# Only fix winding (0x8). Self-intersection (0x4) is NOT fixed on purpose:
# some MDI icons (e.g. security) use a self-intersecting contour for their
# inner detail, and removeOverlap would merge it away into a solid shape.
ttf = fontforge.open(OUT)
dirty = [g for g in ttf.glyphs() if g.unicode >= FIRST_CP and g.validate(True) & 0x8]
if dirty:
    print("fixing TT winding on %d glyphs: %s"
          % (len(dirty), " ".join("U+%05X" % g.unicode for g in dirty)))
    for g in dirty:
        g.correctDirection()
        g.round()
    ttf.generate(OUT)
    ttf = fontforge.open(OUT)
    dirty = [g for g in ttf.glyphs() if g.unicode >= FIRST_CP and g.validate(True) & 0x8]
print("wrong-direction glyphs in final ttf:",
      " ".join("U+%05X" % g.unicode for g in dirty) if dirty else "none")

with open(MAP_OUT, "w") as fh:
    for cp, name in mapping:
        fh.write("ICON_%s=$'\\U%08X'\n" % (name.upper(), cp))
print("wrote mapping to", MAP_OUT)
print("generated %s with %d icons" % (OUT, len(mapping)))
