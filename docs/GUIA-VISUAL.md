# Eternia — Guía visual

**Estado:** Borrador · **Última actualización:** 26 nov 2026

Reglas de una página para que todo el arte del juego se vea como un solo juego. Ninguna pieza entra a arte final si no la cumple ([PLAN.md](PLAN.md), "Flujo de arte"). Cuando se apruebe, cierra la decisión pendiente de estilo visual.

## Estilo en una frase

**Fantasía estilizada low-poly:** formas grandes y facetadas, colores planos y saturados, siluetas que se reconocen en un celular a la distancia del brazo.

## Pilares

1. **Silueta primero.** Si en negro sólido no se distingue qué es (clase, mob, jefe), el diseño no sirve.
2. **El color es información.** Rojo, verde menta, azul y dorado tienen significado en combate (ver abajo) y no se usan de adorno.
3. **Pocas piezas, grandes.** Antes que detalle chico: menos triángulos, mejor rendimiento y lectura en móvil.
4. **El suelo se lee siempre.** Nada tapa las zonas de peligro marcadas en el suelo.

## Forma, materiales y proporciones

- **Modelos:** low-poly con caras planas o un biselado leve. Sin texturas fotográficas: color por cara o una textura de paleta de 256 px compartida. Mobs con menos de 3.000 triángulos y jefes con menos de 15.000.
- **Materiales de Roblox:** SmoothPlastic para casi todo; Wood, Slate y Grass solo en el escenario; **Neon solo para efectos, ojos y runas** (brillo = algo importante).
- **Proporciones:** algo exageradas. Armas, hombreras y cabezas de mobs entre 1,2 y 1,4 veces lo real. Manos y pies grandes.
- **Tamaño según amenaza:** mob normal ≈ 1 jugador; élite ≈ 1,5; jefe intermedio ≈ 2 a 2,5; jefe final ≥ 3 (el Ogro del Claro de la prueba mide ~3).

## Valor y saturación por capas

| Capa | Saturación | Brillo | Por qué |
|---|---|---|---|
| Escenario (suelo, paredes, árboles) | Media-baja | Tonos medios | Es el fondo: no compite |
| Personajes y enemigos | Alta | Más claros u oscuros que el fondo | Destacan sobre el fondo |
| Efectos de combate | Máxima (Neon) | Los más brillantes | Se leen por encima de todo |

Los caminos son un poco más claros que el resto del terreno, y cada punto de interés (fogata, tablón, portal) lleva el color de acento de la zona. Las paletas por zona están en [PLAN.md](PLAN.md), "Ambiente por zona".

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

**Colores de las clases** (efectos, arma provisoria, acento de su UI): Warrior acero y brasa, Paladín dorado sagrado, Ranger verde naturaleza, Mage morado arcano y fuego, Sacerdote luz blanca cálida, Brujo morado sombra con verde vil.

**Rarezas:** Común gris `#B4B4B4`, Raro azul `#3C8CFF`, Épico morado `#A04BFF`, Legendario naranja `#FF8C1E`. Se ven en bordes, haces de luz del loot y textos.

## Personajes (jugadores)

Avatares R15 de Roblox con armaduras como accesorios. Cada clase se reconoce por una pieza grande:

| Clase | Pieza de silueta | Arma |
|---|---|---|
| Warrior | Hombreras grandes | Espada ancha |
| Paladín | Escudo grande | Maza |
| Ranger | Capucha y carcaj | Arco largo |
| Mage | Sombrero puntiagudo | Bastón con orbe |
| Sacerdote | Túnica larga y aro de luz | Libro sagrado |
| Brujo | Capucha con cuernos | Varita y grimorio |

## Enemigos

- Más saturados que el fondo de su zona, con **ojos en Neon** para leer hacia dónde miran.
- Cada ataque tiene **postura de aviso** (se echa atrás, levanta el arma) además de la zona roja en el suelo.
- Nunca usan verde menta ni azul cielo: esos colores son de los jugadores.
- Los mobs de una zona comparten paleta y forma de base (por ejemplo, todos los goblins: verde, orejas largas, ropa de cuero).

## Efectos visuales

- Cortos: golpes y proyectiles de menos de 0,6 s, y áreas solo mientras hacen daño.
- **Los efectos aliados que cubren el suelo no pasan del 50% de opacidad** y siempre quedan por debajo del rojo de peligro.
- Como máximo 200 partículas activas por efecto, con versión reducida para gráficos bajos.

## Interfaz

- Marcos simples de piedra y metal, esquinas redondeadas, iconos con contorno grueso y **sin texto dibujado dentro** (para traducir).
- Fuente Gotham (Bold y Black). **Mínimo 14 px** de texto en móvil.
- En móvil, botones de 44 px o más, en arco alrededor del pulgar derecho; el lado izquierdo queda libre para el joystick.

## Lo que no va

Realismo, texturas fotográficas, sangre o gore, rojo en efectos aliados, verde menta en enemigos, brillos que tapen el suelo, texto dentro de los iconos.

## Pendiente para aprobarla

- [ ] 3 conceptos de prueba con esta guía: el Warrior con armadura, el Goblin Saqueador y un rincón del Claro del Molino. Se pueden generar con una IA de imágenes como base y retocar.
- [ ] Ajustar la UI provisoria que hoy usa texto de 11 a 13 px (barra de habilidades, botones táctiles) al mínimo de 14 px, cuando se haga la UI final.
- [ ] Aprobar y marcar la decisión de estilo en [ESTADO.md](ESTADO.md).
