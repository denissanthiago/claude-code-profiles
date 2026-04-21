## Perfil: frontend

Stack base asumido (ajustá al aplicar si tu repo usa otro):

- **Lenguaje:** TypeScript (estricto, sin `any`)
- **UI:** React (Server Components cuando aplique)
- **Framework:** Next.js o Vite + React
- **Styling:** Tailwind + shadcn/ui (o CSS Modules según repo)
- **Tests:** Vitest (unit/integration) + Playwright (e2e)
- **Package manager:** detectar desde el lockfile (`pnpm-lock.yaml`, `bun.lockb`, `package-lock.json`)

### Convenciones

- Componentes funcionales con hooks. Sin clases salvo ErrorBoundary.
- Un componente por archivo. Nombre del archivo = nombre del componente (PascalCase).
- Barrel imports (`index.ts`) solo cuando el directorio exporta una API pública.
- `any` prohibido. Usar `unknown` + narrowing, o tipos específicos.
- Comentarios solo para el **por qué** no obvio. Nada de "// get user" arriba de `getUser()`.

### Comandos típicos

```bash
# Dev
pnpm dev              # o: bun dev / npm run dev

# Build
pnpm build

# Lint / typecheck
pnpm lint
pnpm typecheck        # o: npx tsc --noEmit

# Tests
pnpm test             # Vitest
pnpm test:e2e         # Playwright
```

Ajustar si tu repo usa otros scripts.

### Qué NO tocar

- `.env*` — variables sensibles. Pedí al usuario.
- `*-lock.*` — lockfiles. No editar a mano.
- `.next/`, `dist/`, `build/`, `.output/` — artefactos de build.
- `node_modules/` — dependencias.

### MCPs globales disponibles

- `chrome-devtools` — debugging visual en tu Chrome real
- `playwright` — automation headless multi-browser
- `context7` — docs actualizados (React, Next, etc.)
- `exa` — research general
- `obsidian` — notas/documentación

### Pack addyosmani/agent-skills bundled

Este perfil incluye el pack completo de [addyosmani/agent-skills](https://github.com/addyosmani/agent-skills):

**Skills (21)** — auto-invocados cuando el prompt matchea la description:
`api-and-interface-design`, `browser-testing-with-devtools`, `ci-cd-and-automation`, `code-review-and-quality`, `code-simplification`, `context-engineering`, `debugging-and-error-recovery`, `deprecation-and-migration`, `documentation-and-adrs`, `frontend-ui-engineering`, `git-workflow-and-versioning`, `idea-refine`, `incremental-implementation`, `performance-optimization`, `planning-and-task-breakdown`, `security-and-hardening`, `shipping-and-launch`, `source-driven-development`, `spec-driven-development`, `test-driven-development`, `using-agent-skills` (meta)

**Slash commands (7)** — invocación manual:
`/spec` · `/plan` · `/build` · `/test` · `/review` · `/code-simplify` · `/ship`

**Agents (3)** — subagentes especializados:
`code-reviewer`, `security-auditor`, `test-engineer`

**References (4)** — checklists consultables por los skills:
`accessibility-checklist.md`, `performance-checklist.md`, `security-checklist.md`, `testing-patterns.md`

**SessionStart hook** inyecta automáticamente la meta-skill `using-agent-skills` al iniciar cada sesión — contiene un flowchart para que Claude elija el skill correcto según la tarea.

Lazy-loading: aunque hay 21 skills, solo se carga el contenido completo del que matchea tu pedido. Los demás quedan como descripción en contexto.

### Contexto del proyecto

<!-- Edita esta sección al aplicar el perfil con los detalles específicos de tu repo -->

- **Nombre del proyecto:** TODO
- **Qué hace:** TODO
- **URL dev:** http://localhost:3000 (default)
- **URL prod:** TODO
- **Integraciones externas:** TODO
