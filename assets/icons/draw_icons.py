"""Íconos provisorios de habilidades (Fase 0).

Dibuja las 18 activas de clase y las 6 definitivas como figuras planas con
contorno grueso, en PNG de 256 x 256 con fondo transparente (PLAN.md,
"Íconos de habilidades"). El marco lo pone la interfaz, así que aquí solo va
la figura. Se reemplazan por los hechos con IA y retocados en Figma.

Uso: python3 -I assets/icons/draw_icons.py   (necesita Pillow)
"""

import math
import os

from PIL import Image, ImageDraw, ImageFilter

S = 1024  # se dibuja grande y se achica para suavizar bordes
OUT = 256
OUTLINE = (26, 20, 32, 255)
STROKE = 34  # grosor del contorno, en píxeles de 1024
HERE = os.path.dirname(os.path.abspath(__file__))

# Colores de las clases (GUIA-VISUAL.md) y los reservados de combate.
STEEL = (200, 208, 220)
EMBER = (255, 130, 50)
GOLD = (240, 192, 64)
LIGHT = (255, 244, 214)
MINT = (120, 255, 170)
SKY = (140, 210, 255)
FOREST = (96, 176, 74)
WOOD = (150, 100, 60)
ARCANE = (170, 100, 255)
FIRE = (255, 120, 40)
FIRE_CORE = (255, 210, 90)
SHADOW = (110, 60, 160)
FEL = (175, 255, 50)
ULT = (255, 120, 40)


def new_mask():
    return Image.new("L", (S, S), 0)


class Icon:
    def __init__(self):
        self.img = Image.new("RGBA", (S, S), (0, 0, 0, 0))

    def layer(self, color, draw_fn, outline=True):
        """Pinta una capa: primero su contorno (la máscara engordada), luego el relleno."""
        mask = new_mask()
        draw_fn(ImageDraw.Draw(mask))
        if outline:
            # engordar: desenfoque y umbral bajo (más rápido que un MaxFilter grande)
            fat = mask.filter(ImageFilter.BoxBlur(STROKE)).point(lambda v: 255 if v > 8 else 0)
            self.img.paste(Image.new("RGBA", (S, S), OUTLINE), (0, 0), fat)
        self.img.paste(Image.new("RGBA", (S, S), color + (255,)), (0, 0), mask)

    def save(self, path):
        os.makedirs(os.path.dirname(path), exist_ok=True)
        self.img.resize((OUT, OUT), Image.LANCZOS).save(path)


# Figuras de ayuda ---------------------------------------------------------


def star(cx, cy, r_out, r_in, points, rot=-90):
    pts = []
    for i in range(points * 2):
        r = r_out if i % 2 == 0 else r_in
        a = math.radians(rot + i * 180 / points)
        pts.append((cx + r * math.cos(a), cy + r * math.sin(a)))
    return pts


def rotate(pts, cx, cy, deg):
    a = math.radians(deg)
    c, s = math.cos(a), math.sin(a)
    return [(cx + (x - cx) * c - (y - cy) * s, cy + (x - cx) * s + (y - cy) * c) for x, y in pts]


def arrow_pts(length, shaft, head_len, head_w, cx=0, cy=0, deg=0):
    """Flecha apuntando a la derecha, centrada en (cx, cy) y girada `deg`."""
    x0 = cx - length / 2
    x1 = cx + length / 2
    pts = [
        (x0, cy - shaft / 2),
        (x1 - head_len, cy - shaft / 2),
        (x1 - head_len, cy - head_w / 2),
        (x1, cy),
        (x1 - head_len, cy + head_w / 2),
        (x1 - head_len, cy + shaft / 2),
        (x0, cy + shaft / 2),
    ]
    return rotate(pts, cx, cy, deg)


def real_arrow(d, cx, cy, length, deg, scale=1.0):
    """Flecha de arco: astil fino, punta y plumas."""
    shaft = 30 * scale
    pts = arrow_pts(length, shaft, 120 * scale, 130 * scale, cx, cy, deg)
    d.polygon(pts, fill=255)
    # plumas
    back = -length / 2
    for side in (-1, 1):
        f = [
            (cx + back, cy),
            (cx + back + 90 * scale, cy),
            (cx + back + 30 * scale, cy + side * 60 * scale),
            (cx + back - 40 * scale, cy + side * 60 * scale),
        ]
        d.polygon(rotate(f, cx, cy, deg), fill=255)


def thick_arc(d, box, start, end, width):
    d.arc(box, start, end, fill=255, width=width)


def heart(cx, cy, size):
    pts = []
    for i in range(120):
        t = math.tau * i / 120
        x = 16 * math.sin(t) ** 3
        y = -(13 * math.cos(t) - 5 * math.cos(2 * t) - 2 * math.cos(3 * t) - math.cos(4 * t))
        pts.append((cx + x * size / 17, cy + y * size / 17))
    return pts


def plus(cx, cy, size, bar):
    h = size / 2
    b = bar / 2
    return [
        (cx - b, cy - h), (cx + b, cy - h), (cx + b, cy - b), (cx + h, cy - b),
        (cx + h, cy + b), (cx + b, cy + b), (cx + b, cy + h), (cx - b, cy + h),
        (cx - b, cy + b), (cx - h, cy + b), (cx - h, cy - b), (cx - b, cy - b),
    ]


def sword(d, cx, cy, length, deg, blade=70):
    """Espada vertical (punta arriba) girada `deg`."""
    top = cy - length / 2
    bot = cy + length / 2
    guard_y = bot - length * 0.24
    pts_blade = [
        (cx, top), (cx + blade / 2, top + blade * 0.8), (cx + blade / 2, guard_y),
        (cx - blade / 2, guard_y), (cx - blade / 2, top + blade * 0.8),
    ]
    d.polygon(rotate(pts_blade, cx, cy, deg), fill=255)
    guard = [(cx - 130, guard_y), (cx + 130, guard_y), (cx + 130, guard_y + 50), (cx - 130, guard_y + 50)]
    d.polygon(rotate(guard, cx, cy, deg), fill=255)
    grip = [(cx - 28, guard_y + 50), (cx + 28, guard_y + 50), (cx + 28, bot), (cx - 28, bot)]
    d.polygon(rotate(grip, cx, cy, deg), fill=255)


# Íconos -------------------------------------------------------------------
# Cada función devuelve un Icon. Las figuras ocupan ~80% del cuadro.

C = S / 2


def cleave():
    i = Icon()
    # media luna del tajo
    def slash(d):
        d.ellipse((120, 140, 900, 920), fill=255)
        d.ellipse((240, 60, 1000, 820), fill=0)

    i.layer(EMBER, slash)
    i.layer(STEEL, lambda d: sword(d, 620, 420, 640, 45))
    return i


def battle_shout():
    i = Icon()
    # cuerno de guerra
    horn = [(150, 430), (560, 300), (820, 170), (870, 210), (870, 810), (820, 850), (560, 720), (150, 590)]
    i.layer(STEEL, lambda d: d.polygon(horn, fill=255))
    i.layer(EMBER, lambda d: d.polygon([(560, 300), (640, 260), (640, 760), (560, 720)], fill=255), outline=False)
    i.layer(EMBER, lambda d: d.rectangle((120, 400, 220, 620), fill=255))
    return i


def charge():
    i = Icon()
    # líneas de velocidad y flecha gruesa hacia adelante
    def lines(d):
        for y, x0 in ((300, 90), (512, 60), (724, 90)):
            d.rounded_rectangle((x0, y - 32, x0 + 260, y + 32), 32, fill=255)

    i.layer(EMBER, lines)
    i.layer(STEEL, lambda d: d.polygon(arrow_pts(620, 230, 300, 560, 610, 512), fill=255))
    return i


def whirlwind():
    i = Icon()
    # tres hojas girando alrededor del centro
    def blades(d):
        for k in range(3):
            blade = [(C, C - 60), (C + 80, C - 380), (C + 200, C - 300), (C + 60, C)]
            d.polygon(rotate(blade, C, C, k * 120), fill=255)

    i.layer(ULT, lambda d: thick_arc(d, (110, 110, 914, 914), 200, 520, 70))
    i.layer(STEEL, blades)
    i.layer(EMBER, lambda d: d.ellipse((C - 110, C - 110, C + 110, C + 110), fill=255))
    return i


def holy_strike():
    i = Icon()
    i.layer(LIGHT, lambda d: d.polygon(star(600, 400, 390, 170, 8), fill=255))
    # maza: mango y cabeza
    i.layer(WOOD, lambda d: d.polygon(rotate([(570, 420), (630, 420), (630, 940), (570, 940)], 600, 420, 35), fill=255))
    i.layer(GOLD, lambda d: d.polygon(star(600, 400, 230, 160, 6, rot=0), fill=255))
    return i


def consecration():
    i = Icon()
    # suelo consagrado: elipse con columnas de luz
    i.layer(GOLD, lambda d: d.ellipse((90, 600, 934, 900), fill=255))
    i.layer(LIGHT, lambda d: d.ellipse((220, 660, 804, 840), fill=255), outline=False)

    def rays(d):
        for x, h in ((300, 380), (512, 250), (724, 380)):
            d.polygon([(x - 60, 750), (x + 60, 750), (x + 35, h), (x - 35, h)], fill=255)

    i.layer(LIGHT, rays)
    i.layer(GOLD, lambda d: d.polygon(star(512, 190, 120, 50, 4), fill=255))
    return i


def healing_light():
    i = Icon()
    i.layer(GOLD, lambda d: d.polygon(star(C, C, 420, 300, 12), fill=255))
    i.layer(MINT, lambda d: d.polygon(plus(C, C, 520, 180), fill=255))
    return i


def dawn_hammer():
    i = Icon()
    # sol del alba detrás y martillo de guerra
    i.layer(ULT, lambda d: d.pieslice((90, 260, 934, 1100), 180, 360, fill=255))
    i.layer(WOOD, lambda d: d.polygon(rotate([(480, 330), (544, 330), (544, 960), (480, 960)], C, 600, -30), fill=255))
    i.layer(GOLD, lambda d: d.polygon(rotate([(260, 150), (764, 150), (764, 420), (260, 420)], C, 600, -30), fill=255))
    i.layer(LIGHT, lambda d: d.polygon(rotate([(300, 200), (724, 200), (724, 250), (300, 250)], C, 600, -30), fill=255), outline=False)
    return i


def power_shot():
    i = Icon()
    i.layer(FOREST, lambda d: thick_arc(d, (120, 120, 904, 904), 120, 330, 80))
    i.layer(LIGHT, lambda d: real_arrow(d, C, C, 880, -45, 1.3))
    return i


def arrow_rain():
    i = Icon()
    def arrows(d):
        for x, y in ((280, 470), (C, 560), (744, 470)):
            real_arrow(d, x, y, 620, 90, 0.95)

    i.layer(FOREST, lambda d: d.rounded_rectangle((120, 70, 904, 200), 60, fill=255))
    i.layer(LIGHT, arrows)
    return i


def disengage():
    i = Icon()
    # flecha curva hacia atrás (salto)
    i.layer(FOREST, lambda d: thick_arc(d, (230, 180, 860, 800), 180, 360, 150))
    i.layer(FOREST, lambda d: d.polygon([(80, 470), (390, 470), (235, 760)], fill=255))
    i.layer(WOOD, lambda d: d.rounded_rectangle((500, 820, 940, 900), 40, fill=255))
    return i


def volley():
    i = Icon()
    def arrows(d):
        for deg in (-75, -45, -15):
            a = math.radians(deg)
            cx = 200 + 400 * math.cos(a)
            cy = 820 + 400 * math.sin(a)
            real_arrow(d, cx, cy, 640, deg, 1.15)

    i.layer(ULT, lambda d: d.pieslice((-100, 520, 500, 1120), 270, 360, fill=255))
    i.layer(LIGHT, arrows)
    return i


def arcane_orb():
    i = Icon()
    i.layer(ARCANE, lambda d: d.ellipse((190, 190, 834, 834), fill=255))
    i.layer(LIGHT, lambda d: d.ellipse((310, 290, 470, 450), fill=255), outline=False)

    def ring(d):
        d.ellipse((60, 400, 964, 624), outline=255, width=60)

    i.layer(ARCANE, ring)
    return i


def blink():
    i = Icon()
    def dots(d):
        for x, r in ((150, 50), (300, 70)):
            d.ellipse((x - r, 620 - r, x + r, 620 + r), fill=255)

    i.layer(ARCANE, dots)
    i.layer(SKY, lambda d: d.polygon(star(640, 420, 360, 110, 4), fill=255))
    i.layer(LIGHT, lambda d: d.polygon(star(640, 420, 140, 50, 4), fill=255), outline=False)
    return i


def fireball():
    i = Icon()
    # bola con cola de llamas hacia arriba a la derecha
    tail = [(270, 820), (180, 440), (330, 560), (360, 250), (500, 430), (640, 120), (720, 420), (860, 300), (800, 820)]
    i.layer(FIRE, lambda d: (d.polygon(tail, fill=255), d.ellipse((220, 380, 820, 940), fill=255)))
    i.layer(FIRE_CORE, lambda d: d.ellipse((350, 540, 690, 880), fill=255), outline=False)
    return i


def meteor_shower():
    i = Icon()
    # caen hacia abajo a la izquierda, con la cola arriba a la derecha
    def meteor(d, cx, cy, r):
        d.ellipse((cx - r, cy - r, cx + r, cy + r), fill=255)
        tail = rotate([(cx, cy - r), (cx - 3.2 * r, cy - 0.15 * r), (cx - 3.2 * r, cy + 0.15 * r), (cx, cy + r)], cx, cy, 135)
        d.polygon(tail, fill=255)

    i.layer(FIRE, lambda d: (meteor(d, 560, 290, 85), meteor(d, 700, 640, 95)))
    i.layer(ARCANE, lambda d: meteor(d, 330, 690, 150))
    i.layer(FIRE_CORE, lambda d: d.ellipse((260, 640, 380, 760), fill=255), outline=False)
    return i


def smite():
    i = Icon()
    bolt = [(560, 60), (300, 520), (480, 520), (380, 960), (740, 420), (550, 420), (700, 60)]
    i.layer(GOLD, lambda d: d.ellipse((140, 800, 884, 960), fill=255))
    i.layer(LIGHT, lambda d: d.polygon(bolt, fill=255))
    return i


def heal():
    i = Icon()
    i.layer(MINT, lambda d: d.polygon(heart(C, 540, 390), fill=255))
    i.layer(LIGHT, lambda d: d.polygon(plus(C, 500, 300, 100), fill=255))
    return i


def holy_nova():
    i = Icon()
    i.layer(GOLD, lambda d: d.polygon(star(C, C, 470, 230, 12), fill=255))
    i.layer(LIGHT, lambda d: d.ellipse((C - 200, C - 200, C + 200, C + 200), fill=255))
    i.layer(MINT, lambda d: d.ellipse((C - 70, C - 70, C + 70, C + 70), fill=255), outline=False)
    return i


def divine_hymn():
    i = Icon()
    # nota musical con aureola
    i.layer(ULT, lambda d: d.ellipse((330, 70, 870, 230), outline=255, width=55))

    def note(d):
        d.ellipse((150, 640, 450, 880), fill=255)
        d.rectangle((380, 300, 450, 770), fill=255)
        d.polygon([(380, 300), (760, 230), (760, 340), (450, 410)], fill=255)
        d.ellipse((520, 570, 820, 810), fill=255)
        d.rectangle((690, 230, 760, 700), fill=255)

    i.layer(LIGHT, note)
    return i


def corruption():
    i = Icon()
    # gota vil que gotea
    drop = [(C, 80)] + [
        (C + 300 * math.sin(t), 600 - 300 * math.cos(t))
        for t in [math.radians(a) for a in range(-130, 131, 5)]
    ][::-1]
    i.layer(SHADOW, lambda d: (d.polygon(drop, fill=255), d.ellipse((C - 300, 300, C + 300, 900), fill=255)))
    i.layer(FEL, lambda d: (d.ellipse((330, 520, 520, 710), fill=255), d.ellipse((560, 640, 680, 760), fill=255)), outline=False)
    return i


def drain_life():
    i = Icon()
    # rayo ondulado que sale de un corazón hacia la mano
    def wave(d):
        pts = [(x, 330 + 90 * math.sin((x - 100) / 70)) for x in range(100, 930, 10)]
        d.line(pts, fill=255, width=70, joint="curve")

    i.layer(FEL, wave)
    i.layer(SHADOW, lambda d: d.polygon(heart(C, 640, 300), fill=255))
    i.layer(FEL, lambda d: d.polygon(arrow_pts(300, 70, 120, 170, C, 640, -90), fill=255), outline=False)
    return i


def shadow_blast():
    i = Icon()
    i.layer(SHADOW, lambda d: d.polygon(star(C, C, 470, 220, 9), fill=255))
    i.layer(FEL, lambda d: d.polygon(star(C, C, 230, 110, 9, rot=-70), fill=255))
    return i


def shadow_pact():
    i = Icon()
    # ojo vil dentro de un rombo de sombra
    i.layer(ULT, lambda d: d.polygon([(C, 70), (954, C), (C, 954), (70, C)], fill=255))
    i.layer(SHADOW, lambda d: d.ellipse((150, 330, 874, 694), fill=255))
    i.layer(FEL, lambda d: d.ellipse((C - 150, C - 150, C + 150, C + 150), fill=255))
    i.layer(OUTLINE[:3], lambda d: d.ellipse((C - 40, C - 120, C + 40, C + 120), fill=255), outline=False)
    return i


ICONS = {
    "warrior": {"Cleave": cleave, "BattleShout": battle_shout, "Charge": charge, "Whirlwind": whirlwind},
    "paladin": {
        "HolyStrike": holy_strike,
        "Consecration": consecration,
        "HealingLight": healing_light,
        "DawnHammer": dawn_hammer,
    },
    "ranger": {"PowerShot": power_shot, "ArrowRain": arrow_rain, "Disengage": disengage, "Volley": volley},
    "mage": {"ArcaneOrb": arcane_orb, "Blink": blink, "Fireball": fireball, "MeteorShower": meteor_shower},
    "priest": {"Smite": smite, "Heal": heal, "HolyNova": holy_nova, "DivineHymn": divine_hymn},
    "warlock": {
        "Corruption": corruption,
        "DrainLife": drain_life,
        "ShadowBlast": shadow_blast,
        "ShadowPact": shadow_pact,
    },
}

if __name__ == "__main__":
    for folder, icons in ICONS.items():
        for name, fn in icons.items():
            fn().save(os.path.join(HERE, folder, f"{name}.png"))
            print(f"{folder}/{name}.png")
