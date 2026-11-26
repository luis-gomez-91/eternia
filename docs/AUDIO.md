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
- **Variantes:** se generan 3 o 4 por sonido y se elige la mejor; los golpes repetidos (combo, impactos) se quedan con 2 o 3 para alternar.
- **Voces:** solo gritos, esfuerzos y quejidos sin palabras.

Texto base que se antepone: `Stylized fantasy action game sound effect, punchy and clean, dry close mic, no music, no voice.`

## Cómo agregar un sonido

1. Agregar la fila en la sección que corresponde, con estado `Por generar`.
2. Generar con el texto base más la descripción; guardar el texto final en la fila.
3. Recortar y normalizar en Audacity; subir por tanda con Open Cloud.
4. Poner el ID en la fila y en los datos del juego (`Data/Feedback` para combate).

## Clases

### Warrior

| Sonido | Dónde suena | Fuente | Texto ElevenLabs | ID Roblox | Estado |
|---|---|---|---|---|---|
| WarriorCombo1 | Golpe 1 del combo (tajo) | Roblox (ProSoundEffects) | — | 9120704978 | Provisorio |
| WarriorCombo2 | Golpe 2 del combo (revés) | Roblox (ProSoundEffects) | — | 9120704978 | Provisorio |
| WarriorCombo3 | Golpe 3 del combo (de arriba abajo) | Roblox (ProSoundEffects) | — | 9126229255 | Provisorio |
| Cleave | Tajo (giro amplio) | Roblox (ProSoundEffects) | — | 9120709477 | Provisorio |
| BattleShout | Grito de batalla | Roblox (ProSoundEffects) | — | 9120415730 | Provisorio |
| Charge | Embestida | Roblox (ProSoundEffects) | — | 9125648149 | Provisorio |
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
| Dodge | Esquivar | Roblox (ProSoundEffects) | — | 9126283272 | Provisorio |

## Impactos

| Sonido | Dónde suena | Fuente | Texto ElevenLabs | ID Roblox | Estado |
|---|---|---|---|---|---|
| Impact | Golpe que acierta | Provisorio (origen no verificado) | — | 101309544882556 | Provisorio |
| ImpactCrit | Golpe crítico | Provisorio (origen no verificado) | — | 7171761940 | Provisorio |
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
