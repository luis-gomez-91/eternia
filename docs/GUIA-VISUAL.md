# Eternia — Guía visual

**Estado:** Borrador, pendiente de aprobación · **Última actualización:** 26 nov 2026

Reglas de una página para que todo el arte del juego se vea como un solo juego. Ninguna pieza entra a arte final si no la cumple ([PLAN.md](PLAN.md), "Flujo de arte"). Las medidas, presupuestos, fichas de los 3 conceptos y la checklist de aprobación están en el anexo [GUIA-VISUAL-TECNICA.md](GUIA-VISUAL-TECNICA.md).

## Estilo en una frase

**Fantasía estilizada low-poly:** geometría angular y facetada, colores planos y saturados, siluetas que se reconocen en un celular a la distancia del brazo. Debe sentirse un RPG de fantasía con identidad propia, no una colección de assets genéricos de Roblox.

## Pilares

1. **Silueta primero.** Si en negro sólido no se distingue qué es (clase, mob, jefe), el diseño no sirve.
2. **El color es información.** Rojo, verde menta, azul y dorado tienen significado en combate (ver abajo) y no se usan de adorno.
3. **Pocas piezas, grandes.** Formas grandes antes que detalle chico: mejor rendimiento y lectura en móvil.
4. **El suelo se lee siempre.** Nada tapa las zonas de peligro marcadas en el suelo.
5. **Personajes y enemigos destacan** sobre el escenario; los efectos, llamativos pero breves.

## Forma y proporciones

- **Geometría:** caras planas y volúmenes claros; biselado leve solo donde ayuda a leer la forma. Nada demasiado redondeado ni con aspecto de juguete. Sin contorno negro global.
- **Proporciones:** algo exageradas. Armas, hombreras y cabezas de mobs entre 1,2 y 1,4 veces lo real; manos y pies grandes. La misma geometría en personajes, enemigos, armas y escenario.
- **Tamaño según amenaza:** mob normal ≈ 1 jugador; élite ≈ 1,5; jefe intermedio ≈ 2 a 2,5; jefe final ≥ 3 (el Ogro del Claro de la prueba mide ~3).

## Materiales

**SmoothPlastic** para casi todo (personajes, enemigos, piezas estilizadas). **Metal** para armas y armaduras. **Wood**, **Slate** y **Grass** solo en el escenario (estructuras, piedra, terreno). **Neon solo para efectos, ojos y runas** (brillo = algo importante), nunca de decoración. Sin texturas fotográficas: paletas y texturas compartidas ([anexo](GUIA-VISUAL-TECNICA.md#materiales-y-texturas-en-roblox)).

## Valor, saturación y luz

| Capa | Saturación | Brillo | Por qué |
|---|---|---|---|
| Escenario (suelo, paredes, árboles) | Media-baja | Tonos medios | Es el fondo: no compite |
| Personajes y enemigos | Alta | Más claros u oscuros que el fondo | Destacan sobre el fondo |
| Efectos de combate | Máxima (Neon) | Los más brillantes | Se leen por encima de todo |

La luz da volumen sin hundir a los personajes en sombra, con poco bloom y sin luces que oculten el suelo. Los caminos son un poco más claros que el terreno y cada punto de interés (fogata, tablón, portal) lleva el color de acento de la zona. Las paletas por zona están en [PLAN.md](PLAN.md), "Ambiente por zona".

## Código de color de combate (reservado)

Estos colores ya están en el juego (`Data/Feedback`, `EnemyUIController`, `MobFeedbackController`). No se usan para otra cosa.

| Significado | Color | Dónde |
|---|---|---|
| **Peligro enemigo** | Rojo `#FF2D23` | Zonas de aviso en el suelo, brillo del mob al cargar un ataque. Solo enemigos |
| Daño recibido | Rojo claro `#FF463C` | Números sobre el jugador |
| **Curación** | Verde menta `#78FFAA` | Números "+", efectos de curar. Nadie más usa este verde |
| Crítico | Dorado `#FFD23C` | Números con "!" |
| Defensa y esquivar | Azul cielo `#8CD2FF` | "Esquivado", esquivar, escudos |
| Definitiva | Naranja `#FF7828` | Botón y barra de la R |
| Veneno y magia vil | Verde ácido `#AFFF32` a `#C8F028` | Araña, Brujo. Amarillento a propósito, para no confundirse con la curación |

**Colores de las clases** (efectos, arma provisoria, acento de su UI y fondo o brillo de sus íconos). Cada clase tiene un color principal para que se reconozca de un vistazo, elegido para no confundirse con los colores reservados. En los íconos es una guía, no una regla: manda el color del elemento (el fuego es naranja aunque sea del Mage, la curación es verde menta).

| Clase | Color | Cuidado con |
|---|---|---|
| Warrior | Rojo carmesí oscuro `#A0202E`, con acero | Oscuro y apagado, para no parecer el rojo de peligro `#FF2D23` |
| Paladín | Dorado bronce `#E0A030`, con blanco | Más cálido que el dorado de los críticos `#FFD23C` |
| Ranger | Amarillo mostaza `#D8C83A`, con madera | Más verdoso que el amarillo de la barra de Energía |
| Mage | Azul cobalto `#2F6BFF`, con fuego naranja | Más oscuro y saturado que el azul cielo de defensa `#8CD2FF` |
| Sacerdote | Blanco cálido `#FFF4D6`, con dorado | Las curaciones siguen en verde menta |
| Brujo | Morado `#8A3FD0`, con verde ácido vil | El verde vil sigue siendo amarillento, nunca menta |

**Rarezas:** Común gris `#B4B4B4`, Raro azul `#3C8CFF`, Épico morado `#A04BFF`, Legendario naranja `#FF8C1E`. Se ven en bordes, haces de luz del loot y textos.

## Personajes (jugadores)

Avatares R15 de Roblox con armaduras como accesorios modulares, compatibles con las animaciones del rig. Cada clase se reconoce por una pieza grande que **se conserva aunque cambie el equipo o el cosmético**:

| Clase | Pieza de silueta | Arma |
|---|---|---|
| Warrior | Hombreras grandes | Espada ancha |
| Paladín | Escudo grande | Maza |
| Ranger | Capucha y carcaj | Arco largo |
| Mage | Sombrero puntiagudo | Bastón con orbe |
| Sacerdote | Túnica larga y aro de luz | Libro sagrado |
| Brujo | Capucha con cuernos | Varita y grimorio |

## Enemigos

- Cuatro niveles: **normal** (silueta simple), **élite** (más grande, con una pieza distintiva), **jefe intermedio** (silueta y movimientos propios) y **jefe final** (diseño único, gran presencia, ataques reconocibles).
- Más saturados que el fondo de su zona, con **ojos en Neon** para leer hacia dónde miran (ámbar u otro color de la familia, no el rojo de peligro).
- Nunca usan verde menta ni azul cielo: esos colores son de los jugadores.
- Una familia (por ejemplo, los goblins: verde oliva, orejas largas, cuero) comparte paleta y forma base, pero cada tipo cambia la silueta, no solo el color.

## Animación

Las animaciones comunican el combate, no solo decoran. Cada ataque tiene **anticipación** (postura de aviso junto con la zona roja), **golpe** claro y **recuperación** (la ventana para pegarle), y es más larga cuanto más fuerte es el ataque. Los enemigos pesados se mueven más lento; los jefes, pesados y deliberados. Las habilidades usan los colores de su clase. Los tiempos están en el [anexo](GUIA-VISUAL-TECNICA.md#animación).

## Efectos visuales

- Cortos: golpes y proyectiles de menos de 0,6 s, y áreas solo mientras hacen daño. Nada permanente que meta ruido.
- **Los efectos aliados que cubren el suelo no pasan del 50% de opacidad** y siempre quedan por debajo del rojo de peligro. Ningún efecto tapa al personaje.
- Partículas y luces con presupuesto y versión reducida para gráficos bajos ([anexo](GUIA-VISUAL-TECNICA.md#presupuestos-orientativos)).

## Interfaz

- Marcos simples de piedra y metal, esquinas redondeadas.
- **Íconos de habilidades:** ilustración pintada que llena todo el cuadrado (opaca, sin transparencia ni marco), con luz dramática: un foco brillante y bordes que caen a oscuro. Un solo motivo grande que se reconozca a 44 px. **Sin texto dibujado dentro** (para traducir). El marco, el redondeo en móvil y el apagado los pone la interfaz. Inspirados en el estilo de los RPG clásicos, nunca copiando íconos de otro juego.
- Fuente Gotham (Bold y Black). **Mínimo 14 px** de texto en móvil.
- PC y móvil hoy (consola, más adelante). En móvil, botones de 44 px o más en arco alrededor del pulgar derecho; el lado izquierdo queda libre para el joystick. Detalle por plataforma en el [anexo](GUIA-VISUAL-TECNICA.md#interfaz-por-plataforma).

## Lo que no va

Realismo, texturas fotográficas, sangre o gore, contorno negro global, formas de juguete, Neon decorativo, rojo en efectos aliados, verde menta o azul cielo en enemigos, brillos que tapen el suelo, texto dentro de los iconos.

## Para aprobarla

Se aprueba cuando los 3 conceptos de prueba (Warrior con armadura, Goblin Saqueador y rincón del Claro del Molino) pasan **juntos** la checklist del [anexo](GUIA-VISUAL-TECNICA.md#checklist-de-aprobación). Hasta entonces sigue en borrador.
