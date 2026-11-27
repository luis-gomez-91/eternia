---
name: cerrar-cambio
description: Revisa y actualiza los documentos de Eternia (PLAN.md, ESTADO.md, AUDIO.md, guías visuales, fichas, CLAUDE.md) antes de dar un cambio por terminado, de hacer commit o de abrir un PR. Úsala siempre al terminar una tarea, al cambiar una decisión de diseño o un flujo de trabajo, o cuando el usuario pregunte qué sigue.
---

# Cerrar un cambio en Eternia

Los documentos tienen un solo papel cada uno (ver `CLAUDE.md`). Esta revisión evita que el plan y el estado queden atrasados respecto de lo que se hizo.

## 1. Ver qué cambió

```bash
git status --short
git diff --stat main...HEAD
git diff --stat
```

Repasar también lo que se decidió en la conversación aunque no haya tocado archivos: decisiones del usuario, cosas que se probaron y no funcionaron, cosas postergadas.

## 2. Recorrer cada documento

Para cada uno, preguntarse si el cambio lo afecta; si sí, editarlo.

- **`docs/ESTADO.md`** (siempre):
  - Marcar `[x]` la tarea hecha, o agregarla si no estaba.
  - Agregar tareas nuevas que hayan aparecido.
  - Marcar como postergado lo que el usuario decidió dejar para después.
  - Cerrar o actualizar las decisiones pendientes que se hayan resuelto.
  - Sumar una fila al registro con la fecha de hoy (formato `27 nov 2026`), que diga qué se hizo, qué se decidió y qué no funcionó.
  - Actualizar la "Última actualización" del principio.
- **`docs/PLAN.md`**: solo si cambió el diseño, una regla o un flujo de trabajo (cómo se hace el arte, el audio, las pruebas). No lleva avance. Si cambia de fase: la línea "Fase actual" de `PLAN.md` y la de `ESTADO.md`, y la tabla de fases, a la vez.
- **`docs/AUDIO.md`**: si se generó, subió o conectó un sonido, avanzar su estado (`Por generar` → `Generado` → `Subido` → `En juego`).
- **`docs/GUIA-VISUAL.md` / `docs/GUIA-VISUAL-TECNICA.md`**: si cambió una regla de arte, un color, una medida, o hay arte aprobado nuevo que sirva de referencia.
- **`docs/fichas/`**: si cambió una zona, jefe, NPC o mob, o sus sonidos.
- **`CLAUDE.md`**: si cambió cómo se trabaja (scripts, herramientas, rutas de assets, comandos).
- **Registros de assets**: `assets/audio/generated.json`, `assets/icons/uploaded.json` y los IDs en `src/shared/Data/`.

## 3. Comprobar que no se contradicen

- Lo que dice `PLAN.md` coincide con lo que se está haciendo de verdad.
- Ninguna tarea de `ESTADO.md` describe algo que el registro dice que cambió.
- Los enlaces entre documentos siguen apuntando a secciones que existen.

## 4. Antes de commitear

```bash
stylua --check src
selene src
```

Los documentos se escriben en español; los mensajes de commit, en inglés.

## 5. Contar el resultado

Al cerrar, decirle al usuario en una línea qué documentos se actualizaron (o por qué no hacía falta tocar ninguno más que `ESTADO.md`).
