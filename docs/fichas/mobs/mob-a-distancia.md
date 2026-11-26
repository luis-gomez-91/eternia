# Mob: Araña Escupidora (a distancia)

**Estado:** En caja gris · **Fase:** 0 · **Zona o mazmorra:** Subárea de prueba (luego Bosque Sombrío)
**Concepto visual:** pendiente · **Caja gris:** campamento de arañas de la subárea de prueba, entre pilares (`ArenaService`); datos en `Data/Mobs` (`VenomSpider`)

## Idea
Dispara desde lejos. Obliga a moverse y a acercarse o usar habilidades de distancia. Los pilares de su campamento cortan los escupitajos: enseñan a cubrirse.

## Aspecto
Araña grande morada oscura, con una marca verde brillante en el abdomen, ojos rojos y colmillos verdes. Provisorio: esferas y patas de bloques (`Spider`).

## Comportamiento
- **Patrulla:** casi quieta (5), hasta 6 studs de su sitio.
- **Distancia a la que detecta:** 26 studs (más que los demás). Suma a los mobs quietos a menos de 14 studs.
- **Persigue:** se acerca hasta ~24 studs y dispara. Si el jugador se le acerca a menos de 12, retrocede.
- **Vuelve a su sitio cuando:** se aleja más de 50 studs de su sitio o no queda nadie cerca.

## Ataques (1 o 2)
| Ataque | Aviso visual | Qué hace | Daño | Espera |
|---|---|---|---|---|
| Escupitajo | Línea roja de 2,5 de ancho hasta 40 studs (o hasta la primera pared) que se llena en 0,9 s | Proyectil de veneno recto a 45 studs/s; pega al primero que cruza, o choca con la pared | 9 | 2,6 s |
| Mordida | Rectángulo rojo de 5 × 4 al frente, 0,5 s | Solo si el jugador se le pega | 7 | 3 s |

## Vida y daño por nivel
Propuesta: +12% por nivel. En la prueba es nivel 2. Tiene menos vida que el goblin a cambio de pegar de lejos.
| Nivel | Vida | Daño (escupitajo / mordida) |
|---|---|---|
| 1 | 125 | 8 / 6 |
| 2 (prueba) | 140 | 9 / 7 |
| 10 | 265 | 17 / 13 |

## Qué suelta
- Fase 0: nada.
- Propuesta para Fase 4: oro y "Glándula de veneno" (material de encargos del tablón).

## Sonidos
Ver [AUDIO.md](../../AUDIO.md). Fuente: ElevenLabs.
| Sonido | Cuándo | Estado |
|---|---|---|
| Detectar | Ve al jugador | Por generar |
| Ataque | Escupitajo / Mordida | Provisorio: Corrupción del Brujo a 1,5 / impacto a 1,35 |
| Recibe golpe | | Usa los impactos de la clase que pega |
| Muere | | Por generar |

## Notas de prueba
- 26 nov 2026: acierta desde ~25 studs a un jugador quieto. Falta probar que los pilares corten el escupitajo en una partida real.
