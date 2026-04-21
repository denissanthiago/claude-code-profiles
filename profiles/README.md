# Perfiles

Plantillas reutilizables que se aplican a un repo con `ccp apply <perfil>`.

Cada perfil es un **directorio** bajo `profiles/` con esta estructura (todos los subdirectorios son opcionales):

```
profiles/<nombre>/
├── profile.json              # metadata (name, description, stack)
├── CLAUDE.md                 # se appendea a <repo>/CLAUDE.md con un marker
├── settings.json             # se mergea con <repo>/.claude/settings.json
├── mcp.json                  # se mergea con <repo>/.mcp.json
├── rules/
│   └── *.md                  # se copian a <repo>/.claude/rules/
├── skills/
│   └── <skill>/SKILL.md      # carpetas se copian a <repo>/.claude/skills/
├── agents/
│   └── *.md                  # se copian a <repo>/.claude/agents/
├── commands/
│   └── *.md                  # se copian a <repo>/.claude/commands/
├── references/
│   └── *.md                  # se copian a <repo>/.claude/references/
└── scripts/
    └── *                     # se copian a <repo>/.claude/scripts/
```

## Semántica del merge

| Origen | Destino | Qué hace al re-aplicar |
|---|---|---|
| `CLAUDE.md` | `<repo>/CLAUDE.md` | Si ya existe la sección `<!-- apply-profile: <nombre> -->`, skip (usa `--force` para regenerar) |
| `settings.json` | `<repo>/.claude/settings.json` | Arrays `allow`/`deny` unidos y deduplicados. `env` existente gana. `hooks` concatenados por evento |
| `mcp.json` | `<repo>/.mcp.json` | `mcpServers` unidos. En colisión de nombre, el existente gana |
| `rules/*.md` | `<repo>/.claude/rules/` | Copia si no existe. Skip con warning si existe (usa `--force` para sobrescribir) |
| `skills/<n>/` | `<repo>/.claude/skills/` | Igual |
| `agents/*.md` | `<repo>/.claude/agents/` | Igual |
| `commands/*.md` | `<repo>/.claude/commands/` | Igual |
| `references/*.md` | `<repo>/.claude/references/` | Igual |
| `scripts/*` | `<repo>/.claude/scripts/` | Igual |

## Uso

```bash
# Listar perfiles disponibles
./ccp profile list

# Preview (no escribe nada)
cd /ruta/a/tu/proyecto
/Users/denis/Projects/Personal/configure-claude-code/ccp apply --dry-run frontend

# Aplicar
/Users/denis/Projects/Personal/configure-claude-code/ccp apply frontend

# Aplicar sobrescribiendo existentes
/Users/denis/Projects/Personal/configure-claude-code/ccp apply --force frontend

# Aplicar varios perfiles al mismo repo
./ccp apply frontend
./ccp apply backend
```

## Cómo crear un perfil nuevo

1. Crear carpeta: `mkdir profiles/<nombre>/`
2. Agregar `profile.json` con metadata:
   ```json
   { "name": "<nombre>", "description": "Para qué es este perfil", "stack": ["React", "TypeScript"] }
   ```
3. Agregar sólo las partes que te importen (CLAUDE.md, settings.json, rules/, etc.).
4. Probar con `./ccp apply --dry-run <nombre>` en un repo de prueba.

## Convenciones

- **Nombres en kebab-case**: `frontend`, `backend`, `video-creator`, `mobile`.
- **Prefijo `_`** para perfiles-plantilla que no se quieren listar: `_template/`.
- **profile.json** es obligatorio si querés que aparezca la descripción en `--list`.
- **Nunca pongas secretos** en `mcp.json` del perfil — usa env vars.

## Perfiles actuales

| Nombre | Estado |
|---|---|
| `frontend` | ⏳ pendiente |
| `backend` | ⏳ pendiente |
| `mobile` | ⏳ pendiente |
| `video-creator` | ⏳ pendiente (librería por definir) |
