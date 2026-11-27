# Eternia — Guía visual: anexo técnico

**Estado:** Borrador, pendiente de aprobación · **Última actualización:** 26 nov 2026

Especificaciones para producir arte que cumpla la [guía visual](GUIA-VISUAL.md) en Roblox. Las reglas de estilo, los colores reservados, las clases y los enemigos se definen **solo** en la guía; aquí están las medidas, los presupuestos, las fichas de los 3 conceptos y la checklist. **Todos los números marcados como orientativos se validan en Studio y en un teléfono real antes de fijarlos.**

## Configuración actual (medida el 26 nov 2026)

| Qué | Valor hoy | Dónde se define |
|---|---|---|
| Cámara | Estándar de Roblox en tercera persona (Classic), zoom de 0,5 a 128 studs, campo de visión 70° | Valores por defecto (el proyecto no los cambia) |
| Iluminación | Voxel, sombras globales activas, Ambient negro, Brightness 2, hora 14:30 | `default.project.json` |
| Efectos de luz | Sky, Atmosphere, Bloom, SunRays y DepthOfField | Vienen del place, no del proyecto (no los controla Rojo) |
| Streaming | Activado (`StreamingEnabled`) | Place |
| Materiales en uso | SmoothPlastic, Metal, Wood, Fabric y Neon (efectos y ojos) | Cuerpos provisorios y efectos |
| UI móvil | Diseñada para 400 px de alto y escalada con UIScale (0,8 a 1,6); zonas seguras del dispositivo | `MobileController` |

## Cámara y legibilidad

Con un campo de visión vertical de 70°, la altura que se ve a una distancia *d* es de unos 1,4 × *d* studs. Estimación hecha con el simulador de iPhone 17 Pro horizontal (unos 380 px de alto útiles). Es solo una referencia de cálculo, no el teléfono de pruebas: ese será uno de gama media real, todavía por elegir.

| Distancia de cámara | Píxeles por stud | Qué significa |
|---|---|---|
| 15 studs (juego normal, a medir) | ≈ 18 | Una cabeza (1 stud) se ve de ~18 px |
| 30 studs | ≈ 9 | Un detalle de 0,25 studs ocupa 2 px: no existe |
| 60 studs | ≈ 4,5 | Solo se leen siluetas y colores |

Reglas orientativas derivadas (a validar con capturas en el teléfono de pruebas):

- Lo que identifica algo (pieza de clase, arma, orejas del goblin) mide **1 stud o más** en su lado mayor y **0,5 studs o más** de grosor.
- Detalles de menos de 0,25 studs no se modelan: van en la textura o no van.
- Un enemigo se reconoce por silueta y color a 40 studs (alcance de los ataques a distancia de hoy).
- Las zonas de peligro se leen desde la cámara en ángulo bajo: su borde y su relleno contrastan con el suelo de la zona.

Pendiente: medir la distancia de cámara habitual al jugar y decidir si se limita el zoom máximo (hoy 128 studs). Es una decisión de cámara, no de arte; no se cambia sin probarla.

## Materiales y texturas en Roblox

Roblox **no permite shaders propios**. El aspecto sale de los materiales del motor, del color de cada pieza y de las texturas de las mallas. Por eso:

- **"Color por cara" no existe como en otros motores.** Una MeshPart lleva una sola textura (o un SurfaceAppearance). El aspecto facetado se logra así:
  1. **Textura de paleta compartida:** una imagen pequeña con celdas de color plano; en Blender, las UV de cada cara se ponen sobre la celda de su color. Muchos modelos comparten la misma imagen.
  2. **Piezas separadas con su Color:** para cosas simples o del escenario, varias piezas con el color de la propiedad `Color` y un material del motor.
- **Materiales:** los de la [guía](GUIA-VISUAL.md#materiales). Si un material del motor no basta, se usa una variante de material (MaterialVariant) compartida, nunca una textura nueva por objeto.
- **Límites de Roblox (documentación oficial, nov 2026):** las texturas normales admiten hasta 4096 × 4096 px; los mapas de SurfaceAppearance (PBR), hasta 1024 × 1024 en general, con límites más bajos para algunos mapas y tipos de asset (por ejemplo, 256 px para los mapas que no son de color en accesorios rígidos). Roblox además baja la calidad de las texturas según el dispositivo y la carga.
- **Presupuesto práctico (orientativo):** 256 px para armas, accesorios y piezas chicas; 512 px en general; 1024 px solo para jefes. Son decisiones nuestras de rendimiento, por debajo de esos límites. Antes de crear una textura nueva, se revisa si sirve una existente.
- **Sin** texturas fotográficas, mapas de normales de detalle fino ni SurfaceAppearance realista.

## Personajes R15

- Base: avatar R15 del jugador. Las armaduras son **accesorios rígidos** colgados de los puntos estándar del rig (hombros, cabeza, cintura, espalda), así siguen cualquier animación R15.
- La pieza de silueta de cada clase ([guía](GUIA-VISUAL.md#personajes-jugadores)) va en un accesorio propio que los cosméticos no reemplazan.
- Las piezas grandes (hombreras, escudo) se prueban con correr, saltar, esquivar y cada habilidad de la clase para comprobar que no atraviesan el cuerpo de forma notoria.
- Escala: los enemigos se dimensionan respecto a un jugador R15 estándar (~5 studs).
- Pendiente: decidir si se limitan las proporciones de avatar (Rthro, cuerpos muy altos o chicos) en la configuración del juego para mantener la escala jugador–enemigo.

## Animación

Tiempos que ya usan los mobs (`Data/Mobs`) y que se mantienen como regla para el arte final:

| Ataque | Anticipación | Recuperación |
|---|---|---|
| Mordida y golpe rápido (araña, lobo) | 0,5 a 0,55 s | 0,8 s |
| Golpe normal (goblin) | 0,7 s | 0,9 s |
| Escupitajo a distancia (araña) | 0,9 s | 0,6 s |
| Carga (lobo) | 1,1 s | 1,4 s |
| Golpe de jefe (ogro) | 1,0 s | 1,0 s |
| Área grande de jefe (pisotón, lluvia de rocas) | 1,6 s | 0,8 a 1,2 s |

- **Anticipación:** dura todo el aviso rojo y se nota por la postura (se echa atrás, levanta el arma). Mínimo 0,5 s; 1 s o más si el golpe es fuerte; 1,5 s o más para áreas grandes de jefe.
- **Golpe:** rápido y claro, coincide con el momento del daño. El impacto se ve en quien lo recibe ([guía](GUIA-VISUAL.md#efectos-visuales)).
- **Recuperación:** quieto o lento, sin girar hacia el jugador. Es la ventana para contraatacar y crece con el daño del ataque.
- Las animaciones finales reemplazan las poses provisorias cambiando IDs en los datos, sin tocar código ([PLAN.md](PLAN.md), "Animación, efectos y sonido de combate").

## Presupuestos orientativos

Puntos de partida, **pendientes de validación en dispositivos reales**. Roblox limita cada malla a 20.000 triángulos; los límites de texturas están en [Materiales y texturas](#materiales-y-texturas-en-roblox).

### Por asset

| Asset | Triángulos | Texturas | Otras reglas |
|---|---|---|---|
| Set de armadura de clase (todas sus piezas juntas) | < 4.000 en total | 1 de 512 px | Máximo 6 accesorios. Cada pieza se revisa aparte según cómo se implemente (accesorio rígido o ropa en capas), con sus propios límites de Roblox |
| Arma o accesorio | < 1.500 | 256 px | — |
| Mob normal | < 3.000 (referencia actual) | 1 de 512 px | — |
| Élite | < 5.000 | 1 de 512 px | — |
| NPC | < 3.000 más el R15 | 1 de 512 px | — |
| Jefe | < 15.000 (referencia actual) | Hasta 1024 px | — |
| Árbol / arbusto | < 800 / < 200 | Paleta compartida | 3 variantes por zona como máximo, mismo MeshId repetido |
| Pieza de escenario chica / grande | < 500 / < 2.000 | Paleta compartida | — |
| Efecto de combate | — | Reutiliza texturas | ≤ 200 partículas (referencia actual), ≤ 2 luces de vida corta |

### Por escena (se mide, no se adivina)

Objetivos del plan ([PLAN.md](PLAN.md), "Presupuestos de rendimiento"): **30 FPS estables como mínimo en un teléfono de gama media** y **60 FPS como objetivo en PC**. Se valida la estabilidad, no solo el promedio:

- Tiempo por fotograma (frame time) durante la prueba completa, en milisegundos: 33,3 ms equivale a 30 FPS y 16,7 ms a 60 FPS.
- Tirones: cantidad de fotogramas que pasan claramente del tiempo objetivo, sobre todo al entrar en combate, al usar definitivas y en el cambio de fase del jefe.
- El peor 1% de los fotogramas, además del promedio.
- Temperatura y caída de rendimiento tras 10 minutos de juego seguido en el teléfono.

Los demás valores no tienen número todavía: se miden en el teléfono de referencia con el MicroProfiler y las estadísticas de render de Studio en la subárea de prueba y en el combate más cargado (jefe con todos los efectos).

- Llamadas de dibujo (draw calls) y triángulos visibles.
- Cantidad de MeshParts y de combinaciones distintas de MeshId, textura y material (cuantas menos, mejor: Roblox agrupa las copias idénticas).
- Partículas activas, emisores y luces dinámicas a la vez.
- Superficies transparentes superpuestas (cada capa cuesta).
- Humanoids activos (los mobs usan uno cada uno).

### Reglas de configuración en Studio

- `CollisionFidelity` en Box o Hull para decorado; Precise solo si se camina sobre la forma.
- `RenderFidelity` en Automatic (baja el detalle a distancia).
- `CastShadow` apagado en piezas chicas y en efectos.
- `CanTouch` y `CanQuery` apagados en decorado sin función.
- Todo lo repetido (árboles, rocas, cajas) usa el mismo MeshId **y** la misma textura, material y configuración de render. Roblox solo agrupa las copias (instancing) cuando todo eso coincide: el mismo MeshId con otra textura o material cuenta como un objeto distinto.
- Instance Streaming activo; los modelos grandes se agrupan para que carguen por zonas.

## Iluminación

Recomendación inicial, a validar con mediciones:

- Mantener **Voxel** (lo que hay hoy) mientras se mide. Probar **ShadowMap** en la subárea si las sombras de Voxel no dan suficiente volumen, y adoptarlo solo si mantiene 30 FPS estables en el teléfono de pruebas. **Future** no se usa salvo que una medición lo justifique.
- Subir el ambiente (hoy negro) a un tono medio para que el lado en sombra de personajes y enemigos no se vuelva negro.
- Bloom bajo; DepthOfField apagado o muy suave en juego (desenfoca enemigos lejanos); SunRays y Atmosphere según la zona.
- Luces dinámicas solo en efectos de vida corta y puntos de interés (fogatas, portales).
- Pendiente: traer la configuración de efectos de luz al proyecto (hoy vive solo en el place) para que cada prueba sea reproducible.

## Interfaz por plataforma

| | PC | Móvil y tablet |
|---|---|---|
| Habilidades | Barra abajo con la tecla visible en cada espacio | Botones en arco alrededor del pulgar derecho |
| Escalado | Por resolución | UIScale por altura (referencia 400 px, entre 0,8 y 1,6) |
| Zonas seguras | — | Las del dispositivo (muesca, barra de inicio) |
| Tamaño mínimo | Texto de 14 px | Botones de 44 px reales, texto de 14 px |
| Barras de vida | Sobre el enemigo y barra del jefe arriba | Igual, a la misma escala |

- Consola (gamepad y distancia de TV) es una posible ampliación futura, fuera del alcance actual. [PLAN.md](PLAN.md) la nombra en "Controles", pero el juego todavía no tiene soporte de gamepad ni reglas de interfaz para TV.
- Pendiente, en la UI provisoria (se corrige al hacer la UI final): el botón "Cambiar objetivo" mide unos 40 px reales en el simulador de iPhone (bajo el mínimo de 44) y varios textos usan de 11 a 13 px.

## Los 3 conceptos de prueba

Validan la guía **juntos**, como un mismo juego. Cada ficha sirve para revisar un resultado y también como instrucción para generarlo con IA. Todos se presentan con la misma luz (tarde, hora 14:30) y las mismas tomas:

1. Frente y perfil a 15 studs, con la cámara estándar de tercera persona.
2. La misma toma reducida a un cuarto (tamaño de celular).
3. La silueta en negro sólido (solo Warrior y Goblin; el escenario se valida por composición, lectura del espacio y contraste).
4. Los tres juntos en una misma imagen: el Warrior frente al Goblin en el rincón del Claro del Molino.

### 1. Warrior con armadura

- **Objetivo:** fijar cómo se ve un personaje de jugador: avatar R15 con armadura modular y la silueta de su clase.
- **Obligatorios:** avatar R15 de proporciones estándar; **hombreras grandes** (cada una al menos 1,3 veces el ancho del hombro, sobresaliendo por los lados); peto; **espada ancha** de unos 4 studs de largo y hoja de 0,6 studs de ancho o más; cinturón y botas.
- **Paleta:** metal acero en tonos medios `#8C96A5`, brillos `#E1EBFF`, acento de brasa `#FF8C3C`, cuero `#644630`.
- **Silueta:** forma de V invertida por las hombreras; la espada se distingue del cuerpo de frente y de perfil.
- **Materiales:** Metal en armadura y espada; SmoothPlastic en cuero y tela. Sin Neon.
- **Detalle:** caras planas, biselado leve en los bordes de las placas. Menos de 4.000 triángulos para la armadura y menos de 1.500 para la espada.
- **No debe:** usar verde menta, azul cielo ni dorado crítico como color principal; tener contorno negro; tener grabados finos o realismo.
- **Aprobado si:**
  - En negro sólido se reconoce como Warrior sin ver el color.
  - Reducido a un cuarto, se distinguen las hombreras y la espada.
  - Las hombreras no atraviesan la cabeza al correr ni al usar las 3 habilidades.
  - Está dentro de los presupuestos.

### 2. Goblin Saqueador

- **Objetivo:** fijar cómo se ve un mob normal y la familia goblin.
- **Obligatorios:**
  - Cuerpo encorvado de 0,8 a 1 vez la altura de un jugador.
  - **Orejas largas** hacia los lados, más anchas que la cabeza.
  - **Ojos en Neon.**
  - **Garrote grande** de madera, de al menos 0,5 studs de grosor.
  - Ropa de cuero y, como propuesta por su nombre, una bolsa de botín a la espalda.
- **Paleta:** piel verde oliva `#5F8C3C` (lejos del verde menta y del verde ácido), cuero `#64462D`, madera `#6E4B28`, **ojos ámbar en Neon** (`#FFB428` como propuesta). No rojos: un rojo permanente le quitaría fuerza al rojo de peligro, que solo aparece al cargar un ataque. Pendiente: los cuerpos provisorios del juego todavía usan ojos rojos; se cambian cuando se haga el modelo.
- **Silueta:** orejas y garrote visibles de frente; la postura agachada lo distingue de un jugador.
- **Materiales:** SmoothPlastic en el cuerpo y la ropa; Wood en el garrote; Neon solo en los ojos.
- **Detalle:** menos de 3.000 triángulos y una textura de paleta de 512 px.
- **No debe:** parecer simpático o de juguete, usar verde menta, ni ser solo un jugador pintado de verde.
- **Aprobado si:**
  - En negro sólido se distingue de un jugador.
  - En escala de grises, sobre el suelo del Claro del Molino, se distingue del pasto: su valor es claramente más claro u oscuro.
  - La pose de anticipación del golpe (garrote atrás) se lee a 15 studs.
  - Está dentro de los presupuestos.

### 3. Rincón del Claro del Molino

- **Objetivo:** fijar cómo se ve el escenario. Es la primera subárea del Bosque Sombrío (niveles 1 a 3), así que es un claro más iluminado dentro de un bosque oscuro.
- **Obligatorios:**
  - Suelo de pasto con un **camino** más claro.
  - Árboles low-poly en el borde, con no más de 3 variantes.
  - Rocas.
  - Un punto de interés con el color de acento de la zona.
  - Como propuesta por el nombre de la subárea, el molino de madera al fondo y cajas de un campamento goblin.
  - Rayos de luz entre los árboles y niebla baja en el borde del bosque.
- **Paleta:** la del Bosque Sombrío ([PLAN.md](PLAN.md), "Ambiente por zona"): verde oscuro y morado con saturación media-baja; el camino es un tono más claro que el pasto.
- **Silueta:** el claro se lee como espacio abierto para pelear, con bordes de árboles bien marcados.
- **Materiales:** Grass y terreno en el suelo; Wood en el molino, cercas y cajas; Slate en rocas. Neon solo en efectos (luciérnagas de noche, punto de interés).
- **Detalle:** árboles de menos de 800 triángulos y piezas grandes de menos de 2.000; paleta compartida; todo lo repetido con el mismo MeshId.
- **No debe:**
  - Usar colores más saturados que los personajes.
  - Tener fondos con detalle fino.
  - Tener luces o niebla que tapen el suelo.
- **Aprobado si:**
  - Una zona roja de peligro se ve claramente sobre su suelo desde la cámara estándar.
  - El Warrior y el Goblin destacan sobre el escenario en la toma conjunta.
  - Mantiene 30 FPS estables (sin tirones notorios) en el teléfono de pruebas con los mobs de la subárea.

## Checklist de aprobación

La guía se aprueba solo si **los 3 conceptos pasan todo, juntos**. Si uno falla, se corrige y se vuelve a revisar el conjunto.

- [ ] Silueta reconocible en negro sólido (Warrior y Goblin)
- [ ] Escenario legible por composición, lectura del espacio y contraste: claro abierto para pelear, camino visible, bordes marcados, personajes destacados
- [ ] Lectura correcta a tamaño reducido (un cuarto, como en celular)
- [ ] Paleta de Eternia y del Bosque Sombrío; los tres se ven del mismo juego en la toma conjunta
- [ ] Ningún conflicto con los colores reservados de combate, clase y rareza
- [ ] Geometría y texturas dentro de los presupuestos orientativos
- [ ] Hecho con técnicas posibles en Roblox (sin shaders, con paleta compartida y R15)
- [ ] Rendimiento aceptable: 30 FPS estables en el teléfono de pruebas de gama media, medidos también por tiempo de fotograma y tirones
- [ ] En combate: zonas rojas visibles, personaje no tapado por efectos, enemigos distinguibles
- [ ] Coherencia con el resto de los assets existentes

## Pendiente de validar

- Teléfono de pruebas: uno de gama media real (el iPhone 17 Pro del simulador solo sirvió para estimar).
- Distancia de cámara habitual y si se limita el zoom máximo.
- Voxel o ShadowMap, nivel de ambiente y configuración de los efectos de luz dentro del proyecto.
- Valores de presupuesto por asset y por escena, medidos en ese teléfono.
- Límites de proporciones del avatar del jugador.
- Elementos marcados como propuesta en las fichas (molino, campamento, bolsa de botín).
- Ajustes de la UI provisoria al mínimo de 44 px y 14 px.
