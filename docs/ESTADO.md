# Eternia — Estado del proyecto

Resumen de lo hecho y lo pendiente. El diseño completo está en [PLAN.md](PLAN.md); el catálogo de sonidos, en [AUDIO.md](AUDIO.md); las reglas de arte, en [GUIA-VISUAL.md](GUIA-VISUAL.md) y su [anexo técnico](GUIA-VISUAL-TECNICA.md).

**Fase actual:** 1 — Núcleo técnico · **Última actualización:** 27 nov 2026

## Fases

| Fase | Meses | Estado | Terminado cuando |
|---|---|---|---|
| 0 — Prototipo de combate | 0 a 1,5 | 🟢 Terminada | Al probarlo en PC y móvil, el combate se entiende sin explicación y dan ganas de seguir |
| 1 — Núcleo técnico | 1,5 a 3 | 🟡 En curso | 1 hora en Studio con varios clientes y bots que simulan 30 jugadores, sin errores de datos ni lag notable |
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
- [x] PC: teclas 1 a 6, Q esquivar, R definitiva. Los espacios 4 a 6 no se muestran hasta las especializaciones de la Fase 2 (antes se veían bloqueados)
- [x] Definitiva con barra de carga: se llena con el daño hecho, la curación y el daño recibido (doble); unas 2 por pelea contra el jefe de prueba. Una definitiva provisoria por clase: Torbellino, Martillo del alba, Andanada, Lluvia de meteoros, Himno divino y Pacto de sombras
- [x] Móvil: botones en arco alrededor del pulgar derecho (ataque, saltar, 1 a 3, esquivar con cargas, definitiva que se enciende al cargar y cambiar objetivo); reemplaza el botón de salto de Roblox. Probado en el simulador de iPhone 17 Pro y en un celular real
- [x] Las habilidades con objetivo respetan el foco: van al enemigo fijado o no se usan si está lejos
- [ ] Teclas reasignables (en el menú de opciones) — pasa a la Fase 1
- [x] Íconos en los botones por datos (campo `Icon`); el nombre se ve al pasar el mouse o con el dedo apretado
- [x] Íconos de las 18 activas de clase y las 6 definitivas: pintados con IA (Gemini), elegidos y subidos a Roblox ([PLAN.md](PLAN.md#íconos-de-habilidades))
- [x] Efectos, arma provisoria y acento de la UI de cada clase con su color nuevo ([GUIA-VISUAL.md](GUIA-VISUAL.md#código-de-color-de-combate-reservado))
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
- [ ] 3 conceptos de prueba en 3D (Warrior con armadura, Goblin Saqueador, rincón del Claro del Molino) aprobados juntos con la checklist del anexo (la parte de rendimiento en la tablet, postergada) — pasa a la Fase 1
- [ ] Medir en los dispositivos de prueba (tablet Redmi para rendimiento; Poco X8 Pro e iPhone para lectura): distancia de cámara, luz (Voxel o ShadowMap) y presupuestos por escena — **postergado**: por ahora solo Studio y simulador
- [x] Plantillas de fichas (zona, mazmorra, jefe, NPC, mob) — ver [fichas/](fichas/)
- [x] Fichas del jefe de prueba y los 3 mobs llenas (estado: En caja gris)
- [x] Ojos ámbar del Goblin provisorio (`#E67814`), sin el rojo de peligro
- [x] Ojos ámbar también en la Araña y el Ogro provisorios: ningún enemigo tiene ojos rojos

## Fase 1 — Tareas

### Pasan de la Fase 0
- [ ] 3 conceptos de prueba en 3D (Warrior, Goblin Saqueador, rincón del Claro del Molino) aprobados con la checklist del anexo; son la base para aprobar la guía visual
- [ ] Teclas reasignables en el menú de opciones

### Del plan
- [ ] Places de desarrollo, pruebas y producción
- [ ] ProfileStore, inventario, loot personal, XP y niveles
- [ ] Amenaza, IA de mobs y sistema de jefes por datos
- [ ] UI base: vida, recurso, barra de habilidades, inventario
- [ ] Localización: todo el texto en tablas, en español e inglés, y glosario de nombres iniciado
- [ ] Sistema de feedback por datos con precarga, avisos de ataques enemigos (zona y sonido) y modo de gráficos bajos
- [ ] Sonidos finales de Warrior y Mage, impactos, interfaz y momentos clave ([AUDIO.md](AUDIO.md))
- [ ] Guía visual aprobada

### Vistos al cerrar la Fase 0
- [x] Vida propia siempre visible: barra abajo, sobre la de Energía o Maná (la de Roblox solo aparecía al recibir daño)
- [x] Nombres de enemigos sin taparse: solo el objetivo fijado muestra nombre y números; los demás, una barra fina
- [x] HUD con menos texto: barras sin números (la vida se lee al pasar el mouse o con el dedo apretado), rastro de daño, bordes rojos con vida baja, espacios bloqueados ocultos, cargas del esquivar como puntos y definitiva que se enciende de abajo hacia arriba y brilla al llenarse
- [x] Barras finas de enemigos solo si están en combate o heridos
- [x] Esperas con un decimal en los últimos 3 s; cargas del esquivar en otro color mientras se recuperan

## Decisiones pendientes

- [ ] Modelado 3D y animación con IA en vez de encargos en Talent Hub (lo prefiere el dueño): falta elegir la herramienta (recomendada: Meshy o Tripo desde los conceptos 2D, limpieza en Blender e importación con Open Cloud) y su presupuesto

### Tomadas (27 nov 2026)

- [x] Normal de mazmorra jugable solo: sí, escalado de 1 a 4 jugadores y sin roles; el grupo queda para Difícil
- [x] Nivel máximo 50 al lanzamiento, con recorte de reserva: si la Fase 3 se atrasa más de un mes, 40 y el Volcán Infernal en la Temporada 1 (ver riesgos en [PLAN.md](PLAN.md#riesgos-principales))
- [x] Nombres de zonas, mazmorras y jefes: quedan los del plan y se fijan en el glosario de localización en la Fase 1
- [x] Estilo visual: low-poly estilizado ([GUIA-VISUAL.md](GUIA-VISUAL.md)), confirmado con los conceptos 2D aprobados; los 3 conceptos en 3D lo validan en el juego
- [x] Equipo: diseño y código con Claude Code; concept art, íconos, sonidos y música con IA; modelado 3D y animación por encargo en Talent Hub (ver [PLAN.md](PLAN.md#equipo))
- [x] Música final: ElevenLabs Music; un compositor solo si la primera pista no llega al nivel
- [x] Precios iniciales: los de referencia del plan (pase de temporada 400 Robux, Cristales de 80 a 1.700 Robux), ajustados con datos de la beta
- [x] Beta temprana solo por invitación desde el Discord; la beta abierta queda para la Fase 7
- [x] Idiomas al lanzamiento: español e inglés, como dice el plan

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
| 27 nov 2026 | Flujo de arte del plan actualizado: el concept art sale de Gemini con el script del proyecto y se aprueba antes de modelar; el modelado lo hace un artista o pasa por Blender, porque las IA de Roblox no respetan las fichas. Nueva skill `cerrar-cambio` (`.claude/skills/`) para revisar los documentos al terminar cada cambio |
| 27 nov 2026 | Color de cada clase en los datos (`Color` en `Data/Classes`) y aplicado: efectos de sus habilidades (Warrior carmesí, Paladín bronce, Ranger mostaza, Mage cobalto, Sacerdote blanco cálido, Brujo morado), arma provisoria (guarda carmesí, empuñadura mostaza, maza y escudo bronce y acero, orbe cobalto), borde de los espacios de habilidad en PC y móvil y franja en el selector de clase. Los anillos de suelo del Warrior pasan a acero porque el carmesí se confundía con las zonas rojas de peligro. Probado en Studio y en el simulador de iPhone 17 Pro |
| 27 nov 2026 | Ojos del Goblin provisorio cambiados de rojo a ámbar en Neon. El `#FFB428` de la guía técnica se veía amarillo con Neon, igual que el del lobo; se comparó lado a lado en Studio y se aprobó `#E67814`. Guía técnica y ficha del mob actualizadas. Después, Araña y Ogro también pasan a ámbar: el verde ácido del veneno se veía amarillo con Neon en la Araña y el amarillo se deja para el lobo. Fichas de los tres actualizadas |
| 27 nov 2026 | Decisiones pendientes tomadas según las recomendaciones del plan: Normal jugable solo, nivel 50 con recorte de reserva a 40, nombres actuales, low-poly estilizado, equipo chico con 3D y animación por encargo en Talent Hub, música con ElevenLabs Music, precios de referencia, beta temprana por invitación y español e inglés. Sigue abierto solo el presupuesto. El plan suma la sección Equipo y corrige la herramienta de concept art (Gemini) |
| 27 nov 2026 | **Fase 0 terminada**: el dueño probó el combate y le gusta, así que se cumple el criterio. Empieza la Fase 1. Pasan a la Fase 1 los 3 conceptos en 3D y las teclas reasignables; siguen postergadas las pruebas en dispositivos reales. En una prueba rápida en Studio se vio que la vida propia no se ve a vida llena y que los nombres de enemigos juntos se tapan. El dueño quiere el modelado 3D y la animación con IA en vez de Talent Hub; falta elegir herramienta y presupuesto |
| 27 nov 2026 | Barra de vida propia en el HUD (verde `#3CB45A`, rojo claro con 30% o menos, texto de 14 px) pegada encima de la de Energía o Maná, sin el texto "Energía 71" (a pedido del dueño), y sin la de Roblox. Los enemigos que no son el objetivo fijado llevan solo una barra fina, sin nombre ni números. En móvil la caja del HUD se achica a las barras para que queden abajo y lejos de los botones. Probado en Studio y en el simulador de iPhone 17 Pro |
| 27 nov 2026 | HUD más limpio, a pedido del dueño (intuitivo, poco invasivo, sin tanto texto): vida de 12 px pegada a la barra de recurso de 6 px, sin "Energía 71" ni "100 / 100" (el número sale al pasar el mouse o con el dedo apretado); rastro de daño crema que baja después de 0,4 s; bordes de la pantalla en rojo claro que laten con 30% de vida o menos (`LowHealthController`); espacios 4 a 6 ocultos hasta desbloquearse y barras al ancho de la fila; cargas del esquivar como dos puntos celestes a la izquierda de las barras (en móvil, puntos blancos en el botón, sin número); definitiva con el ícono que se enciende de abajo hacia arriba y aro que late al llenarse, sin %; barras finas de enemigos solo en combate o heridos. Probado en Studio y en el simulador de iPhone 17 Pro; en móvil los bordes rojos quedaban recortados por la muesca y se corrigió |
| 27 nov 2026 | Barra de recurso más fina que la de vida (12 y 6 px). Esperas: segundos enteros y, en los últimos 3 s, un decimal ("2.4"), sin número si solo corre la espera global; el texto queda en 20 px en PC y 22 px en móvil. Cargas del esquivar que se recuperan en otro color: gris acero en PC y azul oscuro en el botón de móvil. Probado en Studio y en el simulador de iPhone 17 Pro |
| 27 nov 2026 | Se quitan las pruebas con jugadores reales hasta la beta temprana: el criterio de la Fase 1 pasa a 1 hora en Studio con varios clientes y bots que simulan 30 jugadores, y antes de producción se prueba con varios clientes en Studio en vez de con 10 jugadores |
