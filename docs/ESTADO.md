# Eternia — Estado del proyecto

Resumen de lo hecho y lo pendiente. El diseño completo está en [PLAN.md](PLAN.md).

**Fase actual:** 0 — Prototipo de combate · **Última actualización:** 26 nov 2026

## Fases

| Fase | Meses | Estado | Terminado cuando |
|---|---|---|---|
| 0 — Prototipo de combate | 0 a 1,5 | 🟡 En curso | 10 testers juegan 20 min, entienden el combate sin explicación y quieren seguir |
| 1 — Núcleo técnico | 1,5 a 3 | ⚪ Pendiente | 30 jugadores juegan 1 hora sin errores de datos ni lag notable |
| 2 — Clases | 3 a 4,5 | ⚪ Pendiente | Cada especialización mata al muñeco dentro del 10% del promedio de su rol; tank y sanador cumplen en prueba de jefe |
| 3 — Mundo y mazmorras | 4,5 a 7 | ⚪ Pendiente | Se llega del nivel 1 al 50 y se matan los 15 jefes (hito: beta temprana, zonas 1 y 2) |
| 4 — Progresión y economía | 7 a 8 | ⚪ Pendiente | El oro ganado y gastado se equilibran en la analítica de la beta |
| 5 — Endgame y PvP | 8 a 9,5 | ⚪ Pendiente | Un grupo hace un sello +10 y las colas de PvP se llenan en menos de 90 s con 200 jugadores |
| 6 — Social, tienda y operación | 9,5 a 10,5 | ⚪ Pendiente | 100 compras de prueba entregadas bien y todos los eventos de analítica en el tablero |
| 7 — Pulido y lanzamiento | 10,5 a 12 | ⚪ Pendiente | Metas de rendimiento cumplidas, sin errores graves y retención día 1 de la beta ≥ 25% |

Estados: ⚪ Pendiente · 🟡 En curso · 🟢 Terminada

## Fase 0 — Tareas

### Preparación del proyecto
- [x] Proyecto Rojo creado y subido a GitHub
- [x] Selene, StyLua y Wally agregados con Rokit
- [x] Estructura de carpetas: `Services/` (servidor), `Controllers/` (cliente), `Data/` y `Remotes` (compartido)
- [x] Remotos con límite de llamadas por segundo por jugador (`RateLimiter` + `Remotes.OnServerEvent`)

### Combate
- [x] Ataque básico del Warrior validado en servidor (distancia, cooldown, daño) — combo de 3 golpes 12/12/22
- [x] Muñeco de práctica con barra de vida, números de daño y reacción al golpe
- [ ] Esquivar: dash con 2 cargas que se recuperan en 4 s
- [ ] Warrior: 3 habilidades
- [ ] Mage: ataque básico, Orbe arcano, Parpadeo y Bola de fuego
- [ ] Fijar objetivo automático y botón para cambiar

### Enemigos y zona
- [ ] Subárea de prueba en caja gris
- [ ] 3 tipos de mobs con IA simple (patrulla, persigue, ataca, vuelve)
- [ ] Jefe de prueba con 2 fases

### Controles
- [ ] PC: teclas 1 a 6, Q esquivar, R definitiva
- [ ] Móvil: botones en arco alrededor del pulgar derecho

### Diseño (fuera del código)
- [ ] Guía visual en borrador
- [x] Plantillas de fichas (zona, mazmorra, jefe, NPC, mob) — ver [fichas/](fichas/)
- [ ] Fichas del jefe de prueba y los 3 mobs (creadas en borrador, falta llenarlas)

### Prueba
- [ ] Sesión con 10 testers de 20 minutos

## Decisiones pendientes

- [ ] ¿Normal de mazmorra jugable solo, o siempre en grupo?
- [ ] ¿Nivel máximo 50 al lanzamiento, o 40 con la quinta zona en la primera temporada?
- [ ] ¿Nombres finales de zonas, mazmorras y jefes?
- [ ] ¿Estilo visual: low-poly estilizado, o más detallado?
- [ ] ¿Tamaño del equipo y quién hace código, arte 3D, animación y música?
- [ ] ¿Presupuesto para herramientas de pago y para contratar en Talent Hub?
- [ ] ¿Precio del pase de temporada y de los Cristales?
- [ ] ¿Beta temprana abierta a todos o solo por invitación de Discord?
- [ ] ¿Idiomas al lanzamiento: solo español, o español e inglés?

## Registro

| Fecha | Qué se hizo |
|---|---|
| 25 nov 2026 | Plan por fases escrito |
| 26 nov 2026 | Proyecto Rojo subido a GitHub; creado este archivo de estado |
| 26 nov 2026 | Selene, StyLua y Wally instalados; estructura de Services, Controllers, Data y Remotes con cargador Init/Start |
| 26 nov 2026 | Documentos movidos a `docs/`; plantillas de fichas y borradores del jefe de prueba y 3 mobs |
| 26 nov 2026 | Límite por jugador en remotos (cubeta de fichas): UseAbility 10/s, Dodge 3/s; probado en Studio |
| 26 nov 2026 | Muñecos de práctica y combo básico del Warrior validado en servidor (alcance, cono frontal, ritmo); daño en lotes de 0,1 s; barras, números y destello en cliente |
