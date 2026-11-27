# Mob: Lobo Gris (de carga)

**Estado:** En caja gris · **Fase:** 0 · **Zona o mazmorra:** Subárea de prueba (luego Bosque Sombrío)
**Concepto visual:** pendiente · **Caja gris:** manada de lobos en campo abierto (`ArenaService`); datos en `Data/Mobs` (`GreyWolf`)

## Idea
Avisa y embiste en línea recta. Enseña a leer avisos y a esquivar a tiempo (salir de la línea o usar Q).

## Aspecto
Lobo gris con patas y orejas oscuras y ojos amarillos. Provisorio: bloques (`Wolf`).

## Comportamiento
- **Patrulla:** camina (7) hasta 10 studs de su sitio. Van en pareja.
- **Distancia a la que detecta:** 22 studs. Suma a los quietos a menos de 16 studs.
- **Persigue:** el más rápido de los mobs (16, igual que el jugador). Si está entre 7 y 24 studs y la embestida está lista, embiste; si no, se acerca a morder.
- **Vuelve a su sitio cuando:** se aleja más de 55 studs de su sitio o no queda nadie cerca.

## Ataques (1 o 2)
| Ataque | Aviso visual | Qué hace | Daño | Espera |
|---|---|---|---|---|
| Embestida | Línea roja de 4 de ancho hasta 30 studs (o hasta una pared) que se llena en 1,1 s, con gruñido | Corre la línea a 55 studs/s y daña una vez a cada jugador que atraviesa. Después queda 1,4 s quieto | 18 | 6 s |
| Mordida | Rectángulo rojo de 6 × 4,5 al frente, 0,55 s | Golpe corto entre embestidas | 8 | 2 s |

## Vida y daño por nivel
Propuesta: +12% por nivel. En la prueba es nivel 3.
| Nivel | Vida | Daño (embestida / mordida) |
|---|---|---|
| 1 | 185 | 15 / 7 |
| 3 (prueba) | 220 | 18 / 8 |
| 10 | 345 | 28 / 13 |

## Qué suelta
- Fase 0: nada.
- Propuesta para Fase 4: oro y "Piel de lobo" (material del herrero y de encargos).

## Sonidos
Ver [AUDIO.md](../../AUDIO.md). Fuente: ElevenLabs.
| Sonido | Cuándo | Estado |
|---|---|---|
| Detectar | Ve al jugador | En juego (WolfGrowl) |
| Aviso | Gruñido al empezar la embestida | En juego (WolfGrowl) |
| Ataque | Embestida / Mordida | En juego (WolfCharge / WolfBite) |
| Recibe golpe | | Usa los impactos de la clase que pega |
| Muere | | En juego (WolfDeath) |

## Notas de prueba
- 26 nov 2026: los dos lobos embestían a la vez apenas detectaban (36 de daño juntos). Ahora cada mob espera entre 0,4 y 1,2 s al azar antes de su primer ataque.
- Con la invulnerabilidad del esquivar activa, la embestida no hace daño y se ve "Esquivado".
