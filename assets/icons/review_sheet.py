"""Hojas de revisión de los candidatos de íconos (una por clase).

Cada fila es una habilidad con sus candidatos numerados, en grande y al tamaño
de un botón de móvil (44 px, recortado en círculo), para elegir cuál se aprueba.

Uso: python3 -I assets/icons/review_sheet.py <carpeta de salida>
"""

import json
import os
import re
import sys

from PIL import Image, ImageDraw, ImageFont

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(os.path.dirname(HERE))
CANDIDATES = os.path.join(HERE, "candidates")
CLASS_NAMES = {
    "warrior": "Warrior",
    "paladin": "Paladín",
    "ranger": "Ranger",
    "mage": "Mage",
    "priest": "Sacerdote",
    "warlock": "Brujo",
}
BIG, SMALL, PAD, LABEL = 220, 44, 18, 190


def ability_names():
    """Nombre visible de cada habilidad, leído de Data/Abilities."""
    with open(os.path.join(ROOT, "src", "shared", "Data", "Abilities.luau")) as f:
        source = f.read()
    return dict(re.findall(r'Id = "(\w+)",[^}]*?Name = "([^"]+)"', source))


def font(size):
    for path in ("/System/Library/Fonts/Supplemental/Arial Bold.ttf", "/System/Library/Fonts/Helvetica.ttc"):
        if os.path.exists(path):
            return ImageFont.truetype(path, size)
    return ImageFont.load_default()


def candidates_for(ability_id):
    folder = os.path.join(CANDIDATES, ability_id)
    if not os.path.isdir(folder):
        return []
    files = [f for f in os.listdir(folder) if f.lower().endswith((".png", ".jpg", ".jpeg"))]
    return sorted(os.path.join(folder, f) for f in files)


def sheet_for(folder, ids, names, out_path):
    rows = [(a, candidates_for(a)) for a in ids]
    most = max((len(c) for _, c in rows), default=1) or 1
    width = LABEL + most * (BIG + PAD) + PAD + most * (SMALL + 14) + PAD
    height = 70 + len(rows) * (BIG + 34 + PAD)
    sheet = Image.new("RGB", (width, height), (30, 28, 32))
    d = ImageDraw.Draw(sheet)
    d.text((PAD, 18), CLASS_NAMES[folder], font=font(34), fill=(240, 240, 240))
    mask = Image.new("L", (SMALL, SMALL), 0)
    ImageDraw.Draw(mask).ellipse((0, 0, SMALL - 1, SMALL - 1), fill=255)
    for r, (ability_id, files) in enumerate(rows):
        y = 70 + r * (BIG + 34 + PAD)
        d.text((PAD, y + BIG / 2 - 30), names.get(ability_id, ability_id), font=font(22), fill=(240, 240, 240))
        d.text((PAD, y + BIG / 2), ability_id, font=font(16), fill=(150, 150, 150))
        if not files:
            d.text((LABEL, y + BIG / 2), "(sin candidatos)", font=font(18), fill=(200, 90, 90))
        for c, path in enumerate(files):
            img = Image.open(path).convert("RGB")
            x = LABEL + c * (BIG + PAD)
            sheet.paste(img.resize((BIG, BIG), Image.LANCZOS), (x, y))
            d.text((x + 6, y + BIG + 4), str(c + 1), font=font(22), fill=(255, 200, 80))
            sx = LABEL + most * (BIG + PAD) + PAD + c * (SMALL + 14)
            sheet.paste(img.resize((SMALL, SMALL), Image.LANCZOS), (sx, y + (BIG - SMALL) // 2), mask)
            d.text((sx + 16, y + (BIG + SMALL) // 2 + 4), str(c + 1), font=font(14), fill=(255, 200, 80))
    sheet.save(out_path)
    return out_path


def main():
    out_dir = sys.argv[1] if len(sys.argv) > 1 else CANDIDATES
    os.makedirs(out_dir, exist_ok=True)
    with open(os.path.join(HERE, "prompts.json")) as f:
        prompts = json.load(f)
    names = ability_names()
    by_class = {}
    for ability_id, entry in prompts["abilities"].items():
        by_class.setdefault(entry["class"], []).append(ability_id)
    for folder in CLASS_NAMES:
        if folder in by_class:
            path = os.path.join(out_dir, f"revision-{folder}.png")
            print(sheet_for(folder, by_class[folder], names, path))


if __name__ == "__main__":
    main()
