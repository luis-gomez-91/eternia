# Fichas de diseño

Cada pieza del juego (zona, mazmorra, jefe, NPC, mob) tiene su ficha antes de construirse. Ver [PLAN.md](../PLAN.md), sección "Cómo se diseña cada cosa".

**Flujo:** ficha → concepto visual → caja gris → prueba → arte final.
Una pieza no entra a construcción sin su ficha aprobada, ni a arte final sin pasar la prueba en caja gris.

## Cómo crear una ficha

1. Copiar la plantilla de [`_plantillas/`](_plantillas/) a la carpeta de su tipo (`zonas/`, `mazmorras/`, `jefes/`, `npcs/`, `mobs/`).
2. Nombre del archivo en minúsculas con guiones: `jefes/ignaroth-el-dragon.md`.
3. Llenarla y cambiar el estado a medida que avanza.

## Estados

`Borrador` → `Aprobada` → `En caja gris` → `Probada` → `Arte final` → `Terminada`

## Fichas

| Ficha | Tipo | Fase | Estado |
|---|---|---|---|
| [Jefe de prueba](jefes/jefe-de-prueba.md) | Jefe | 0 | Borrador |
| [Mob cuerpo a cuerpo](mobs/mob-cuerpo-a-cuerpo.md) | Mob | 0 | Borrador |
| [Mob a distancia](mobs/mob-a-distancia.md) | Mob | 0 | Borrador |
| [Mob de carga](mobs/mob-de-carga.md) | Mob | 0 | Borrador |
