# Eternia

RPG de acción para Roblox (Rojo + Luau). Los documentos están en español; el código, sus comentarios y los mensajes de commit también se escriben como ya están (comentarios en español, commits en inglés).

## Documentos (`docs/`)

Cada documento tiene un solo papel, para que no se contradigan:

- `PLAN.md`: cómo es el juego y qué entra en cada fase. No lleva estado ni avance, salvo la línea "Fase actual" del principio.
- `ESTADO.md`: lo hecho y lo pendiente. Es la fuente del avance: fase actual, tabla de fases, tareas de la fase con casillas, decisiones pendientes y registro por fecha.
- `AUDIO.md`: catálogo de sonidos y su estado (`Por generar` → `Generado` → `Subido` → `En juego`).
- `GUIA-VISUAL.md` y `GUIA-VISUAL-TECNICA.md`: reglas de arte y medidas para Roblox.
- `fichas/`: una ficha por zona, mazmorra, jefe, NPC o mob, con su sección de sonidos.

Al terminar un cambio (la skill `cerrar-cambio` lleva la revisión completa, documento por documento):

1. Marcar la tarea en `ESTADO.md` (o agregarla si es nueva) y sumar una fila al registro con la fecha.
2. Si cambia el diseño, actualizar `PLAN.md` y, si suma trabajo, la tarea en `ESTADO.md`.
3. Al cambiar de fase, actualizar a la vez la línea "Fase actual" de `PLAN.md`, la de `ESTADO.md` y su tabla de fases.

## Código

- `src/server/Services`, `src/client/Controllers`, `src/shared/Data` (datos de habilidades, clases, mobs y feedback) y `src/shared/Remotes.luau` (cada remoto con su límite por segundo).
- El servidor valida todo el combate; el cliente solo anticipa.
- Animación, efectos, sonidos e íconos se definen por datos: cambiar un asset es cambiar un ID, no código.
- Antes de commitear: `stylua --check src` y `selene src`.

## Assets

- Sonidos: generados con ElevenLabs (clave en `.env`), guardados en `assets/audio/<grupo>/` y registrados en `assets/audio/generated.json` con su `assetId`. Se suben con Open Cloud (MCP de Roblox Studio, `/assets/v1/assets`, creador = usuario dueño del place) y el ID va a `SOUND_IDS` en `src/shared/Data/Feedback.luau`.
- Íconos de habilidades: PNG de 256 px en `assets/icons/<clase>/`, registrados en `assets/icons/uploaded.json`. Se suben como `Image` (no `Decal`, cuyo ID no sirve en scripts) y el ID va al campo `Icon` de `src/shared/Data/Abilities.luau`. Se generan con Gemini (`assets/icons/generate_icons.py`, clave `GEMINI_API_KEY` en `.env`, instrucciones en `prompts.json`), se elige un candidato en `finalize_icons.py` y se muestran al usuario antes de subirlos.
- Pruebas en PC y en móvil (simulador de Studio y celular real) antes de dar algo por terminado.
