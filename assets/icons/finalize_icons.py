"""Pasa los candidatos elegidos a íconos finales: assets/icons/<clase>/<Id>.png.

Recorta un borde claro si la IA pintó un marco, deja el cuadrado centrado y lo
achica a 256 x 256 (PNG opaco, GUIA-VISUAL.md, Íconos). Para cambiar un ícono,
se cambia su candidato en CHOSEN y se vuelve a correr.

Uso: python3 -I assets/icons/finalize_icons.py
"""

import json
import os

from PIL import Image, ImageStat

HERE = os.path.dirname(os.path.abspath(__file__))
CANDIDATES = os.path.join(HERE, "candidates")
OUT = 256
MAX_TRIM = 0.08  # como mucho se recorta esta fracción por lado

# Candidato elegido por habilidad (archivo dentro de candidates/<Id>/).
CHOSEN = {
    "Cleave": "gemini-3.1-flash-image_3.jpg",
    "BattleShout": "gemini-3.1-flash-image_3.jpg",
    "Charge": "gemini-3.1-flash-image_2.jpg",
    "Whirlwind": "gemini-3.1-flash-image_1.jpg",
    "HolyStrike": "gemini-3.1-flash-image_3.jpg",
    "Consecration": "gemini-3.1-flash-image_2.jpg",
    "HealingLight": "gemini-3.1-flash-image_2.jpg",
    "DawnHammer": "gemini-3.1-flash-image_1.jpg",
    "PowerShot": "gemini-3.1-flash-image_1.jpg",
    "ArrowRain": "gemini-3.1-flash-image_1.jpg",
    "Disengage": "gemini-3.1-flash-image_1.jpg",
    "Volley": "gemini-3.1-flash-image_1.jpg",
    "ArcaneOrb": "gemini-3.1-flash-image_1.jpg",
    "Blink": "gemini-3.1-flash-image_1.jpg",
    "Fireball": "gemini-3.1-flash-image_1.jpg",
    "MeteorShower": "gemini-3.1-flash-image_1.jpg",
    "Smite": "gemini-3.1-flash-image_1.jpg",
    "Heal": "gemini-3.1-flash-image_1.jpg",
    "HolyNova": "gemini-3.1-flash-image_1.jpg",
    "DivineHymn": "gemini-3.1-flash-image_1.jpg",
    "Corruption": "gemini-3.1-flash-image_1.jpg",
    "DrainLife": "gemini-3.1-flash-image_1.jpg",
    "ShadowBlast": "gemini-3.1-flash-image_1.jpg",
    "ShadowPact": "gemini-3.1-flash-image_1.jpg",
}


def trim_light_border(img):
    """Quita un marco claro pintado en los bordes (líneas casi blancas)."""
    gray = img.convert("L")
    w, h = gray.size
    limit = int(min(w, h) * MAX_TRIM)

    def bright(box):
        return ImageStat.Stat(gray.crop(box)).mean[0] > 170

    left = top = 0
    right, bottom = w, h
    while left < limit and bright((left, 0, left + 1, h)):
        left += 1
    while right > w - limit and bright((right - 1, 0, right, h)):
        right -= 1
    while top < limit and bright((0, top, w, top + 1)):
        top += 1
    while bottom > h - limit and bright((0, bottom - 1, w, bottom)):
        bottom -= 1
    if (left, top, right, bottom) != (0, 0, w, h):
        # un poco más hacia adentro, para no dejar el borde suave del marco
        pad = int(min(w, h) * 0.015)
        img = img.crop((left + pad, top + pad, right - pad, bottom - pad))
    return img


def center_square(img):
    w, h = img.size
    side = min(w, h)
    x, y = (w - side) // 2, (h - side) // 2
    return img.crop((x, y, x + side, y + side))


def main():
    with open(os.path.join(HERE, "prompts.json")) as f:
        prompts = json.load(f)
    for ability_id, file in CHOSEN.items():
        folder = prompts["abilities"][ability_id]["class"]
        img = Image.open(os.path.join(CANDIDATES, ability_id, file)).convert("RGB")
        img = center_square(trim_light_border(img)).resize((OUT, OUT), Image.LANCZOS)
        out = os.path.join(HERE, folder, f"{ability_id}.png")
        os.makedirs(os.path.dirname(out), exist_ok=True)
        img.save(out)
        print(f"{folder}/{ability_id}.png  <-  {ability_id}/{file}")


if __name__ == "__main__":
    main()
