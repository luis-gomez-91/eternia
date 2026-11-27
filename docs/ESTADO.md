# Eternia — Estado del proyecto

Resumen de lo hecho y lo pendiente. El diseño completo está en [PLAN.md](PLAN.md); el catálogo de sonidos, en [AUDIO.md](AUDIO.md); las reglas de arte, en [GUIA-VISUAL.md](GUIA-VISUAL.md) y su [anexo técnico](GUIA-VISUAL-TECNICA.md).

**Fase actual:** 0 — Prototipo de combate · **Última actualización:** 27 nov 2026

## Fases

| Fase | Meses | Estado | Terminado cuando |
|---|---|---|---|
| 0 — Prototipo de combate | 0 a 1,5 | 🟡 En curso | Al probarlo en PC y móvil, el combate se entiende sin explicación y dan ganas de seguir |
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
- [x] Place guardado en Roblox (privado), con permisos de MCP para subir assets desde `assets/audio`
- [x] Clave de ElevenLabs en `.env` (ignorado por Git)

### Combate
- [x] Ataque básico del Warrior validado en servidor (distancia, cooldown, daño) — combo de 3 golpes 12/12/22
- [x] Muñeco de práctica con barra de vida, números de daño y reacción al golpe
- [x] Esquivar: dash con 2 cargas que se recuperan en 4 s (Q; 16 studs, 0,3 s de invulnerabilidad)
- [x] Warrior: 3 habilidades — Tajo (1), Grito de batalla (2), Embestida (3); Energía generada por el ataque básico
- [x] Las otras 5 clases con su ataque básico y sus 3 activas de clase, validadas en servidor:
  - Paladín: maza (2 golpes), Golpe sagrado, Consagración, Luz sanadora
  - Ranger: disparo rápido, Disparo potente, Lluvia de flechas, Retirada
  - Mage: proyectil mágico, Orbe arcano, Parpadeo, Bola de fuego (se usa en vez de Barrera de maná para probar daño en área y quemadura)
  - Sacerdote: rayo de luz, Castigo, Curación, Nova sagrada
  - Brujo: descarga de sombra, Corrupción, Drenar vida, Explosión de sombra
- [x] Maná: empieza lleno, se recupera 2% por segundo y un poco con el ataque básico; la barra muestra Energía o Maná según la clase
- [x] Selector de clase provisorio (arriba a la izquierda) hasta que exista la selección de personaje
- [x] Fijar objetivo automático (enemigo visible más cerca del centro de la pantalla) y T para cambiar; anillo rojo bajo el objetivo

### Feedback de combate (provisorio, se cambia por el arte final)
- [x] Sistema por datos: cada ataque y habilidad indica su animación, efecto y sonido (`Data/Feedback`, `Data/Poses`)
- [x] Warrior: animaciones del combo, Tajo, Grito, Embestida y esquivar (poses en código, sin assets)
- [x] Warrior: efectos (arco del tajo, onda del grito, estelas, chispa de impacto) y sonidos
- [x] Sonidos propios del Warrior, esquivar e impactos generados con ElevenLabs y subidos a Roblox
- [x] Las otras 5 clases: poses, efectos (proyectiles, rayos, columnas de luz, explosiones, zona en el suelo, lluvia de flechas), arma provisoria y 22 sonidos con ElevenLabs
- [x] Impactos por tipo (arma, maza, flecha, arcano, fuego, sombra) y números verdes de curación

### Enemigos y zona
- [x] Subárea de prueba en caja gris, armada en código (`ArenaService`): fogata de aparición, entrada, 3 campamentos, plataforma con rampa y arena del jefe
- [x] 3 tipos de mobs con IA simple (patrulla, persigue, ataca, vuelve): Goblin Saqueador, Araña Escupidora y Lobo Gris (`MobService`, datos en `Data/Mobs`)
- [x] Avisos de ataques enemigos: zona roja en el suelo que se llena hasta el golpe; el daño cae donde se avisó, así que se evita saliendo o esquivando
- [x] Los jugadores reciben daño y mueren; el esquivar los hace invulnerables ("Esquivado"); números rojos de daño recibido
- [x] Jefe de prueba con 2 fases: Ogro del Claro (Garrotazo, Pisotón; en fase 2 Lluvia de rocas y 2 goblins de ayuda), barra de jefe arriba de la pantalla
- [x] Sonidos propios de mobs y jefe con ElevenLabs (16, subidos a Roblox)

### Controles
- [x] PC: teclas 1 a 6, Q esquivar, R definitiva. Los espacios 4 a 6 se ven bloqueados (Nv 10, 20 y 30) hasta las especializaciones de la Fase 2
- [x] Definitiva con barra de carga: se llena con el daño hecho, la curación y el daño recibido (doble); unas 2 por pelea contra el jefe de prueba. Una definitiva provisoria por clase: Torbellino, Martillo del alba, Andanada, Lluvia de meteoros, Himno divino y Pacto de sombras
- [x] Móvil: botones en arco alrededor del pulgar derecho (ataque, saltar, 1 a 3, esquivar con cargas, definitiva con % y cambiar objetivo); reemplaza el botón de salto de Roblox. Probado en el simulador de iPhone 17 Pro y en un celular real
- [x] Las habilidades con objetivo respetan el foco: van al enemigo fijado o no se usan si está lejos
- [ ] Teclas reasignables (en el menú de opciones, más adelante)
- [x] Íconos en los botones por datos (campo `Icon`); el nombre se ve al pasar el mouse o con el dedo apretado
- [x] Íconos de las 18 activas de clase y las 6 definitivas: pintados con IA (Gemini), elegidos y subidos a Roblox ([PLAN.md](PLAN.md#íconos-de-habilidades))
- [ ] Efectos, arma provisoria y acento de la UI de cada clase con su color nuevo ([GUIA-VISUAL.md](GUIA-VISUAL.md#código-de-color-de-combate-reservado))
- [ ] Confirmar en el celular que los íconos se leen mejor que el nombre y que el toque corto usa la habilidad (en el simulador no se pudo probar el toque corto) — **postergado**: por ahora solo Studio y simulador
- [x] Prueba de hechizo con carga: Bola de fuego del Mage con 1 s, movimiento al 50% y esquivar que cancela sin gastar; probada en PC y móvil (reglas en [PLAN.md](PLAN.md#hechizos-con-carga))

### Publicación de prueba
- [x] Juego publicado en privado como "Eternia — Desarrollo", con descripción y género
- [x] Clasificación de contenido: Minimal en Roblox, E (ESRB) y PEGI 3, sin restricciones por región
- [x] Cuentas de prueba con permiso Playtest (luis_gomu y tiburonssin1991); se entra con el enlace o el QR del juego
- [ ] Confirmar que las cuentas de prueba entran al juego (el botón Jugar salía en gris antes de la clasificación) — **postergado**: por ahora solo Studio y simulador
- [ ] Prueba de rendimiento en la tablet Redmi — **postergado**: por ahora solo Studio y simulador

### Diseño (fuera del código)
- [x] Guía visual en borrador: [GUIA-VISUAL.md](GUIA-VISUAL.md), con anexo técnico [GUIA-VISUAL-TECNICA.md](GUIA-VISUAL-TECNICA.md) (presupuestos orientativos, fichas y checklist)
- [x] Conceptos 2D de los 3 conceptos de prueba y de la toma conjunta aprobados: [assets/concepts/](../assets/concepts/) (generados con Gemini desde las fichas del anexo)
- [ ] 3 conceptos de prueba en 3D (Warrior con armadura, Goblin Saqueador, rincón del Claro del Molino) aprobados juntos con la checklist del anexo (la parte de rendimiento en la tablet, postergada)
- [ ] Medir en los dispositivos de prueba (tablet Redmi para rendimiento; Poco X8 Pro e iPhone para lectura): distancia de cámara, luz (Voxel o ShadowMap) y presupuestos por escena — **postergado**: por ahora solo Studio y simulador
- [x] Plantillas de fichas (zona, mazmorra, jefe, NPC, mob) — ver [fichas/](fichas/)
- [x] Fichas del jefe de prueba y los 3 mobs llenas (estado: En caja gris)

## Decisiones pendientes

- [ ] ¿Normal de mazmorra jugable solo, o siempre en grupo?
- [ ] ¿Nivel máximo 50 al lanzamiento, o 40 con la quinta zona en la primera temporada?
- [ ] ¿Nombres finales de zonas, mazmorras y jefes?
- [ ] ¿Estilo visual: low-poly estilizado, o más detallado? Propuesta en borrador: low-poly estilizado ([GUIA-VISUAL.md](GUIA-VISUAL.md)); se cierra cuando se aprueben los 3 conceptos
- [ ] ¿Tamaño del equipo y quién hace código, arte 3D, animación y música?
- [ ] ¿Presupuesto para herramientas de pago (incluye ElevenLabs) y para contratar en Talent Hub?
- [ ] ¿Música final: generada con ElevenLabs Music o hecha por un compositor?
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
| 26 nov 2026 | Esquivar con Q: dash en cliente, cargas e invulnerabilidad validadas en servidor; indicador de cargas en pantalla |
| 26 nov 2026 | Habilidades de clase del Warrior (Tajo, Grito de batalla, Embestida) con Energía, esperas y espera global de 0,5 s validadas en servidor; barra de habilidades en pantalla |
| 26 nov 2026 | Plan: la Fase 0 suma feedback provisorio de combate (animaciones, efectos y sonidos simples por datos); habilidades de clase del Warrior en el plan |
| 26 nov 2026 | Plan: animación, efectos y sonido en 3 niveles (provisorio, sistema en Fase 1, final por fases); nuevo riesgo de cuello de botella de animación |
| 26 nov 2026 | Feedback provisorio del Warrior: señales por datos (pose o animación, efectos, sonido), poses R15 en código, arcos, ondas, estelas, aura y chispas; los demás jugadores lo ven por `CombatCue`; espada provisoria en la mano; el esquivar ya no hace caer al personaje al chocar |
| 26 nov 2026 | Sacudida de cámara al acertar golpes propios (más fuerte en crítico); grupos de volumen SFX, Música, Ambiente y Voces |
| 26 nov 2026 | Plan: fuentes de audio (ElevenLabs para sonidos propios, Creator Store solo con licencia, APM para música de prueba) y reglas de subida |
| 26 nov 2026 | Plan: todos los sonidos del juego por categoría con su fuente y su fase; catálogo nuevo [AUDIO.md](AUDIO.md) con guía de estilo; sección "Sonidos" en las fichas |
| 26 nov 2026 | Fijar objetivo automático con T para cambiar. Las 6 clases jugables con sus 3 activas de clase, Maná, curación, daño en el tiempo, proyectiles y selector de clase provisorio; 22 sonidos nuevos con ElevenLabs (unos 360 créditos). Las activas de clase del Paladín, Ranger, Sacerdote y Brujo se definieron ahora (ver PLAN.md) |
| 26 nov 2026 | Subárea de prueba en caja gris con 3 mobs (Goblin Saqueador, Araña Escupidora, Lobo Gris) y jefe de prueba de 2 fases (Ogro del Claro). IA en servidor: patrulla, detecta, persigue, avisa con zona roja en el suelo, ataca y vuelve inmune a su sitio. Daño a jugadores con invulnerabilidad del esquivar. Fichas llenas. Arreglado: las barras de vida desaparecían al morir el jugador |
| 26 nov 2026 | Controles: teclas 1 a 6 y R; barra de definitiva y una definitiva provisoria por clase; botones táctiles en arco para móvil. 16 sonidos de mobs y jefe generados con ElevenLabs, sin subir todavía (la red de la oficina bloquea Roblox) |
| 26 nov 2026 | Guía visual en borrador: estilo low-poly estilizado, colores reservados de combate, siluetas por clase y reglas de enemigos, efectos e interfaz. La curación pasa a verde menta y el veneno y la magia vil a verde ácido, para no confundirlos |
| 26 nov 2026 | Juego publicado en privado ("Eternia — Desarrollo"), clasificación de contenido Minimal / PEGI 3 y cuentas de prueba con Playtest. Primera prueba en un celular real: el botón de saltar no funcionaba (el control de Roblox borraba la orden) y la Embestida iba al enemigo más cercano en vez del fijado; ambos corregidos |
| 26 nov 2026 | Dispositivos de prueba: tablet Redmi para rendimiento, Poco X8 Pro e iPhone 17 Pro para lectura (no hay un teléfono de gama media). Ajustes de consistencia en el anexo |
| 26 nov 2026 | Anexo técnico corregido: límites reales de texturas de Roblox (4096 px normales, 1024 px PBR), ojos ámbar para el goblin (pendiente en el modelo), estabilidad de fotogramas en las mediciones, instancing, armaduras y silueta solo para personajes. Sigue en borrador |
| 26 nov 2026 | Guía visual completada sin cambiar el estilo ni los colores: geometría, materiales (Metal en armas y armaduras), luz, cámara, R15, niveles de enemigos y tiempos de animación. Nuevo anexo técnico con presupuestos orientativos, fichas de los 3 conceptos y checklist. Sigue en borrador |
| 26 nov 2026 | Se quita la sesión con 10 testers: cada cambio se prueba en casa en PC y móvil |
| 26 nov 2026 | Primeros sonidos propios con ElevenLabs (combo, Tajo, Grito, Embestida, esquivar, impacto y crítico) subidos a Roblox; place guardado en Roblox para poder subir assets; la precarga deja los sonidos vivos para que suenen sin retraso (de ~330 ms a 1 frame) |
| 26 nov 2026 | Plan: hechizos con carga solo en algunos hechizos grandes de especialización (cargas de 0,5 a 1,5 s y canalizados), moviéndose al 50% y con esquivar que cancela; el resto sigue instantáneo. Lista por especialización en el plan |
| 26 nov 2026 | Bola de fuego del Mage con carga de 1 s: barra de carga, brillo visible para todos, movimiento al 50%; esquivar, perder el objetivo o salirse de alcance cancela sin gastar. El servidor valida el tiempo de carga y el esquive. Daño 55 y salpicadura 20 (antes 35 y 15). Funciona en PC y móvil |
| 27 nov 2026 | Subidos a Roblox los 16 sonidos de mobs y jefe (Goblin, Araña, Lobo y Ogro del Claro); ya no reusan los de las clases con otro tono |
| 27 nov 2026 | Plan: íconos de habilidades (unos 170) con contorno grueso y sin texto, marco según el tipo, ID en los datos; provisorios en la Fase 0, los de especialización en la Fase 2 |
| 27 nov 2026 | Íconos provisorios de las 18 activas de clase y las 6 definitivas: dibujados por código (`assets/icons/draw_icons.py`, figura plana con contorno grueso y colores de la clase), subidos a Roblox como Image e ID en `Data/Abilities`. Barra de PC con ícono y nombre al pasar el mouse; botones de móvil con ícono, nombre con el dedo apretado 0,4 s (al soltar no se usa) y % de la definitiva encima del ícono. Probado en Studio y en el simulador de iPhone 17 Pro |
| 27 nov 2026 | Primera tanda de íconos no aprobada. Color propio por clase en la guía visual (Warrior carmesí, Paladín dorado bronce, Ranger mostaza, Mage cobalto, Sacerdote blanco cálido, Brujo morado), ajustado para no chocar con los colores reservados. Los íconos se aprueban antes de subirlos |
| 27 nov 2026 | Los íconos de habilidades pasan a ilustración pintada de borde a borde, opaca y con luz dramática (inspirada en los RPG clásicos), generada con IA de imágenes por API. Instrucciones en `assets/icons/prompts.json`; tope de 10 USD para la prueba de los 24 íconos. Los botones muestran el ícono a tamaño completo |
| 27 nov 2026 | Íconos pintados de las 24 habilidades generados con Gemini (`gemini-3.1-flash-image`, 43 imágenes en total con las pruebas), elegidos, recortados a 256 px y subidos a Roblox. Probados en PC y en el simulador de iPhone 17 Pro: cargan los 24 y se apagan en espera o sin recurso en los dos controles. El proyecto de Google llegó a su tope de gasto mensual a mitad de la tanda |
| 27 nov 2026 | Se postergan las pruebas en dispositivos reales (celular, tablet Redmi, mediciones) y la prueba de las cuentas de Playtest para no frenar el avance; mientras tanto se prueba en Studio y en su simulador de dispositivos |
| 27 nov 2026 | La IA de mallas de Roblox no respetó la ficha del Goblin (orejas cortas, verde lima, armas inventadas), así que primero se hacen conceptos 2D con Gemini (`assets/concepts/prompts.json`, mismo script de los íconos con `--prompts`). Aprobados el Warrior con hombreras en punta, el Goblin, el Claro del Molino visto desde la cámara de juego y la toma conjunta; quedan como referencia para modelar en 3D |
| 27 nov 2026 | Goblin en 3D con las herramientas de IA de Roblox usando el concepto aprobado como referencia: 3 intentos más, ninguno cumple la ficha (modelo por piezas: redondo y de juguete; mallas: orejas cortas, verde lima y garrote chico). Los modelos 3D de los conceptos necesitan otro camino (artista o Blender, importados con Open Cloud) |
