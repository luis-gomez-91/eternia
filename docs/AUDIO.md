# Eternia — Catálogo de audio

Todos los sonidos del juego, con su fuente y cómo se hicieron. Las reglas y qué fuente usa cada categoría están en [PLAN.md](PLAN.md), sección "Audio".

**Fuentes:** `ElevenLabs` (generado) · `Roblox` (Creator Store, solo catálogos con licencia: ProSoundEffects, APM Music) · `Provisorio` (de prueba, se cambia antes de publicar)

**Estados:** `Por generar` → `Generado` → `Subido` → `En juego`

## Guía de estilo para ElevenLabs

Todo texto parte de esta base para que el juego suene coherente:

- **Idioma del texto:** inglés (ElevenLabs lo entiende mejor).
- **Estilo:** fantasía estilizada de acción, como un juego de rol para jóvenes: claro y con fuerza, nunca gore ni realista crudo.
- **Mezcla:** seco y cercano, sin reverberación larga, sin música de fondo, sin voces salvo que se pidan.
- **Duración:** la justa. Golpes y habilidades de 0,3 a 1,5 s; momentos clave hasta 3 s; detalles de ambiente hasta 8 s.
- **Variantes:** se generan 3 por sonido y se elige la mejor midiendo inicio, subida, duración útil y si se concentra en un solo golpe. Se descarta antes cualquier variante con pico bajo −6 dB (a veces sale casi en silencio).
- **Mínimo de ElevenLabs:** 0,5 s por sonido.
- **Voces:** solo gritos, esfuerzos y quejidos sin palabras.

Texto base que se antepone: `Stylized fantasy action game sound effect, punchy and clean, dry close mic, no music, no voice.`

## Cómo agregar un sonido

1. Agregar la fila en la sección que corresponde, con estado `Por generar`.
2. Generar con el texto base más la descripción; guardar el texto final en la fila.
3. Recortar el silencio y normalizar a −1 dB de pico; guardar en `assets/audio/<grupo>/<Sonido>.mp3` (la variante y el texto quedan en `assets/audio/generated.json`). Subir por tanda con Open Cloud.
4. Poner el ID en la fila y en los datos del juego (`Data/Feedback` para combate).

## Clases

### Warrior

| Sonido | Dónde suena | Fuente | Texto ElevenLabs | ID Roblox | Estado |
|---|---|---|---|---|---|
| WarriorCombo1 | Golpe 1 del combo (tajo) | ElevenLabs | A quick one-handed sword slash cutting through the air, sharp light metallic whoosh. | 111424923198216 | En juego |
| WarriorCombo2 | Golpe 2 del combo (revés) | ElevenLabs | A fast backhand sword swing, airy whoosh with a slightly lower tone and a faint blade ring. | 124397046727052 | En juego |
| WarriorCombo3 | Golpe 3 del combo (de arriba abajo) | ElevenLabs | A heavy two-handed overhead sword swing, deep powerful whoosh ending in a strong ground-slam thud. | 103438577618554 | En juego |
| Cleave | Tajo (giro amplio) | ElevenLabs | A wide sweeping 180-degree heavy sword cleave, deep forceful whoosh with a fiery crackling edge. | 105049720867727 | En juego |
| BattleShout | Grito de batalla | ElevenLabs | A fierce male warrior battle cry, short wordless roar, no words, with a deep resonant war horn swell underneath. | 104391889530290 | En juego |
| Charge | Embestida | ElevenLabs | A warrior charging forward at high speed, heavy armored rush with a strong building wind whoosh. | 77904768404795 | En juego |
| WarriorHurt | Recibe un golpe (quejido) | ElevenLabs | | | Por generar |
| WarriorDeath | Muere | ElevenLabs | | | Por generar |

### Mage

| Sonido | Dónde suena | Fuente | Texto ElevenLabs | ID Roblox | Estado |
|---|---|---|---|---|---|
| MageBolt | Ataque básico (proyectil mágico) | ElevenLabs | | | Por generar |
| ArcaneOrb | Orbe arcano | ElevenLabs | | | Por generar |
| Blink | Parpadeo | ElevenLabs | | | Por generar |
| Fireball | Bola de fuego (lanzar y explotar) | ElevenLabs | | | Por generar |
| MageHurt | Recibe un golpe (quejido) | ElevenLabs | | | Por generar |
| MageDeath | Muere | ElevenLabs | | | Por generar |

### Todas las clases

| Sonido | Dónde suena | Fuente | Texto ElevenLabs | ID Roblox | Estado |
|---|---|---|---|---|---|
| Dodge | Esquivar | ElevenLabs | A very quick light dash, short cloth swish and air whoosh. | 83476574026443 | En juego |

## Impactos

| Sonido | Dónde suena | Fuente | Texto ElevenLabs | ID Roblox | Estado |
|---|---|---|---|---|---|
| Impact | Golpe que acierta | ElevenLabs | A sword blade hitting a target, solid crisp thwack with a short bright metal ring. | 88644710053967 | En juego |
| ImpactCrit | Golpe crítico | ElevenLabs | A heavy critical sword hit, crunchy powerful impact with a bright metallic ring and a short sparkling shimmer. | 125109039614338 | En juego |
| ImpactMetal | Golpe a armadura o metal | ElevenLabs | | | Por generar |
| ImpactFlesh | Golpe a criatura | ElevenLabs | | | Por generar |
| ImpactWood | Golpe a madera (muñecos, escudos) | ElevenLabs | | | Por generar |
| ImpactStone | Golpe a piedra | ElevenLabs | | | Por generar |
| ImpactMagic | Golpe mágico | ElevenLabs | | | Por generar |

## Momentos clave

| Sonido | Dónde suena | Fuente | Texto ElevenLabs | ID Roblox | Estado |
|---|---|---|---|---|---|
| LevelUp | Subir de nivel | ElevenLabs | | | Por generar |
| LootCommon | Loot gris o azul | ElevenLabs | | | Por generar |
| LootEpic | Loot morado | ElevenLabs | | | Por generar |
| LootLegendary | Loot naranja | ElevenLabs | | | Por generar |
| ForgeUpgrade | Mejora en el herrero | ElevenLabs | | | Por generar |
| PortalUnlock | Se enciende un portal de zona | ElevenLabs | | | Por generar |

## Interfaz

| Sonido | Dónde suena | Fuente | Texto ElevenLabs | ID Roblox | Estado |
|---|---|---|---|---|---|
| UiClick | Botones | Roblox | — | | Por elegir |
| UiOpen | Abrir panel | Roblox | — | | Por elegir |
| UiClose | Cerrar panel | Roblox | — | | Por elegir |
| UiError | Acción no permitida | Roblox | — | | Por elegir |

## Movimiento

| Sonido | Dónde suena | Fuente | Texto ElevenLabs | ID Roblox | Estado |
|---|---|---|---|---|---|
| Footsteps | Pasos por superficie (pasto, arena, nieve, piedra, barro) | Roblox | — | | Por elegir |
| Jump / Land | Saltar y caer | Roblox | — | | Por elegir |

## Ambiente por zona

El fondo continuo sale de Roblox; los detalles propios de cada zona se generan. Cada zona se completa junto con su ficha.

| Zona | Fondo continuo (Roblox) | Detalles (ElevenLabs) | Estado |
|---|---|---|---|
| Ciudadela de Eternia | | | Por definir |
| Bosque Sombrío | | | Por definir |
| Arenas Rojas | | | Por definir |
| Picos Helados | | | Por definir |
| Pantano Maldito | | | Por definir |
| Volcán Infernal | | | Por definir |

## Mobs y jefes

Cada mob y jefe tiene sus sonidos en la sección "Sonidos" de su ficha ([fichas/](fichas/)): detectar al jugador, atacar, recibir golpe y morir; los jefes además el aviso de cada ataque fuerte, el cambio de fase y el rugido.

## Música

| Pista | Dónde suena | Fuente | ID Roblox | Estado |
|---|---|---|---|---|
| Ciudadela | Ciudad central | APM Music (prototipo) | | Por elegir |
| Combate | Capa que entra al pelear | APM Music (prototipo) | | Por elegir |

La música final de cada zona, mazmorra y jefe está pendiente de decidir (ElevenLabs Music o compositor).
