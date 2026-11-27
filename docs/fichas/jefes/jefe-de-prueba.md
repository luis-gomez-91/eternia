# Jefe: Ogro del Claro (jefe de prueba)

**Estado:** En caja gris · **Fase:** 0 · **Mazmorra:** Subárea de prueba · **Posición:** Prueba
**Concepto visual:** pendiente · **Caja gris:** arena circular al fondo de la subárea de prueba (`ArenaService`); datos en `Data/Mobs` (`ClearingOgre`)

## Idea
Jefe de 2 fases para probar el combate de la Fase 0: leer avisos en el suelo, salir de zonas, pegar en las ventanas y manejar ayudantes.

## Aspecto
Ogro grande de piel marrón clara, panza enorme, colmillos, ojos ámbar y un garrote gigante. Provisorio: bloques (`Ogre`), unas 3 veces la altura de un jugador.

## Qué pone a prueba
Rol principal: **Daño**. Por qué: en la Fase 0 se juega solo o en grupos sin roles; pide moverse bien y pegar en las ventanas. En difícil pasará a probar al tank (Garrotazo fuerte que debe recibir de frente).

**Duración objetivo:** 2 a 4 min. Con 3.000 de vida y ~25-35 de daño por segundo de una clase sola, son unos 2 min pegando, más los ayudantes.

## Fases
| Fase | Empieza con vida | Qué cambia |
|---|---|---|
| 1 | 100% | Garrotazo y Pisotón. Velocidad 12 |
| 2 | 50% | Ruge (1,5 s inmune, banner "¡Ogro del Claro se enfurece!"), llama 2 Goblins Saqueadores, suma Lluvia de rocas, se mueve un 20% más rápido y sus esperas bajan un 20% |

## Ataques
| Ataque | Fase | Aviso visual | Qué hace | Cómo se evita o se responde |
|---|---|---|---|---|
| Garrotazo | 1 y 2 | Rectángulo rojo de 13 × 9 al frente, 1 s | 22 de daño | Salir hacia un costado o por detrás |
| Pisotón | 1 y 2 | Círculo rojo de radio 13 alrededor del ogro, 1,6 s, con sonido de aviso | 30 de daño | Alejarse; o esquivar con Q justo antes |
| Lluvia de rocas | 2 | Círculos rojos de radio 6 bajo cada jugador y 4 más al azar en la arena, 1,6 s, con sonido de aviso | 24 de daño | Salir del círculo propio sin meterse en otro |
| Llamado | 2 (al entrar) | Rugido | 2 Goblins Saqueadores que atacan a su objetivo | Matarlos o alejarlos del ogro; mueren si muere el ogro |

## Qué cambia en difícil
- Mecánica extra (propuesta): el Garrotazo deja una grieta en el suelo que daña durante 4 s, y la Lluvia de rocas deja piedras que bloquean el paso (cobertura contra un nuevo grito en área).

## Recompensas
- Fase 0: nada.
- Propuesta: cofre personal con oro y una pieza Rara.

## Sonidos
Ver [AUDIO.md](../../AUDIO.md). Fuente: ElevenLabs.
| Sonido | Cuándo | Estado |
|---|---|---|
| Rugido | Al empezar la pelea | En juego (OgreRoar a 1,1 de tono) |
| Aviso | Antes del Pisotón y la Lluvia de rocas | En juego (BossWarn) |
| Ataques | Garrotazo / Pisotón / Rocas | En juego (OgreSmash / OgreStomp / OgreRock) |
| Cambio de fase | Rugido de la fase 2 | En juego (OgreRoar) |
| Recibe golpe | | Usa los impactos de la clase que pega |
| Muere | | En juego (OgreDeath) |

## Notas de prueba
- 26 nov 2026: la fase 2 entra al terminar el ataque en curso. Los ayudantes aparecen y pegan, y las rocas caen bien. Si todos salen de la arena, el ogro vuelve al centro con la vida llena, en fase 1 y sin ayudantes.
- Reaparece a los 45 s de morir.
