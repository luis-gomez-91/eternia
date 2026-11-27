# Eternia — Plan por Fases y Recomendaciones

25 nov 2026 · @Luis

> Avance y tareas: ver [ESTADO.md](ESTADO.md).

## Resumen

Eternia es un RPG de acción en Roblox para jugadores de 10 a 25 años: una ciudad central con portales a 5 zonas, una mazmorra por zona y nivel máximo 50. Es "Dungeon Quest con clases, especializaciones, roles de tank y sanador, y PvP", no un WoW en Roblox.

**Ciclo de juego:** entrar a una zona → matar mobs y hacer encargos → subir de nivel y sacar loot → entrar a la mazmorra y matar al jefe → mejorar el equipo en el herrero → desbloquear la siguiente zona. En el nivel 50 el ciclo pasa a los Sellos de Eternia y al PvP.

**Pilares**

- **Combate que se siente bien:** rápido, con impacto, jugable en móvil y PC.
- **Identidad de clase:** 6 clases y 18 especializaciones con roles claros (tank, sanador, daño, soporte).
- **Loot que motiva:** cada sesión de 10 a 20 minutos da algo que mejora al personaje.
- **Jugar con amigos:** grupos de 4 para mazmorras y PvP por equipos.
- **Justo y seguro:** monetización solo cosmética, sin comercio entre jugadores, pensado para menores.

**Alcance:** 6 clases, 5 zonas, 5 mazmorras con 3 jefes cada una, modo difícil, Sellos de Eternia, PvP de Captura del Estandarte y Arena, herrero, monturas cosméticas y temporadas de 8 semanas. Lanzamiento estimado en unos 12 meses de desarrollo.

## Estructura del mundo

El mundo es una ciudad central, Ciudadela de Eternia, con portales a 5 zonas semiabiertas. Cada portal se enciende al llegar al nivel de la zona; no hay mundo abierto continuo.

[embed: node/205f4143-525f]

Cada portal lleva a una zona y cada zona termina en su mazmorra; PvP, Sellos y eventos salen también de la ciudad.

### Ciudadela de Eternia (la ciudad central)

|   |   |   |
|---|---|---|
|Lugar|Qué hay|Desde nivel|
|Plaza de portales|5 portales de zona en círculo, apagados hasta el nivel requerido|1|
|Herrero|Mejorar, transferir mejoras y desmontar|1|
|Tienda general|Pociones, comida, materiales básicos|1|
|Entrenadores de clase|Elegir especialización, reiniciar puntos, ver builds|1 (especialización en el 10)|
|Tablón de mazmorras|Buscador de grupo por rol, modo normal o difícil|10|
|Arena del Estandarte|Colas de PvP, ranking y vendedor de Honor|20|
|Portal de los Sellos|Sellos de Eternia y cofre semanal|50|
|Plaza de eventos|Portales temporales de evento y jefe de temporada|Variable|
|Salón de la fama|Rankings, mejores tiempos de Sellos, top de PvP|1|
|Establo y vestidor|Monturas, mascotas, apariencias (transmog)|1|
|Tienda de Robux|Solo cosméticos|1|
|Zona de práctica|Muñecos de entrenamiento para probar builds|1|

### Reglas de los portales

- **Desbloqueo:** el portal de cada zona se enciende al llegar a su nivel mínimo (1, 10, 20, 30, 40).
- **Viaje rápido:** desde cualquier zona hay un botón para volver a la ciudad (5 segundos de canalización, se cancela al recibir daño).
- **Volver a zonas anteriores:** siempre se puede, para colecciones, logros o ayudar a amigos. Un jugador de nivel alto recibe XP reducida en zonas bajas.
- **Grupo:** si el líder del grupo cruza un portal, el resto recibe la opción de seguirlo.
- **Mazmorras, PvP y Sellos:** se juegan en servidores privados aparte; la ciudad y las zonas comparten un mismo servidor.

### Primera sesión (tutorial)

El jugador aparece en un barco que llega a la Ciudadela. Elige clase, aprende a moverse, atacar, esquivar y usar 2 habilidades contra 3 mobs. Un guía lo lleva por la ciudad (herrero, tablero, portal) y lo deja en el portal del Bosque Sombrío. Duración máxima: 3 minutos, y se puede saltar.

## Las 5 zonas

Cada zona cubre 10 niveles, tiene 3 subáreas de dificultad creciente y termina en la puerta de su mazmorra. Cada una tiene su color, música y enemigos propios.

|   |   |   |   |   |   |   |
|---|---|---|---|---|---|---|
|Zona|Niveles|Ambiente|Enemigos|Élite raro|Evento de zona|Mazmorra|
|Bosque Sombrío|1–10|Bosque verde oscuro, niebla, luciérnagas, ruinas cubiertas de musgo|Lobos, arañas, goblins|Colmillo Gris, lobo alfa|Invasión goblin|Guarida de Raíz Negra|
|Arenas Rojas|10–20|Desierto de dunas rojas, oasis, templos enterrados|Escorpiones, momias, bandidos|Escorpión Rey|Tormenta de arena con bandidos|Tumba del Faraón Olvidado|
|Picos Helados|20–30|Montaña nevada, cuevas de hielo azul, aurora en el cielo|Yetis, lobos de hielo, enanos corruptos|Yeti Ancestral|Avalancha y ataque de gigantes|Fortaleza de Escarcha|
|Pantano Maldito|30–40|Agua verde, árboles muertos, niebla densa, luna roja|No-muertos, brujas, criaturas del pantano|Bruja Mor'gana|Luna de sangre|Catedral Hundida|
|Volcán Infernal|40–50|Ríos de lava, obsidiana, cielo rojo, ceniza cayendo|Demonios, elementales de fuego, dracónidos|Señor de Lava|Erupción|Guarida del Dragón|

### Subáreas por zona

|   |   |   |   |
|---|---|---|---|
|Zona|Entrada (niveles 1–3 de la banda)|Centro (4–7)|Fondo (8–10)|
|Bosque Sombrío|Claro del Molino (1–3)|Bosque Profundo (4–7)|Ruinas del Templo Verde (8–10)|
|Arenas Rojas|Oasis de Sal (10–13)|Mar de Dunas (14–17)|Ciudad Enterrada (18–20)|
|Picos Helados|Campamento Enano (20–23)|Paso del Viento (24–27)|Cumbre Helada (28–30)|
|Pantano Maldito|Aldea Hundida (30–33)|Ciénaga de los Muertos (34–37)|Cementerio Antiguo (38–40)|
|Volcán Infernal|Faldas de Ceniza (40–43)|Forja Demoníaca (44–47)|Cráter del Dragón (48–50)|

### Contenido fijo de cada zona

- **Tablón de encargos:** 10 a 12 misiones cortas por zona (matar, recolectar objetos que sueltan los mobs, escoltar, activar altares). Dan XP, oro y materiales del herrero.
- **Misión de historia:** 3 a 4 misiones encadenadas por zona que presentan al jefe de la mazmorra y terminan abriendo su puerta.
- **Élite raro:** aparece cada 10 minutos en un punto fijo; da loot raro asegurado la primera vez al día. Derrotarlo una vez es requisito para la mazmorra.
- **Evento de zona:** cada 30 minutos, dura 5 minutos; todos los jugadores de la zona pelean juntos y reciben un cofre según su participación.
- **Cofres escondidos:** 10 por zona, cada uno una sola vez por cuenta; dan oro, cosméticos y puntos de colección.
- **Puntos de descanso:** una fogata por subárea que recupera vida fuera de combate y sirve de punto de reaparición.
- **Puerta de la mazmorra:** al fondo; se abre con nivel mínimo, misión de historia completa y élite derrotado.

### Reglas de dificultad

- Mobs con nivel visible y color: gris (muy fácil, sin XP), verde, amarillo, naranja, rojo (5 o más niveles arriba).
- Morir en una zona no quita nada: reapareces en la última fogata con 10 segundos de espera.
- Los mobs reaparecen en 30 a 60 segundos; el loot es personal, nadie roba muertes.

## Mazmorras y jefes

Hay una mazmorra por zona, para 1 a 4 jugadores, con 3 jefes cada una: 2 intermedios y un jefe final. Normal dura 10 a 15 minutos y difícil 15 a 20.

### Las 5 mazmorras

|   |   |   |   |   |   |   |
|---|---|---|---|---|---|---|
|Mazmorra|Normal desde|Difícil desde|Jefe 1|Jefe 2|Jefe final|Mecánica principal|
|Guarida de Raíz Negra|Nivel 7|Nivel 10|Gruñón el Cazador|Madre Araña|Rey Goblin Krag|Esquivar zonas marcadas en el suelo|
|Tumba del Faraón Olvidado|17|20|Guardián de Arena|Sacerdotisa Momia|Faraón Ankhamon|Romper escudos y cortar curaciones|
|Fortaleza de Escarcha|27|30|Capitán Borin|Gólem de Hielo|Reina de Escarcha|Moverse para no congelarse y romper hielo a aliados|
|Catedral Hundida|37|40|Abominación|Nigromante Vael|El Lich|Matar adds a tiempo y separarse|
|Guarida del Dragón|47|50|Guardián Dracónido|Elemental Primordial|Ignaroth, el Dragón|Fases aéreas, cubrirse del aliento, cambiar de tank|

### Estructura de una mazmorra

1. Entrada con grupo de mobs de calentamiento.
2. Pasillo con mobs y una trampa o mecánica del entorno.
3. Jefe 1: enseña la mecánica básica de la mazmorra.
4. Zona intermedia con un evento corto (puzzle, defender un punto, escapar).
5. Jefe 2: combina dos mecánicas.
6. Sala final con atajo de regreso.
7. Jefe final: 2 o 3 fases, cada una cambia el combate.

### Reglas

- **Normal:** se escala para 1 a 4 jugadores; se puede jugar solo y no exige roles.
- **Difícil:** requiere grupo de 4 con al menos un tank y un sanador recomendados, y un Poder de equipo mínimo. Los jefes tienen una mecánica extra.
- **Buscador de grupo:** cola por rol (tank, sanador, daño). Bono de oro y una bolsa extra para tanks y sanadores cuando faltan en la cola.
- **Muerte:** el jugador reaparece en el último punto de control; si muere todo el grupo, el jefe se reinicia pero los jefes ya derrotados quedan así.
- **Abandono:** salir de una mazmorra del buscador antes de terminar da 15 minutos de espera para volver a la cola.
- **Loot personal:** cada jugador recibe su propio cofre; nadie pelea por el botín.

### Recompensas

|   |   |   |   |
|---|---|---|---|
|Recompensa|Normal|Difícil|Sellos de Eternia|
|XP|Base|×1.5|No aplica (nivel 50)|
|Oro|Base|×2|Según nivel del sello|
|Equipo|Común y Raro, a veces Épico|Raro y Épico, a veces Legendario|Épico y Legendario, poder según el nivel del sello|
|Materiales del herrero|Básicos|Avanzados|Raros|
|Insignias|10|20|30 a 60|
|Apariencia de la mazmorra|Set base|Set con otro color|Set brillante de temporada|
|Montura del jefe final|No|1% por muerte|2% en sello +10 o más|
|Título|No|"Vencedor de" + mazmorra|"Maestro de Sellos"|

- **Primera victoria del día** en cada mazmorra: XP y oro doble.
- **Insignias:** moneda para comprar la pieza exacta que se busca al vendedor de la ciudad, para que la mala suerte no frustre.

### Sellos de Eternia (endgame, nivel 50)

- Llaves de nivel +2 a +20 que se usan en cualquiera de las 5 mazmorras en versión nivel 50.
- Cada nivel sube la vida y el daño de los enemigos un 8%.
- Hay tiempo límite: terminar a tiempo sube la llave 1 a 3 niveles; fallar la baja 1 nivel.
- **Afijos:** desde +4 uno, desde +7 dos y desde +10 tres; rotan cada semana (por ejemplo, enemigos que explotan al morir, enemigos que se curan entre sí, charcos de fuego).
- **Cofre semanal:** guarda el mejor sello de la semana y deja elegir 1 ítem entre 3.
- **Ranking:** mejores tiempos por mazmorra en el Salón de la fama, y reinicio por temporada.

## Clases y especializaciones

Las 6 clases están desde el lanzamiento y cada una elige 1 de 3 especializaciones en el nivel 10. Hay 2 clases que pueden ser tank, 2 que pueden sanar y todas pueden hacer daño.

### Clases

|   |   |   |   |   |   |
|---|---|---|---|---|---|
|Clase|Recurso|Roles posibles|Armas|Armadura|Ataque básico|
|Warrior|Energía|Tank, daño|Espadas, hachas, escudo|Placas|Combo de 3 golpes cuerpo a cuerpo|
|Paladín|Energía|Tank, sanador, daño|Mazas, martillos, escudo|Placas|Golpe con maza que carga Luz|
|Ranger|Energía|Daño|Arcos, ballestas|Cuero|Disparo rápido a distancia|
|Mage|Maná|Daño|Bastones, varitas|Tela|Proyectil mágico|
|Sacerdote|Maná|Sanador, daño|Bastones, orbes|Tela|Rayo de luz|
|Brujo|Maná|Daño, soporte|Varitas, grimorios|Tela|Descarga de sombra|

La Energía se regenera rápido y se gasta en golpes; el Maná es una reserva más grande que se recupera despacio y con pociones. Solo hay estos 2 recursos para que todo sea fácil de entender.

### Las 18 especializaciones

|   |   |   |   |   |   |
|---|---|---|---|---|---|
|Clase|Especialización|Rol|Estilo|3 habilidades clave|Definitiva (nivel 50)|
|Warrior|Armas|Daño|Golpes lentos y muy fuertes|Golpe mortal, Torbellino, Carga|Avatar de guerra: más tamaño y daño 10 s|
|Warrior|Furia|Daño|Dos armas, velocidad y frenesí|Sed de sangre, Furia ciega, Salto heroico|Masacre: sin cooldowns 6 s|
|Warrior|Guardián|Tank|Escudo, amenaza y bloqueo|Golpe de escudo, Provocar, Muro de escudo|Bastión: el grupo recibe 30% menos daño|
|Paladín|Protección|Tank|Auras y algo de curación propia|Escudo sagrado, Consagración, Juicio|Defensor divino: inmune 4 s y provoca a todos|
|Paladín|Sagrado|Sanador|Sanador cuerpo a cuerpo|Luz sagrada, Imposición de manos, Faro de luz|Amanecer: cura al grupo un 50%|
|Paladín|Castigo|Daño|Melee con daño sagrado|Veredicto, Tormenta divina, Martillo de ira|Ira vengadora: alas, más daño y curación propia|
|Ranger|Tirador|Daño|A distancia, mucho crítico|Disparo apuntado, Ráfaga, Retirada|Lluvia de flechas masiva|
|Ranger|Bestias|Daño|Mascota que pelea a su lado|Llamar bestia, Furia salvaje, Orden de ataque|Estampida: 6 bestias cargan|
|Ranger|Trampero|Daño y control|Trampas, venenos, control|Trampa de hielo, Bomba de veneno, Red|Campo minado|
|Mage|Fuego|Daño|Daño en área y quemaduras|Bola de fuego, Lluvia de meteoros, Muro de llamas|Fénix: revive una vez por combate|
|Mage|Escarcha|Daño|Daño constante que ralentiza y congela|Lanza de hielo, Nova helada, Ventisca|Era glacial: congela a todos 3 s|
|Mage|Arcano|Daño|Daño muy alto que crece mientras más maná gastas|Explosión arcana, Misiles arcanos, Poder arcano|Singularidad: atrae y daña a todos|
|Sacerdote|Luz|Sanador|Curación directa y en área|Curación, Círculo de sanación, Renovar|Himno divino: curación masiva|
|Sacerdote|Disciplina|Sanador|Escudos y curar haciendo daño|Escudo de luz, Expiación, Castigo|Barrera: el grupo recibe 40% menos daño|
|Sacerdote|Sombra|Daño|Daño en el tiempo y robo de vida|Dolor sombrío, Tortura mental, Forma de sombra|Vacío: daño enorme y cura al grupo|
|Brujo|Maldiciones|Daño y soporte|Debilita a los jefes, daño en el tiempo|Corrupción, Maldición de debilidad, Drenar vida|Plaga: las maldiciones saltan entre enemigos|
|Brujo|Invocación|Daño|Ejército de demonios|Invocar diablillo, Invocar guardián, Ofrenda|Demonio colosal 15 s|
|Brujo|Caos|Daño|Daño explosivo con fuego oscuro|Descarga del caos, Lluvia de fuego, Inmolar|Cataclismo: gran explosión en área|

### Reglas de especialización

- Se elige en el nivel 10 con una misión corta del entrenador de clase.
- Se puede cambiar gratis en la ciudad, fuera de combate y fuera de mazmorras.
- El equipo sirve para todas las especializaciones de la clase; no hay que farmear otro set.
- **Amenaza (aggro):** los tanks generan 3 veces más amenaza; los jefes atacan a quien tenga más amenaza, salvo en mecánicas especiales.

## Niveles y habilidades

El nivel máximo es 50 y llegar toma unas 30 horas de juego. Cada especialización tiene 6 habilidades activas, 4 pasivas y una definitiva, y desde el nivel 10 cada nivel da 1 punto para subirlas.

### Curva de XP

XP para pasar del nivel n al siguiente = 100 × n^1.8, redondeado. Las mazmorras y los encargos dan la mayor parte; matar mobs sueltos da poco para que no convenga solo farmear.

|   |   |   |   |
|---|---|---|---|
|Banda|Zona|Tiempo aproximado|De dónde sale la XP|
|1–10|Bosque Sombrío|2 horas|Tutorial, encargos, historia, primera mazmorra|
|10–20|Arenas Rojas|4 horas|Encargos, mazmorra, eventos|
|20–30|Picos Helados|6 horas|Mazmorra, encargos, PvP (desde el 20)|
|30–40|Pantano Maldito|8 horas|Mazmorra, eventos, PvP|
|40–50|Volcán Infernal|10 horas|Mazmorra, PvP, eventos|

### Desbloqueo de habilidades

|   |   |
|---|---|
|Nivel|Qué se desbloquea|
|1|Ataque básico, esquivar, habilidad de clase 1|
|3|Habilidad de clase 2|
|6|Habilidad de clase 3|
|10|Especialización y su habilidad 1, primer punto|
|15|Pasiva 1|
|20|Habilidad de especialización 2|
|25|Pasiva 2|
|30|Habilidad de especialización 3|
|35|Pasiva 3|
|40|Pasiva 4|
|50|Definitiva|

### Puntos

- **Puntos totales:** 41 (1 por nivel del 10 al 50).
- **Activas:** empiezan en rango 1 al desbloquearse y suben hasta el 5; cada rango sube el daño o la curación un 10% y en el rango 5 añade un efecto (por ejemplo, Bola de fuego deja el suelo ardiendo).
- **Pasivas:** rango 0 a 5; se desbloquean en rango 0 y cada rango cuesta 1 punto.
- **Definitiva:** rango 1 a 3.
- **Costo de subir todo:** 46 puntos (24 en activas, 20 en pasivas y 2 en la definitiva), así que siempre hay que elegir qué dejar sin maximizar.
- **Reiniciar puntos:** gratis en la ciudad.

### Cómo funcionan las habilidades

Hay 3 tipos de habilidad, además del ataque básico:

|   |   |   |   |
|---|---|---|---|
|Tipo|Cómo se usa|Cuántas tiene cada especialización|Reglas|
|Activa|Se aprieta un botón. Gasta Energía o Maná y después tiene un tiempo de espera (cooldown).|6: 3 de clase y 3 de especialización|Entre una activa y otra hay 0,5 s de espera para que no se lancen todas a la vez.|
|Pasiva|No se aprieta. Siempre está encendida y cambia cómo funcionan las activas.|4|Se ven en la pantalla de habilidades, no ocupan botón en la barra.|
|Definitiva|Se aprieta cuando su barra está llena.|1|La barra se llena al hacer daño, curar o recibir golpes. Contra un jefe se llena 1 o 2 veces por pelea.|

El ataque básico no gasta recurso ni tiene espera: con Energía la genera y con Maná recupera un poco. Las 3 habilidades de clase son las mismas para las 3 especializaciones; lo que cambia de una rama a otra son las otras 3 activas, las 4 pasivas y la definitiva.

#### Hechizos con carga

Casi todo es instantáneo, porque el combate pide moverse y esquivar las zonas rojas, y en móvil quedarse quieto se siente lento. Algunos hechizos grandes llevan una carga corta para darles peso y un riesgo a cambio de más daño o curación.

- **Carga:** de 0,5 a 1,5 s. El hechizo sale solo al terminar, hacia el objetivo fijado.
- **Canalizado:** el efecto ocurre mientras dura (de 1,5 a 3 s). Se puede cortar antes y se pierde lo que faltaba.
- **Moverse:** mientras se carga o se canaliza, el personaje se mueve al 50% de su velocidad.
- **Esquivar cancela.** Una carga cancelada no gasta recurso ni empieza la espera. Un canalizado se cobra al empezar, así que cortarlo pierde lo que faltaba.
- **El objetivo cuenta:** si el objetivo fijado muere o se sale de alcance durante la carga, se cancela sin gastar nada.
- **Recibir daño no interrumpe.** Interrumpir queda solo para mecánicas especiales de jefes, que avisan antes.
- **Pagan el riesgo:** pegan o curan bastante más que una instantánea del mismo costo. El número exacto se ajusta en la Fase 2 con el muñeco.
- **Se ve:** barra de carga sobre el personaje y sobre el botón, y un brillo que los demás también ven (en PvP se puede anticipar).
- **Nunca llevan carga:** el ataque básico, las 3 habilidades de clase (así los niveles 1 a 9 son simples), los desplazamientos, las defensivas, las de tank y las definitivas.

|   |   |   |
|---|---|---|
|Clase|Especialización|Hechizos con carga|
|Warrior|Todas|Ninguno|
|Paladín|Sagrado|Luz sagrada (carga 1 s): la curación grande a un aliado|
|Paladín|Protección y Castigo|Ninguno|
|Ranger|Tirador|Disparo apuntado (carga 1 s)|
|Ranger|Bestias|Llamar bestia (carga 1,5 s)|
|Ranger|Trampero|Ninguno|
|Mage|Fuego|Bola de fuego (carga 1 s)|
|Mage|Escarcha|Ventisca (canalizado 3 s)|
|Mage|Arcano|Explosión arcana (carga 0,75 s) y Misiles arcanos (canalizado 1,5 s)|
|Sacerdote|Luz|Círculo de sanación (carga 1 s)|
|Sacerdote|Disciplina|Ninguno: es el sanador que cura mientras se mueve|
|Sacerdote|Sombra|Tortura mental (canalizado 2 s)|
|Brujo|Maldiciones|Ninguno: aplica daño en el tiempo y sigue moviéndose|
|Brujo|Invocación|Invocar diablillo e Invocar guardián (carga 1,5 s)|
|Brujo|Caos|Descarga del caos (carga 1 s)|

Así cada clase de tela tiene ramas con carga y ramas más móviles, y quien prefiera no cargar tiene una opción en el Sacerdote (Disciplina) y en el Brujo (Maldiciones).

#### Ejemplo: Mage de Fuego en nivel 50

|   |   |   |   |   |   |
|---|---|---|---|---|---|
|Nivel|Habilidad|Tipo|Qué hace|Maná|Espera|
|1|Orbe arcano|Activa de clase|Lanza un orbe que atraviesa a todos los enemigos en línea.|15|6 s|
|3|Parpadeo|Activa de clase|Teletransporte de 10 m hacia adelante.|10|12 s|
|6|Barrera de maná|Activa de clase|Escudo que absorbe daño igual al 20% de tu vida durante 6 s.|20|25 s|
|10|Bola de fuego|Activa de Fuego|Carga 1 s y lanza una bola que explota al impactar y deja al enemigo ardiendo 4 s.|20|3 s|
|15|Ignición|Pasiva|Los críticos dejan al enemigo ardiendo 4 s más.|—|—|
|20|Muro de llamas|Activa de Fuego|Muro de 8 m que quema a quien lo cruce durante 6 s.|30|15 s|
|25|Calor creciente|Pasiva|Cada Bola de fuego que acierta da +5% de crítico, hasta 5 veces. Se reinicia al hacer un crítico.|—|—|
|30|Lluvia de meteoros|Activa de Fuego|3 meteoros caen en un área después de 1 s.|40|20 s|
|35|Piel de brasas|Pasiva|Quien te golpea cuerpo a cuerpo se quema.|—|—|
|40|Pirómano|Pasiva|Los enemigos que están ardiendo reciben 10% más de tu daño.|—|—|
|50|Fénix|Definitiva|Durante 10 s te conviertes en fénix: más daño y vuelo corto. Si mueres en esos 10 s, revives con 50% de vida (una vez por combate).|Barra llena|—|

**Cómo se juega en una pelea:**

1. Pones el Muro de llamas entre tú y el grupo de enemigos.
2. Lanzas Bola de fuego una y otra vez, moviéndote despacio mientras carga y esquivando si viene un golpe (esquivar cancela la carga sin gastar maná). Cada acierto sube Calor creciente hasta que sale un crítico, y ese crítico, gracias a Ignición, deja al enemigo ardiendo más tiempo.
3. Con los enemigos juntos y ardiendo (Pirómano les suma 10% de daño), tiras la Lluvia de meteoros.
4. Mientras esperas los cooldowns, usas el ataque básico para recuperar maná.
5. Si algo se te acerca, Parpadeo para alejarte o Barrera de maná si no alcanzas a escapar.
6. Cuando la barra de definitiva se llena en el jefe, activas Fénix.

**Cómo podría repartir sus 41 puntos:**

- Bola de fuego, Lluvia de meteoros, Muro de llamas y Orbe arcano al rango 5: 16 puntos.
- Parpadeo al rango 3 y Barrera de maná al rango 2: 3 puntos.
- Las 4 pasivas al rango 5: 20 puntos.
- Fénix al rango 3: 2 puntos.
- Total: 41. Parpadeo y Barrera quedan sin maximizar. Otro jugador podría subir la Barrera y dejar el Orbe más bajo para aguantar más.

Las habilidades de clase del Warrior son Tajo (golpe amplio a todos los enemigos al frente), Grito de batalla (más daño por unos segundos y Energía al instante) y Embestida (carga hasta un enemigo y lo golpea).

Las de las otras clases (las 3 primeras, iguales para sus 3 especializaciones):

|   |   |   |   |
|---|---|---|---|
|Clase|Nivel 1|Nivel 3|Nivel 6|
|Paladín|Golpe sagrado: golpe fuerte con luz sobre el objetivo|Consagración: suelo sagrado que daña alrededor durante 6 s|Luz sanadora: cura 25% de vida a uno mismo y aliados cercanos|
|Ranger|Disparo potente: flecha tensada que hace mucho daño|Lluvia de flechas: área en el objetivo con 3 pulsos|Retirada: salto hacia atrás|
|Mage|Orbe arcano|Parpadeo|Barrera de maná (en el prototipo se prueba Bola de fuego en su lugar)|
|Sacerdote|Castigo: luz que cae sobre el objetivo|Curación: cura 30% a uno mismo y aliados cercanos|Nova sagrada: daña alrededor y cura un poco al grupo|
|Brujo|Corrupción: daño en el tiempo|Drenar vida: daño en el tiempo que cura al que lo lanza|Explosión de sombra: área en el objetivo|

Las otras 2 ramas del Mage usan las mismas 3 habilidades de clase y cambian el resto. Escarcha usa Lanza de hielo, Nova helada y Ventisca, con pasivas que hacen más daño a enemigos ralentizados o congelados. Arcano usa Explosión arcana, Misiles arcanos y Poder arcano, con pasivas de cargas arcanas: cada Explosión suma una carga que sube el daño y el costo de maná, y los Misiles las gastan.

### Controles

- **Barra:** ataque básico, esquivar, 6 habilidades y la definitiva. En móvil, botones en arco alrededor del pulgar derecho.
- **Esquivar:** un dash corto con 2 cargas que se recuperan en 4 segundos.
- **Fijar objetivo:** automático al enemigo más cercano en el centro de la pantalla, con botón para cambiar. Las habilidades que necesitan objetivo van siempre al fijado; si está fuera de alcance no se usan (no saltan a otro enemigo). Sin objetivo fijado, van al primero al frente.
- **PC y consola:** teclas 1 a 6, Q para esquivar, R para la definitiva, todo reasignable.

### Stats

Solo hay 3 stats visibles, que vienen del nivel y del equipo:

- **Daño:** sube el daño y la curación.
- **Vida:** puntos de vida.
- **Crítico:** probabilidad de hacer el doble de daño o curación (tope 50%).

El **Poder de equipo** es un número que resume todo el equipo. Sirve para saber si estás listo para una mazmorra y para el buscador de grupo. No hay reparto manual de stats.

## Equipo, loot y herrero

El personaje lleva 6 piezas de equipo en 4 rarezas, y el herrero las mejora de +1 a +10 sin riesgo de fallo. No hay durabilidad ni reparaciones.

### Piezas de equipo

|   |   |   |
|---|---|---|
|Ranura|Stat principal|Dónde sale más|
|Arma|Daño|Jefes finales|
|Casco|Vida|Jefes intermedios|
|Pechera|Vida|Jefes finales|
|Guantes|Crítico|Mobs y encargos|
|Botas|Vida y velocidad de movimiento|Mobs y encargos|
|Amuleto|Daño y crítico|Élites raros y Sellos|

### Rarezas

|   |   |   |   |   |
|---|---|---|---|---|
|Rareza|Color|Stats|Tope de mejora|De dónde sale|
|Común|Gris|Base|+4|Mobs, encargos|
|Raro|Azul|+20%|+6|Mobs, élites, mazmorra normal|
|Épico|Morado|+45%|+8|Mazmorra normal y difícil, Sellos|
|Legendario|Naranja|+75% y un efecto único|+10|Mazmorra difícil, Sellos, eventos|

- **Nivel de ítem:** cada pieza tiene un nivel igual al de la zona donde cayó; solo se puede equipar con ese nivel o más.
- **Efectos legendarios:** cambian cómo funciona una habilidad (por ejemplo, Torbellino atrae enemigos). Hay 2 por especialización y 1 por clase, 42 en total al lanzamiento.
- **Loot personal:** cada jugador ve y recoge solo su botín. El loot cae para tu clase el 80% de las veces.
- **Inventario:** 40 espacios; banco personal de 60 en la ciudad. Botón de "vender todo lo gris" y de "desmontar lo peor".

### Herrero

- **Mejorar:** cada +1 sube los stats de la pieza un 6%. Cuesta oro y materiales; nunca falla.
- **Transferir mejora:** al cambiar de pieza, pasa el nivel de mejora a la nueva por el 50% del oro gastado, siempre que no supere el tope de su rareza. Así nadie siente que perdió su progreso.
- **Desmontar:** convierte una pieza en materiales según su rareza.
- **Mejorar rareza:** una pieza de nivel máximo puede subir una rareza con materiales raros (Raro a Épico, Épico a Legendario sin efecto único).

|   |   |   |
|---|---|---|
|Material|Sale de|Sirve para|
|Fragmentos de hierro|Mobs, desmontar Común|+1 a +4|
|Esencia azul|Mazmorra normal, élites, desmontar Raro|+5 a +6|
|Cristal morado|Mazmorra difícil, desmontar Épico|+7 a +8, subir a Épico|
|Núcleo de Eternia|Sellos, jefes de evento, desmontar Legendario|+9 a +10, subir a Legendario|

### Apariencias (transmog)

Toda pieza recogida queda guardada en la colección de apariencias. En el vestidor de la ciudad se puede usar cualquier apariencia de la colección sobre el equipo actual, gratis.

## Economía y monedas

Hay 4 monedas y ninguna se puede intercambiar entre jugadores. No hay casa de subastas ni comercio directo, para evitar estafas y venta por dinero real.

|   |   |   |   |
|---|---|---|---|
|Moneda|Cómo se gana|En qué se gasta|Tope|
|Oro|Mobs, encargos, mazmorras, vender ítems|Herrero, pociones, monturas básicas, transferir mejoras|Sin tope|
|Insignias|Mazmorras y Sellos|Piezas exactas en el vendedor de mazmorras|2.000|
|Honor|Partidas de PvP|Apariencias, armas cosméticas y emotes de PvP|5.000; ganancia diaria con tope|
|Cristales|Robux, pase de temporada, algunos logros|Solo cosméticos de la tienda|Sin tope|

### Sumideros de oro

El oro necesita salidas para que no pierda valor:

- Mejoras y transferencias en el herrero (el mayor gasto).
- Monturas que se compran con oro.
- Pociones y comida con buffs de 30 minutos.
- Cambiar el nombre o el color de la guild.
- Reiniciar la llave de Sellos.

### Reglas

- **Nada se intercambia** entre jugadores: ni oro, ni ítems, ni monedas.
- **Ligado a la cuenta:** todo el equipo y los cosméticos quedan en la cuenta; si en el futuro hay varios personajes, se comparten cosméticos y monturas.
- **Regalos:** solo se pueden regalar cosméticos con el sistema de regalos de Roblox.
- **Balance:** el oro por hora se mide en la analítica y se ajusta para que una mejora +10 de una pieza tome unas 6 a 8 horas de juego en total.

## PvP

El PvP tiene 2 modos al lanzamiento: Captura del Estandarte 4v4 desde el nivel 20 y Arena 2v2 o 3v3 clasificatoria en el nivel 50. En PvP el poder está igualado, así que gana la habilidad, no el equipo.

### Modos

|   |   |   |   |   |   |
|---|---|---|---|---|---|
|Modo|Jugadores|Desde nivel|Duración|Cómo se gana|Mapas al lanzamiento|
|Captura del Estandarte|4v4|20|8 minutos máximo|3 capturas, o más capturas al acabar el tiempo|Ruinas del Valle, Puente de Lava|
|Arena|2v2 y 3v3|50|3 a 5 minutos|Eliminar al equipo rival|Coliseo de Arena, Templo de Hielo|

### Reglas de Captura del Estandarte

- Cada equipo tiene un estandarte en su base; hay que robar el del rival y llevarlo a la propia base mientras el tuyo está en su sitio.
- Quien lleva el estandarte se mueve un 20% más lento, no puede usar dash ni monturas y se ve en el mapa.
- Si muere, el estandarte cae al suelo: un aliado lo devuelve tocándolo y un enemigo lo recoge.
- Reaparición en la base en 8 segundos.
- Si nadie captura en 4 minutos, los portadores reciben un 10% más de daño cada 30 segundos para evitar empates eternos.
- En empate al acabar el tiempo gana quien tenga el estandarte rival más cerca de su base.

### Poder igualado

- Todos pelean como nivel 50 con un equipo estándar de PvP; el equipo propio solo cuenta para la apariencia.
- Las habilidades se desbloquean según la especialización elegida, aunque el jugador tenga nivel 20.
- El daño se multiplica por 0.6 y la curación por 0.7 para que las peleas duren más.
- Rendimientos decrecientes: aturdir o congelar al mismo jugador 3 veces en 15 segundos lo deja inmune 10 segundos.

### Emparejamiento

- MMR oculto por modo; los grupos se emparejan con grupos de tamaño parecido.
- Si la cola tarda más de 90 segundos, se amplía el rango de MMR.
- Los equipos tienen colores, Sol (dorado) y Luna (plateado), sin facciones permanentes.

### Recompensas

|   |   |
|---|---|
|Recompensa|Cómo se gana|
|XP|Niveles 20 a 49: una partida da la XP de unos 10 minutos de zona|
|Honor|Cada partida (más si ganas), con tope diario. Compra el set de apariencia PvP, armas cosméticas y emotes|
|Divisiones de Arena|Bronce, Plata, Oro y Diamante, con título y marco de retrato por temporada|
|Top 100 de temporada|Montura exclusiva de esa temporada|
|Logros|"100 estandartes capturados" y similares, con títulos|

El PvP no da oro ni equipo de poder, para que no se use como granja.

### Conducta

- Detección de inactividad: 60 segundos sin moverse expulsa al jugador y le da 15 minutos de espera.
- Abandonar una partida cuenta como derrota y da 15 minutos de espera.
- Botón de reportar en la pantalla final.

## Social y grupos

El lanzamiento trae grupos de hasta 4, amigos de Roblox, buscador de grupo y comunicación rápida. Las guilds quedan para una actualización posterior.

|   |   |
|---|---|
|Función|Qué hace|
|Grupo|Hasta 4 jugadores; XP compartida en zonas, el líder elige mazmorra y dificultad|
|Invitar y unirse|Invitar desde la lista de amigos de Roblox o tocando a un jugador; unirse al servidor de un amigo|
|Buscador de grupo|Cola por rol para mazmorras y PvP, con bono para roles que faltan|
|Chat|TextChatService con filtro de Roblox, canales de servidor y de grupo|
|Chat rápido|Frases fijas ("¡Vamos!", "Necesito curación", "Esperen") para móvil y para cuentas sin chat|
|Pings|Marcar enemigo, lugar o peligro con un toque; se ve en el mundo y en el minimapa|
|Emotes|6 básicos gratis y más en la tienda o por logros|
|Inspeccionar|Ver la clase, especialización, equipo y logros de otro jugador|
|Salón de la fama|Rankings de Sellos, PvP, logros y colecciones|

### Reglas de grupo

- XP y loot en zona: cada jugador recibe XP completa si está cerca; el loot es personal.
- Diferencia de nivel: si un jugador tiene 10 niveles más, recibe XP mínima y los enemigos no se escalan a él.
- Expulsar del grupo en mazmorras requiere voto de 3 de 4 jugadores.

## Monturas, mascotas y cosméticos

Todas las monturas van a la misma velocidad: la diferencia es solo de apariencia. Se usan en la ciudad y en las zonas fuera de combate, pero no en mazmorras ni en PvP.

### Monturas

- **Primera montura:** en el nivel 10, se compra con oro al establero; da +60% de velocidad.
- **Al recibir daño** el jugador se baja de la montura; subir toma 1 segundo.
- **Monturas voladoras:** no están al lanzamiento; se pueden evaluar en una expansión.

|   |   |   |
|---|---|---|
|Fuente|Ejemplo de montura|Cómo se consigue|
|Establero (oro)|Caballo, lobo, carnero|Comprar con oro desde nivel 10; varios colores|
|Jefe final en difícil|Lobo de Raíz Negra, Escarabajo Dorado, Oso de Escarcha, Araña Espectral, Cría de Dragón|1% por muerte|
|Sellos de Eternia|Montura de temporada|Completar un sello +10 a tiempo en la temporada|
|PvP|Grifo de Guerra de temporada|Top 100 de Arena en la temporada|
|Logros|Caballo de Eternia|Completar las 5 mazmorras en difícil|
|Eventos|Calabaza con patas, reno, etc.|Evento de temporada|
|Tienda|Monturas brillantes o fantásticas|Cristales; misma velocidad que las demás|

### Mascotas

- Cosméticas: siguen al jugador, tienen animaciones y no pelean ni dan stats.
- Salen de cofres escondidos, eventos, logros y la tienda.
- Una activa a la vez; se pueden ponerles nombre (filtrado).

### Otros cosméticos

|   |   |   |
|---|---|---|
|Tipo|Ejemplo|Fuente|
|Apariencias de armadura|Set de cada mazmorra, set PvP|Mazmorras, Honor, tienda|
|Efectos de habilidad|Bola de fuego azul|Logros, tienda, pase|
|Auras|Brillo alrededor del personaje|Sellos, PvP, pase|
|Títulos|"Matadragones"|Logros, Sellos, PvP|
|Marcos de retrato|Marco Diamante|PvP, Sellos|
|Emotes|Baile, saludo|Tienda, logros|

### Colecciones

Una pestaña muestra todas las monturas, mascotas, apariencias y títulos, con los que faltan en gris y de dónde salen. Hay logros por cantidad (10, 25 y 50 monturas).

## Eventos, temporadas y retención

El juego se renueva en temporadas de 8 semanas, cada una con un modificador de Sellos, una temporada de PvP, un pase cosmético y un evento con portal propio en la ciudad.

### Qué trae cada temporada

- **Afijo de temporada** para los Sellos y reinicio del ranking.
- **Temporada de PvP** con reinicio suave del MMR y recompensas nuevas.
- **Pase de temporada** con pista gratis y pista de pago (solo cosméticos).
- **Evento de 2 semanas** con portal temporal, jefe de evento y tienda de evento.
- **Contenido nuevo** según la temporada: una especialización rebalanceada, un mapa de PvP o una subárea nueva.

### Eventos fijos del año

|   |   |   |   |
|---|---|---|---|
|Evento|Época|Portal y contenido|Recompensa estrella|
|Noche de las Calabazas|Octubre|Zona embrujada y jefe Jinete sin Cabeza|Montura calabaza|
|Invierno en Eternia|Diciembre|Pueblo nevado y jefe Rey de Hielo Navideño|Montura reno|
|Festival del Sol|Junio a julio|Juegos y carreras en la ciudad|Mascota sol|
|Aniversario|Fecha de lanzamiento|Jefe de aniversario con todos los jefes anteriores|Título y aura de aniversario|

### Retención diaria y semanal

|   |   |
|---|---|
|Sistema|Cómo funciona|
|Recompensa por entrar|Calendario de 7 días que se repite; el día 7 da un cofre mejor. No se pierde la racha por faltar un día, solo se pausa|
|Misiones diarias|3 al día (por ejemplo, "mata 30 enemigos", "termina una mazmorra"); dan oro, XP y puntos del pase|
|Misiones semanales|3 a la semana, más largas, con más puntos del pase|
|Primera victoria del día|Bono doble en cada mazmorra y en PvP|
|Cofre semanal|Desde el nivel 50, elige 1 ítem entre 3 según el mejor sello y el PvP de la semana|
|Logros|Cientos, con puntos, títulos, monturas y marcos|

### Notificaciones

Usar las notificaciones de experiencia de Roblox solo para eventos y cosas que el jugador pidió (por ejemplo, "tu evento empieza en 10 minutos"), con un máximo de 2 por semana.

## Monetización

Todo lo que se vende es cosmético o de comodidad; nunca stats, equipo, materiales del herrero ni XP. Los precios en Robux son una referencia inicial y se ajustan con datos.

|   |   |   |   |
|---|---|---|---|
|Producto|Tipo en Roblox|Precio de referencia|Qué da|
|Paquetes de Cristales|Developer product|80 a 1.700 Robux|Moneda para la tienda cosmética|
|Pase de temporada|Developer product por temporada|400 Robux|Pista de pago: apariencias, montura, aura, emotes, Cristales de vuelta|
|Inventario +40|Gamepass|150 Robux|Más espacio en la mochila|
|Banco +60|Gamepass|150 Robux|Más espacio en el banco|
|Paquete de bienvenida|Developer product, una vez por cuenta|200 Robux|Montura, mascota y apariencia de inicio|
|Servidores privados|Función de Roblox|100 Robux al mes|Jugar con amigos en un servidor propio|

### Tienda cosmética

- Rotación semanal de 6 a 8 ítems: monturas, mascotas, apariencias, efectos de habilidad, auras y emotes.
- Se puede ver cómo luce cada ítem en tu personaje antes de comprar.
- Sin cajas de botín de pago: todo lo que se compra se ve antes de pagar.

### Reglas

- Sin anuncios de "oferta que acaba en 5 minutos" ni presión a menores.
- Confirmación doble en compras de más de 500 Robux.
- Cumplir las políticas de Roblox sobre monetización, publicidad y probabilidades.

## Arte, estilo visual y audio

El estilo es fantasía estilizada y low-poly, con colores saturados y siluetas claras, porque se ve bien en móvil y corre en equipos modestos. Antes de producir assets hay que cerrar una guía visual de una página: [GUIA-VISUAL.md](GUIA-VISUAL.md) (borrador).

### Guía visual

Las reglas de estilo (geometría, materiales, luz, colores reservados de combate, siluetas de clase, niveles de enemigos, animación, efectos e interfaz) están en [GUIA-VISUAL.md](GUIA-VISUAL.md). Las medidas para Roblox, los presupuestos orientativos, las fichas de los 3 conceptos de prueba y la checklist de aprobación están en [GUIA-VISUAL-TECNICA.md](GUIA-VISUAL-TECNICA.md).

### Ambiente por zona

|   |   |   |   |
|---|---|---|---|
|Zona|Paleta|Luz y clima|Música|
|Ciudadela de Eternia|Blanco, dorado, azul|Día soleado, banderas, fuentes|Tema épico tranquilo|
|Bosque Sombrío|Verde oscuro, morado|Niebla baja, rayos de luz, luciérnagas de noche|Flautas y cuerdas misteriosas|
|Arenas Rojas|Rojo, ocre, turquesa en oasis|Sol fuerte, calima, tormentas de arena|Percusión y escalas árabes|
|Picos Helados|Blanco, azul hielo, aurora verde|Nevada, viento, aurora de noche|Coros y campanas|
|Pantano Maldito|Verde tóxico, gris, rojo de luna|Niebla densa, luna roja, lluvia|Tonos graves e inquietantes|
|Volcán Infernal|Negro, naranja, rojo|Ceniza cayendo, brillo de lava|Tambores y metales intensos|

### Presupuestos de rendimiento

- Meta: 60 FPS en PC y 30 FPS estables en un teléfono de gama media.
- Presupuestos por asset y por escena (triángulos, texturas, partículas, luces, draw calls): orientativos y pendientes de medir en los dispositivos de prueba, en [GUIA-VISUAL-TECNICA.md](GUIA-VISUAL-TECNICA.md#presupuestos-orientativos). Referencias iniciales: mobs con menos de 3.000 triángulos y jefes con menos de 15.000.
- Zonas: StreamingEnabled y LOD para que solo cargue lo cercano.

### Audio

- Música propia por zona, mazmorra y jefe; capa de combate que entra al pelear.
- Efectos de sonido de impacto claros por clase (metal, flechas, magia).
- Aviso sonoro antes de cada ataque fuerte de jefe.
- Volumen separado de música, efectos, ambiente y voces en ajustes (un SoundGroup por cada uno).
- Solo audio con licencia comercial o hecho por el equipo.

**De dónde sale cada sonido**

Regla: lo que identifica a Eternia y el jugador recuerda se genera con **ElevenLabs**; lo que solo tiene que estar ahí y nadie nota sale de **Roblox genérico** (Creator Store, solo catálogos con licencia como ProSoundEffects y APM Music).

|   |   |   |
|---|---|---|
|Categoría|Ejemplos|Fuente|
|Clases|Ataques básicos, habilidades, definitivas, esquivar, recibir golpe, morir|ElevenLabs|
|Voces|Gritos, esfuerzos y quejidos sin palabras (sirven en todos los idiomas)|ElevenLabs|
|Impactos|Por material (metal, carne, madera, piedra, magia) y crítico|ElevenLabs|
|Mobs|Detectar al jugador, atacar, recibir golpe, morir|ElevenLabs|
|Jefes|Aviso de ataque fuerte, ataques, cambio de fase, rugido, muerte|ElevenLabs|
|Ambiente|Fondo continuo de cada zona y de la Ciudadela|Roblox genérico; detalles propios de cada zona (criaturas, lava, viento helado) con ElevenLabs|
|Interfaz|Clics, abrir y cerrar paneles, error|Roblox genérico|
|Momentos clave|Subir de nivel, loot por rareza, mejora en el herrero, desbloquear portal, logros|ElevenLabs|
|Movimiento|Pasos por superficie, saltar, caer|Roblox genérico|
|Monturas, mascotas, eventos y PvP|Sonidos de cada montura y mascota, estandarte capturado, cuenta atrás, victoria|ElevenLabs|
|Música|Zonas, mazmorras, jefes, capa de combate|APM Music para prototipo y beta; la final es decisión pendiente (ElevenLabs Music o compositor)|

El fondo continuo de las zonas queda en Roblox genérico porque un ambiente largo que se repite sin cortes sale mejor de una librería profesional que generado.

**Catálogo:** cada sonido del juego tiene una fila en [AUDIO.md](AUDIO.md) con dónde suena, su fuente, el texto usado en ElevenLabs y su ID en Roblox. Así se puede regenerar o hacer variantes con el mismo estilo. Las fichas de zona, mob y jefe tienen una sección "Sonidos" que enlaza a su parte del catálogo.

**Cuándo se hace cada cosa**

|   |   |
|---|---|
|Fase|Sonidos finales|
|1 — Núcleo técnico|Warrior y Mage completos, impactos, interfaz y momentos clave|
|2 — Clases|Las 6 clases y 18 especializaciones|
|3 en adelante|Mobs, jefes y ambiente de cada zona junto con su arte final; monturas, mascotas, eventos y PvP en su fase|

**Costo:** medido en la primera tanda (27 variantes, 22 s de audio, 117 créditos): unos **5 créditos por segundo generado**. Con 3 variantes por sonido, un sonido de combate de 1 s cuesta unos 15 créditos. Estimado del catálogo completo (unos 400 sonidos más los detalles de ambiente): entre 6.000 y 10.000 créditos, repartidos por fases.

**Reglas**

- Nunca audio subido por usuarios del Creator Store con origen desconocido: muchos son recortes de otros juegos o películas.
- Todo texto de ElevenLabs sigue la guía de estilo de [AUDIO.md](AUDIO.md) para que el juego suene coherente.
- Antes de subir, cada sonido se recorta y se normaliza en Audacity para que todos suenen parecido de fuerte.
- Se sube por tandas con Open Cloud, porque cada audio pasa por moderación y hay un límite de subidas al mes (más alto con la cuenta verificada).
- Los IDs viven solo en los datos (`Data/Feedback`): cambiar un sonido no toca código.

### Flujo de arte

1. Concept art y moodboard por zona y jefe (IA de imágenes como Higgsfield o Midjourney, retocado por un artista).
2. Guía visual aprobada: los 3 conceptos de prueba pasan juntos la checklist de [GUIA-VISUAL-TECNICA.md](GUIA-VISUAL-TECNICA.md#checklist-de-aprobación).
3. Bloqueo de la zona en Roblox Studio con piezas grises.
4. Modelado en Blender (o base generada con Meshy o Tripo y limpiada en Blender).
5. Texturas y materiales con paletas compartidas, importación a Studio y prueba en móvil dentro de los presupuestos del anexo técnico.
6. Iluminación, efectos, sonido y pulido.

### Animación, efectos y sonido de combate

Van juntos y en 3 niveles, para que cada prueba se entienda y el arte final no obligue a tocar código:

1. **Provisorio:** cada habilidad, mob o jefe entra a la caja gris con animación, efecto y sonido simples, hechos por quien programa la mecánica.
2. **Sistema (Fase 1):** todo se define por datos (IDs de animación, efecto y sonido por habilidad), con precarga, avisos de ataques enemigos y modo de gráficos bajos. Pasar al arte final es cambiar IDs.
3. **Final:** primero Warrior y Mage como referencia de calidad y de tiempo por habilidad; después el resto según la tabla de fases.

Volumen estimado: unas 250 animaciones (unas 110 de clases, 60 de mobs y 90 de jefes), además de sus efectos y sonidos.

## Idiomas y localización

Eternia sale con 2 idiomas traducidos a mano y suma más con el tiempo. Todo el texto del juego vive en las tablas de localización de Roblox, nunca escrito directo en el código, así que agregar un idioma no obliga a tocar la interfaz.

|   |   |   |
|---|---|---|
|Etapa|Idiomas|Cómo se traducen|
|Lanzamiento|Español e inglés|A mano, revisados por el equipo|
|Primera actualización|Portugués de Brasil|Traducción revisada por una persona (freelancer)|
|Después del lanzamiento|Francés, alemán, japonés, coreano, chino y otros que soporte Roblox|Traducción automática de Roblox, con los nombres importantes fijados a mano|

**Reglas desde el primer día:**

- **Texto:** ningún texto queda escrito en el código. Todo sale de las tablas de localización: menús, misiones, diálogos, nombres de objetos, tooltips y avisos.
- **Glosario:** los nombres propios del juego (clases, especializaciones, zonas, mazmorras, jefes, Sellos de Eternia, Insignias) tienen una sola traducción por idioma, para que la traducción automática no los cambie.
- **Interfaz:** los botones y paneles aguantan textos hasta un 30% más largos, porque el alemán y el portugués ocupan más que el inglés. Los íconos no llevan texto dibujado dentro de la imagen.
- **Números y tiempos:** se muestran con el formato de cada idioma, por ejemplo 1.000 frente a 1,000.
- **Página del juego:** el nombre, la descripción y los thumbnails se hacen en español, inglés y portugués.
- **Chat:** la traducción del chat de Roblox queda activada para que jugadores de distintos países se entiendan en grupo.

**Herramientas:** tablas de localización de Roblox Studio para los textos y sus traducciones, traducción automática de Roblox para los idiomas que no se traducen a mano, y una hoja de cálculo compartida (Google Sheets) para el glosario y el trabajo de los traductores antes de importar a Roblox.

**Métricas:** porcentaje de jugadores y retención por idioma. Si un idioma con traducción automática supera el 10% de los jugadores, pasa a tener traducción revisada por una persona.

## Herramientas por área

El juego se construye en Roblox Studio, con el código en Git y el arte 3D en Blender. La IA de imágenes sirve para concept art y marketing, no para los modelos finales.

|   |   |   |   |
|---|---|---|---|
|Área|Herramienta|Para qué|Costo|
|Motor|Roblox Studio|Construir mapas, probar, publicar|Gratis|
|Código|VS Code + Rojo + Luau Language Server|Escribir Luau fuera de Studio y sincronizarlo|Gratis|
|Código|Git + GitHub|Control de versiones y revisiones de código|Gratis o de pago para equipos|
|Código|Wally|Gestor de paquetes de Luau|Gratis|
|Código|Selene + StyLua|Revisar errores comunes y formatear el código|Gratis|
|Código|Jest Lua o TestEZ|Pruebas automáticas de la lógica|Gratis|
|Datos|ProfileStore (o ProfileService)|Guardar perfiles de jugador sin perder datos|Gratis|
|Mapas|Terrain Editor de Studio|Terreno de las zonas|Gratis|
|Modelos 3D|Blender|Personajes, armas, armaduras, jefes, decorados|Gratis|
|Modelos 3D|Meshy o Tripo|Generar bases 3D con IA que se limpian en Blender|De pago con plan gratis|
|Texturas|Blender, Substance Painter o Krita|Pintar texturas|Gratis o de pago|
|Animación|Animation Editor de Roblox o Moon Animator|Ataques, habilidades, emotes|Gratis o de pago|
|Concept art|Higgsfield o Midjourney|Moodboards, concept de zonas y jefes|De pago|
|Marketing|Higgsfield, CapCut|Trailers y videos cortos|De pago con plan gratis|
|UI|Figma|Diseñar pantallas e iconos antes de llevarlos a Studio|Gratis o de pago|
|Audio|ElevenLabs Sound Effects|Sonidos propios: clases, voces, impactos, mobs, jefes, momentos clave, monturas y eventos|De pago (el plan gratis no permite uso comercial)|
|Audio|Audacity, biblioteca de audio de Roblox, música con licencia|Recortar y normalizar; ambiente, interfaz y música|Gratis o de pago|
|Planificación|Notion, Trello o Linear|Tareas, documentos y tablero por fase|Gratis o de pago|
|Comunidad|Discord y grupo de Roblox|Avisos, reportes de bugs y beta testers|Gratis|
|Analítica|Analytics de Roblox Creator Hub|Retención, embudos, economía, ingresos|Gratis|
|Contratación|Talent Hub de Roblox|Buscar modeladores, animadores y músicos|Gratis|

### Reglas de trabajo

- Todo el código vive en Git; nada se edita solo dentro de Studio sin pasar por Rojo.
- Una rama por función y revisión antes de unirla a la principal.
- 3 lugares (places) separados: desarrollo, pruebas y producción.
- Antes de publicar en producción se prueba en pruebas con al menos 10 jugadores.

## Arquitectura técnica en Roblox

El juego es una experiencia con 4 places y el servidor decide todo: daño, loot, XP y monedas. El cliente solo muestra animaciones y envía intenciones.

### Places

|   |   |   |   |
|---|---|---|---|
|Place|Qué contiene|Jugadores por servidor|Cómo se entra|
|Mundo|Ciudad y las 5 zonas, con StreamingEnabled|30|Al abrir el juego|
|Mazmorra|Las 5 mazmorras en sus 2 modos y los Sellos|1 a 4|TeleportService a un ReservedServer por grupo|
|PvP|Mapas de Estandarte y Arena|4 a 8|Cola en MemoryStore y ReservedServer por partida|
|Evento|Mapa del evento de temporada|4 a 20|Portal de la plaza de eventos|

### Sistemas principales

- **Datos del jugador:** ProfileStore con bloqueo de sesión para que no se dupliquen ítems al cambiar de servidor. Guardado automático cada 60 segundos y al salir. Campo de versión para migrar datos cuando cambie el formato.
- **Contenido como datos:** clases, habilidades, ítems, mobs, jefes y recompensas viven en tablas de ModuleScripts. Agregar contenido no exige tocar la lógica.
- **Combate:** el cliente reproduce la animación al instante; el servidor valida cooldown, recurso, distancia y línea de visión, y calcula el daño.
- **Amenaza:** tabla de amenaza por enemigo en el servidor; los jefes siguen al de más amenaza salvo en mecánicas.
- **IA de enemigos:** máquina de estados simple (patrulla, persigue, ataca, vuelve) con PathfindingService solo cuando hace falta.
- **Jefes:** script por jefe con fases y mecánicas definidas en datos (vida en la que cambia de fase, ataques, tiempos).
- **Grupos entre servidores:** el grupo viaja con TeleportService y TeleportData; MessagingService avisa invitaciones entre servidores.
- **Matchmaking:** colas de MemoryStore por modo, rol y MMR; un servidor arma partidas cada pocos segundos.
- **Rankings:** OrderedDataStore para el Salón de la fama, actualizado cada pocos minutos.
- **Compras:** ProcessReceipt idempotente que guarda cada recibo para no entregar dos veces ni perder compras.

### Estructura del código

|   |   |
|---|---|
|Carpeta|Contenido|
|ServerScriptService|Servicios del servidor: datos, combate, loot, mazmorras, PvP, economía, compras|
|ReplicatedStorage/Shared|Tablas de datos, tipos, utilidades y definiciones de remotos|
|StarterPlayerScripts|Controladores del cliente: cámara, controles, UI, efectos|
|ServerStorage|Modelos de mobs, jefes y mazmorras que solo el servidor clona|

### Rendimiento de red

- Remotos con límite de llamadas por segundo por jugador.
- El daño se envía agrupado cada 0,1 segundos, no golpe por golpe.
- Mobs fuera de la vista de todos los jugadores se duermen.

## Seguridad, moderación y cuidado de menores

Como gran parte del público es menor de edad, el juego no permite comercio, filtra todo el texto y nunca confía en el cliente.

### Anti-trampas

- El servidor calcula daño, loot, XP y monedas; el cliente no puede pedir "dame 1.000 de oro".
- Validación de cada remoto: tipos, rangos, cooldowns y distancia.
- Detección de velocidad y teletransporte imposibles; el jugador se devuelve a su última posición válida y se registra.
- Alertas automáticas si un jugador gana oro, XP o ítems muy por encima de lo normal por hora.
- Baneos con la Ban API de Roblox y registro de motivo, fecha y quien lo aplicó.

### Moderación

- Todo texto escrito por jugadores (chat, nombres de mascotas) pasa por el filtro de Roblox.
- Botón de reportar jugador en el menú de cada jugador y al final de cada partida.
- Silenciar y bloquear jugadores desde su perfil.
- Clasificación de contenido de Roblox (cuestionario de madurez e IARC) al día: se repite cada vez que el juego agrega contenido que cambie las respuestas (más violencia, sangre, miedo, compras o chat propio).
- Panel de administración interno para revisar reportes, ver historial de un jugador y aplicar sanciones.

### Cuidado de menores

- Sin comercio, regalos de oro ni ítems entre jugadores.
- Violencia de fantasía sin sangre; enemigos que se desvanecen al morir.
- Sin enlaces externos ni pedidos de datos personales.
- Chat según los ajustes de edad y control parental de Roblox; el chat rápido funciona para todos.
- Responder con honestidad el cuestionario de madurez de contenido de Roblox.
- Monetización sin presión (ver Monetización).

### Respaldo de datos

- Registro de cada cambio importante del inventario (loot, mejoras, compras) para poder devolver ítems perdidos.
- Herramienta interna para restaurar el perfil de un jugador a una versión anterior.

## Analítica y métricas

Las decisiones de balance y contenido se toman con datos de la analítica de Roblox más eventos propios. Estas son las metas iniciales; se ajustan después de la beta.

|   |   |   |
|---|---|---|
|Métrica|Meta inicial|Qué dice|
|Retención día 1|30% o más|Si la primera sesión engancha|
|Retención día 7|10% o más|Si el ciclo de juego tiene profundidad|
|Retención día 30|4% o más|Si el endgame funciona|
|Duración media de sesión|20 minutos o más|Si hay suficiente que hacer por sesión|
|Jugadores que llegan al nivel 10|50% de los nuevos|Si el tutorial y la primera zona funcionan|
|Jugadores que terminan la primera mazmorra|40% de los nuevos|Si las mazmorras son claras y alcanzables|
|Conversión a pagador|2% a 4%|Si la tienda ofrece cosas deseables|

### Eventos propios a registrar

- Embudo del tutorial, paso por paso.
- Clase y especialización elegidas, y cambios de especialización.
- Tiempo por nivel y por zona.
- Intentos, muertes y abandonos por jefe y por mazmorra.
- Oro ganado y gastado por fuente, y nivel de mejora medio del equipo.
- Tasa de victoria por especialización en PvP y en Sellos.
- Tiempo de espera en colas por rol.
- Compras por producto y desde qué pantalla se abrieron.

### Cómo se usan

- Revisión semanal de un tablero con estas métricas.
- Si un jefe tiene más del 50% de abandonos, se revisa su dificultad.
- Si una especialización gana 5 puntos más que el promedio, se ajusta en la siguiente actualización.
- Pruebas A/B dividiendo a los jugadores nuevos en 2 grupos para probar tienda, tutorial y recompensas.

## Plan por fases

El lanzamiento llega en unos 12 meses, en 8 fases con un criterio de terminado cada una. El arte avanza en paralelo desde la Fase 1, y en el mes 7 hay una beta temprana con 2 zonas para tener datos y comunidad antes de terminar.

[embed: node/bc96aaf2-4cb3]

Cada fase tiene un criterio de terminado; los 3 hitos marcados deciden si se sigue adelante.

### Cómo se diseña cada cosa

El diseño no se hace todo al principio. Va siempre una fase por delante de la construcción: mientras se construye una zona, ya se está diseñando la siguiente. Así lo que se aprende jugando la primera mazmorra mejora las demás, y no se rehace trabajo.

Cada pieza del juego (zona, mazmorra, jefe, NPC, mob) pasa por los mismos 5 pasos:

1. **Ficha en papel:** qué es, qué hace y por qué es divertido, con la plantilla de su tipo.
2. **Concepto visual:** 2 o 3 imágenes de referencia (Higgsfield o un artista) para fijar el aspecto.
3. **Caja gris:** versión jugable hecha con bloques en Roblox Studio, sin arte final. El combate sí lleva feedback provisorio (animaciones, efectos y sonidos simples) para que se entienda al jugarlo.
4. **Prueba:** se prueba jugando. Si no es divertido, se vuelve al paso 1 o 3. Nada pasa al arte final sin aprobar aquí.
5. **Arte final:** modelos (Blender), texturas, efectos, sonido y música.

**Qué se diseña en cada fase**

|   |   |   |   |
|---|---|---|---|
|Fase|Ficha y concepto|Caja gris jugable|Arte final|
|0 — Prototipo|Guía visual en borrador; plantillas de fichas; jefe de prueba y 3 mobs|Subárea de prueba y jefe de prueba|Nada (solo feedback provisorio de combate)|
|1 — Núcleo técnico|Guía visual final; Ciudadela y sus NPCs; Bosque Sombrío completo y su mazmorra con 3 jefes|Ciudadela|Personaje base y armaduras iniciales; kit de piezas del Bosque; Warrior y Mage con animaciones, efectos y sonidos finales como referencia de calidad|
|2 — Clases|Aspecto de las 6 clases y efectos de sus habilidades; Arenas Rojas y su mazmorra con 3 jefes|Bosque Sombrío y mazmorra 1; zona de práctica|Ciudadela y Bosque Sombrío; animaciones, efectos y sonidos de las 6 clases y 18 especializaciones|
|3 — Mundo y mazmorras|Picos Helados, Pantano Maldito y Volcán Infernal con sus mazmorras y 9 jefes; NPCs de cada zona|Arenas Rojas y zonas 3 a 5 con sus mazmorras|Arenas Rojas y mazmorra 2 (para la beta del mes 7); música de zonas 1 y 2; animaciones, avisos y sonidos de los mobs y jefes de las zonas 1 y 2|
|4 — Progresión|Aspecto del equipo por rareza, legendarios, monturas, mascotas e iconos|—|Picos Helados y Pantano Maldito con sus mazmorras, mobs y jefes animados; objetos; monturas y mascotas animadas|
|5 — Endgame y PvP|Efectos visuales de los afijos de Sellos; mapas de Estandarte y Arena|Mapas de PvP|Volcán Infernal y mazmorra 5 con sus mobs y jefes animados; mapas de PvP; efectos de afijos y del PvP|
|6 — Social y tienda|Cosméticos de la tienda y del pase de Temporada 1; primer evento|Evento 1|Cosméticos, tienda e interfaz final; emotes y efectos cosméticos|
|7 — Pulido y lanzamiento|Temporada 2 y siguiente evento|Evento 2|Pulido general (incluye timing de animaciones y efectos, y versión de gráficos bajos), trailer, thumbnails e icono|

Regla: una pieza no entra a construcción sin su ficha aprobada, y no entra a arte final sin pasar la prueba en caja gris.

**Qué lleva cada ficha**

|   |   |
|---|---|
|Ficha|Contenido|
|Zona|Niveles, ambiente y paleta, mapa con las 3 subáreas y el camino a la mazmorra, mobs, élite, evento, encargos, NPCs, historia y música|
|Mazmorra|Mapa con salas y pasillos, duración (15 a 20 min), grupos de mobs entre jefes, atajos, recompensas y qué cambia en difícil|
|Jefe|Aspecto, fases, ataques con su aviso visual, qué rol pone a prueba (tank, sanador o daño), duración (2 a 4 min), qué cambia en difícil y recompensas|
|NPC|Dónde está, qué hace (vende, da encargos, mejora, cuenta historia), diálogos y aspecto|
|Mob|Aspecto, comportamiento, 1 o 2 ataques con su aviso, vida y daño por nivel, y qué suelta|

Las fichas viven en [fichas/](fichas/), y cada una enlaza a su concepto visual y a su versión en caja gris.

### Fase 0 — Prototipo de combate (meses 0 a 1,5)

- Warrior y Mage con 3 habilidades cada uno, ataque básico y esquivar.
- Feedback provisorio de combate: animación, efecto y sonido simples para cada ataque y habilidad, definidos por datos para cambiarlos por el arte final sin tocar código.
- Una subárea gris con 3 tipos de mobs y un jefe con 2 fases.
- Controles de PC y móvil.
- Prueba de hechizo con carga: Bola de fuego del Mage con 1 s, movimiento al 50% y cancelación al esquivar, para confirmar en PC y móvil las reglas de [Hechizos con carga](#hechizos-con-carga).
- **Terminado cuando:** al probarlo en PC y en móvil, el combate se entiende sin explicación y dan ganas de seguir jugando.

### Fase 1 — Núcleo técnico (mes 1,5 a 3)

- Repositorio con Rojo, Git, Wally, Selene y StyLua; places de desarrollo, pruebas y producción.
- ProfileStore, inventario, loot personal, XP y niveles.
- Combate validado en servidor, amenaza, IA de mobs y sistema de jefes por datos.
- UI base: vida, recurso, barra de habilidades, inventario.
- Sistema de localización listo: todo el texto en tablas, en español e inglés, y glosario de nombres iniciado.
- Sistema de feedback de combate por datos: animaciones, efectos y sonidos con precarga, avisos de ataques enemigos (zona roja en el suelo y sonido) y modo de gráficos bajos.
- Sonidos finales de Warrior y Mage, impactos, interfaz y momentos clave (ver [AUDIO.md](AUDIO.md)).
- Guía visual aprobada.
- **Terminado cuando:** 30 jugadores juegan 1 hora sin errores de datos ni lag notable.

### Fase 2 — Clases (mes 3 a 4,5)

- Las 6 clases y 18 especializaciones con sus habilidades, pasivas y definitivas.
- Árbol de puntos, cambio de especialización y zona de práctica.
- **Terminado cuando:** cada especialización mata al muñeco de práctica en un tiempo dentro del 10% del promedio de su rol, y el tank y el sanador cumplen su rol en una prueba de jefe.

### Fase 3 — Mundo y mazmorras (mes 4,5 a 7)

- Ciudadela, tutorial, 5 zonas con encargos, historia, élites, eventos y cofres.
- 5 mazmorras con 15 jefes, modo normal y difícil.
- Buscador de grupo.
- **Hito: beta temprana** con la ciudad y las 2 primeras zonas (niveles 1 a 20) abierta a la comunidad de Discord.
- **Terminado cuando:** se puede llegar del nivel 1 al 50 y matar a los 15 jefes.

### Fase 4 — Progresión y economía (mes 7 a 8)

- Rarezas, efectos legendarios, herrero completo, materiales.
- Monedas, vendedores, monturas, mascotas, apariencias y colecciones.
- **Terminado cuando:** la analítica de la beta muestra que el oro ganado y gastado se equilibran.

### Fase 5 — Endgame y PvP (mes 8 a 9,5)

- Sellos de Eternia con afijos, cofre semanal y rankings.
- Captura del Estandarte, Arena, matchmaking, poder igualado y Honor.
- **Terminado cuando:** un grupo puede hacer un sello +10 y las colas de PvP se llenan en menos de 90 segundos con 200 jugadores conectados.

### Fase 6 — Social, tienda y operación (mes 9,5 a 10,5)

- Grupo, chat rápido, pings, emotes, Salón de la fama.
- Tienda cosmética, pase de temporada, gamepasses y paquete de bienvenida.
- Analítica completa, panel de moderación, baneos y restauración de perfiles.
- Misiones diarias, semanales, recompensa por entrar y logros.
- **Terminado cuando:** cada compra se entrega bien en 100 compras de prueba y todos los eventos de analítica aparecen en el tablero.

### Fase 7 — Pulido, beta abierta y lanzamiento (mes 10,5 a 12)

- Optimización para móvil, corrección de errores y balance final.
- Beta abierta de 2 a 3 semanas.
- Trailer, thumbnails, icono y videos cortos.
- Español e inglés completos y revisados; página del juego y thumbnails en español, inglés y portugués.
- Lanzamiento con la Temporada 1.
- **Terminado cuando:** se cumplen las metas de rendimiento, no hay errores graves abiertos y la retención día 1 de la beta es de 25% o más.

### Después del lanzamiento

- Temporadas cada 8 semanas y eventos fijos del año.
- Parches de balance cada 2 semanas.
- Primera actualización: portugués de Brasil revisado y traducción automática de Roblox activada para el resto de idiomas.
- Actualizaciones grandes según los datos: guilds, raid, nuevos modos de PvP, expansión con zona 6 y subida de nivel.

## Lo que se quitó y lo que queda para después

Se quitaron los sistemas de WoW que no alimentan el ciclo de pelear, sacar loot y mejorar. Algunos vuelven más adelante si los datos muestran que el juego los necesita.

|   |   |   |
|---|---|---|
|Sistema|Decisión|Por qué|
|Mundo abierto continuo|Quitado: ciudad con portales|Mucho más trabajo, peor en móvil, y los portales dan la misma sensación|
|Profesiones (minería, alquimia, etc.)|Quitado|El herrero cubre la mejora de equipo; recolectar se siente como tarea|
|Casa de subastas y comercio|Quitado|Estafas, venta por dinero real y riesgo con menores|
|Recursos de clase distintos (Ira, Fe, almas)|Simplificado a Energía y Maná|Más fácil de entender para jugadores de 10 años|
|Stats secundarios (Celeridad, Maestría)|Simplificado a Daño, Vida y Crítico|Menos números que leer|
|Herrero con fallos, gemas, encantamientos y reforja|Simplificado a mejoras +1 a +10 sin fallo|Sin frustración por mala suerte|
|Monturas voladoras y de varias velocidades|Simplificado a una velocidad, cosméticas|Las zonas son pequeñas|
|Facciones permanentes en PvP|Quitado: colores de equipo|Dividían a los amigos|
|Reputaciones, XP descansada, builds guardadas, sets de 2 y 4 piezas|Quitado|Complejidad sin mucho beneficio en Roblox|

### Para después del lanzamiento, si el juego crece

|   |   |
|---|---|
|Función|Cuándo considerarla|
|Guilds con banco y misiones|Cuando muchos jugadores jueguen en grupos fijos|
|Raid de 8 jugadores|Cuando haya suficientes jugadores en el nivel 50 para llenarla|
|Casa personal decorable|Como gran actualización social de retención|
|Más modos de PvP (control de puntos, batalla 15v15)|Cuando las colas de PvP sean rápidas|
|Zona 6 y nivel 60|Expansión del primer aniversario|
|Clase nueva|Con una expansión|
|Varios personajes por cuenta|Cuando los jugadores pidan probar otras clases sin cambiar la suya|

## Riesgos principales

El mayor riesgo es que el combate no se sienta bien en móvil; por eso la Fase 0 no se da por terminada hasta que, al probarlo, den ganas de seguir jugando.

|   |   |   |   |
|---|---|---|---|
|Riesgo|Probabilidad|Impacto|Plan|
|El combate no engancha|Media|Muy alto|Probar cada cambio de combate en PC y móvil; no avanzar sin cumplir el criterio de la Fase 0|
|18 especializaciones desbalanceadas|Alta|Alto|Zona de práctica con mediciones, analítica de tasa de victoria y parches cada 2 semanas|
|Pocos tanks y sanadores en la cola|Alta|Alto|Mazmorra normal jugable sin roles, bono a roles que faltan, roles fáciles de jugar|
|Lag con 30 jugadores y muchos efectos|Media|Alto|Presupuestos de rendimiento, pruebas en móvil de gama media desde la Fase 1|
|Pérdida o duplicación de datos|Baja|Muy alto|ProfileStore con bloqueo de sesión, registro de inventario y restauración|
|Contenido se acaba rápido|Media|Alto|Sellos, PvP, colecciones y temporadas cada 8 semanas|
|Retraso del calendario|Alta|Medio|Beta temprana en el mes 7 y fases con criterio claro para recortar a tiempo|
|Arte inconsistente por usar IA|Media|Medio|Guía visual aprobada antes de producir y retoque manual|
|Cuello de botella de animación (unas 250 animaciones)|Alta|Alto|Animador contratado en Talent Hub antes de terminar la Fase 1; Warrior y Mage como referencia para medir el tiempo real; provisorias mientras tanto|
|Trampas que rompen la economía|Media|Alto|Servidor autoritativo, alertas por ganancias anormales y baneos|
|El juego no se descubre en Roblox|Media|Muy alto|Thumbnails y videos cuidados, comunidad desde la beta, eventos con fecha|

## Decisiones pendientes

Marca cada una cuando la decidas; lo que está en el doc es la recomendación.

- ¿Normal de mazmorra jugable solo, o siempre en grupo?
- ¿Nivel máximo 50 al lanzamiento, o 40 con la quinta zona en la primera temporada?
- ¿Nombres finales de zonas, mazmorras y jefes?
- ¿Estilo visual: low-poly estilizado, o más detallado?
- ¿Tamaño del equipo y quién hace código, arte 3D, animación y música?
- ¿Presupuesto para herramientas de pago (incluye ElevenLabs) y para contratar en Talent Hub?
- ¿Música final: generada con ElevenLabs Music o hecha por un compositor?
- ¿Precio del pase de temporada y de los Cristales?
- ¿Beta temprana abierta a todos o solo por invitación de Discord?
- ¿Idiomas al lanzamiento: solo español, o español e inglés?