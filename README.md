# configure-claude-code

Herramienta personal para gestionar y aplicar configuraciones de [Claude Code](https://claude.com/claude-code) de forma reutilizable entre proyectos.

El núcleo es **`ccp`** (Claude Code Profiles): un CLI bash que aplica *perfiles* — bundles de rules, skills, agents, commands, references, scripts, `settings.json` y `.mcp.json` — al `.claude/` de cualquier repo target.

> La documentación canónica extendida vive en el vault de Obsidian bajo `configure-claude-code/` (entry: `Índice.md`). Este README es el punto de entrada rápido.

---

## Qué resuelve

Sin esto: en cada proyecto nuevo copiás a mano `.claude/` + `CLAUDE.md` + `settings.json` + MCPs, y las actualizaciones quedan sueltas en cada repo.

Con esto: un perfil (`frontend`, `backend`, `mobile`, …) se aplica con un comando, se puede re-aplicar con `--force`, se desinstala limpio con `--uninstall`, y los recursos externos (packs de GitHub) se pinean a un commit o branch.

---

## Requisitos

- `bash` ≥ 4, `jq`, `git`
- `claude` CLI instalado y logueado (para los comandos `draft …` que usan IA)
- macOS o Linux
- Node ≥ 20 si vas a instalar MCPs con `install-mcps.sh`

---

## Instalación

No hay instalador — es un repo de scripts. Cloná y opcionalmente aliaseá `ccp`:

```bash
git clone <este-repo> ~/Projects/Personal/configure-claude-code
cd ~/Projects/Personal/configure-claude-code

# Opcional: alias para tener ccp en el PATH
echo 'alias ccp="~/Projects/Personal/configure-claude-code/scripts/ccp"' >> ~/.zshrc
```

Para los MCPs globales (chrome-devtools, obsidian, playwright, context7, exa):

```bash
# exa es opcional — solo se instala si exportás EXA_API_KEY
export EXA_API_KEY='tu-key'   # https://dashboard.exa.ai/api-keys
./scripts/install-mcps.sh
```

Configuración global (`~/.claude/settings.json` y `~/.claude/hooks/`) viene en `global/` — copialo a mano cuando quieras:

```bash
cp global/settings.json ~/.claude/settings.json
cp -R global/hooks ~/.claude/
```

---

## Uso rápido

```bash
# Ver perfiles disponibles
ccp profile list

# Desde el repo target (no desde este repo), aplicá un perfil
cd /ruta/a/tu/proyecto
ccp apply --dry-run frontend        # preview, no escribe nada
ccp apply frontend                  # aplica
ccp apply --force frontend          # sobrescribe existentes
ccp apply frontend --uninstall      # revierte (no toca settings.json ni mcp.json)
```

Un `apply` copia a `.claude/rules/`, `.claude/skills/`, `.claude/agents/`, etc., y appendea al `CLAUDE.md` del target envuelto en `<!-- apply-profile: <nombre> -->`. Todo lo escrito queda trackeado en `.claude/.applied-profiles.json`.

Ver todas las opciones con `ccp --help`.

---

## Perfiles disponibles

| Perfil | Descripción | Stack |
|---|---|---|
| `frontend` | Frontend web | React · TypeScript · Next/Vite · Tailwind · Vitest · Playwright |
| `backend` | Backend + DB + infraestructura | Node/Bun · TypeScript · Postgres · Prisma · Docker · Vitest |
| `mobile` | Mobile (iOS + Android) | React Native · Expo · TypeScript · Jest |
| `video-creator` | Creación de videos con animaciones | TypeScript · Node (librería por definir) |

Crear uno nuevo:

```bash
ccp profile create mi-perfil --description "..." --stack "Go,PostgreSQL"
```

La anatomía de un perfil está documentada en [`profiles/README.md`](profiles/README.md).

---

## Gestión de recursos

CRUD individual (templates locales o desde GitHub/path):

```bash
ccp <type> add    <profile> <name> [--from <url|path>]
ccp <type> remove <profile> <name>
ccp <type> list   <profile>
# <type> ∈ skill · agent · command · rule · reference · script · mcp
```

Packs externos — repos de GitHub completos instalados como unidad:

```bash
ccp pack install <profile> https://github.com/owner/repo [--pin SHA | --branch X | --tag vX]
ccp pack update  <profile> <pack|--all>
ccp pack remove  <profile> <pack>
ccp pack list    <profile>
ccp pack adopt   <profile> <url>   # manifest retroactivo si ya los copiaste
```

Inventario completo de un perfil con conteos y barras:

```bash
ccp inventory <profile>
```

Workspace de drafts asistido por IA (para crear skills/rules/agents nuevos con ayuda del `claude` CLI antes de instalarlos):

```bash
ccp draft create  <type> <name>
ccp draft refine  <type> <name>
ccp draft install <type> <name> <profile[,profile2,…]>
ccp draft list [--all]
ccp draft discard <type> <name>
ccp draft history
```

---

## Estructura

```
configure-claude-code/
├── scripts/
│   ├── ccp                    # CLI principal (bash)
│   ├── install-mcps.sh        # instala MCPs globales (scope=user)
│   ├── test.sh                # test suite
│   └── lib/cyber-ui.sh        # UI compartida (colors, logs, banners)
├── profiles/                  # perfiles reutilizables (ver profiles/README.md)
│   ├── frontend/
│   ├── backend/
│   ├── mobile/
│   └── video-creator/
├── global/                    # config global (copiar a ~/.claude/)
│   ├── settings.json
│   └── hooks/session-start.sh
├── drafts/                    # workspace de drafts (asistido por IA)
└── CLAUDE.md                  # guía para instancias de Claude Code dentro del repo
```

---

## Tests

```bash
scripts/test.sh                 # todos
scripts/test.sh <prefix>        # filtro por nombre
scripts/test.sh -v              # verbose
```

Los tests son funciones bash `test_<name>()` que importan `ccp` en modo librería (`PROFILE_SH_LIB=1`) para probar helpers internos sin disparar el dispatch.

---

## Seguridad

- `ccp apply` **rechaza** correr con target = este repo o = `~/.claude/` para no pisarse.
- Archivos que vienen de un `pack` quedan write-locked contra `remove` directo — se tocan solo vía `pack remove`/`update`.
- `pack install` **advierte** si el pack trae hooks (`*.sh`), hooks en `settings.json` o MCP servers, porque corren código arbitrario en tu máquina. Revisá el repo antes de instalar.
- `global/settings.json` tiene un baseline de `deny` para operaciones destructivas (rm -rf, git push --force, git reset --hard, dd, mkfs, edits a `~/.ssh`, `~/.aws`, shells de login, etc.).

---

## Licencia

Repo personal. Sin licencia explícita — usalo de referencia, forkealo si te sirve.
