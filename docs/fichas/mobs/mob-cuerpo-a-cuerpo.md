# Mob: Goblin Saqueador (cuerpo a cuerpo)

**Estado:** En caja gris · **Fase:** 0 · **Zona o mazmorra:** Subárea de prueba (luego Bosque Sombrío, Claro del Molino)
**Concepto visual:** pendiente · **Caja gris:** campamento de goblins de la subárea de prueba (`ArenaService`); datos en `Data/Mobs` (`GoblinRaider`)

## Idea
Se acerca y golpea. Enseña a esquivar y a pegar entre sus ataques. Es el mob más común: aparece en grupos de 3.

## Aspecto
Goblin bajo y verde, orejas largas, ojos ámbar y un garrote de madera. Provisorio: bloques simples (`server/Mobs/Bodies`, `Goblin`).

## Comportamiento
- **Patrulla:** camina despacio (6) a puntos al azar hasta 8 studs de su sitio.
- **Distancia a la que detecta:** 18 studs. Los goblins quietos a menos de 14 studs se suman a la pelea. Recibir daño también lo hace pelear.
- **Persigue:** corre a 14 (un poco menos que el jugador, 16) hasta quedar a ~3 studs.
- **Vuelve a su sitio cuando:** se aleja más de 50 studs de su sitio o no queda ningún jugador cerca. Vuelve corriendo, inmune, y recupera toda la vida.

## Ataques (1 o 2)
| Ataque | Aviso visual | Qué hace | Daño | Espera |
|---|---|---|---|---|
| Garrotazo | Rectángulo rojo de 6,5 × 5 al frente que se llena en 0,7 s; el goblin brilla en rojo | Golpe frontal. Después queda 0,9 s quieto: la ventana para pegarle | 8 | 2,6 s |

## Vida y daño por nivel
Propuesta: +12% por nivel. En la prueba es nivel 2.
| Nivel | Vida | Daño |
|---|---|---|
| 1 | 160 | 7 |
| 2 (prueba) | 180 | 8 |
| 10 | 340 | 15 |

## Qué suelta
- Fase 0: nada (no hay loot todavía).
- Propuesta para Fase 4: oro, Fragmentos de hierro y equipo Común de guantes o botas.

## Sonidos
Ver [AUDIO.md](../../AUDIO.md). Fuente: ElevenLabs.
| Sonido | Cuándo | Estado |
|---|---|---|
| Detectar | Ve al jugador | En juego (GoblinAggro) |
| Ataque | Garrotazo | En juego (GoblinAttack) |
| Recibe golpe | | Usa los impactos de la clase que pega |
| Muere | | En juego (GoblinDeath) |

## Notas de prueba
- 26 nov 2026: con 10 de daño y 2,2 s de espera, 3 goblins mataban en ~8 s a un jugador quieto; bajado a 8 y 2,6 s.
