## Perfil: video-creator

> ⚠ **Perfil placeholder.** El stack concreto depende de la librería de animación elegida. Este perfil contiene lo mínimo común a cualquier flow de creación de videos programáticos con JS/TS.

### Decisiones pendientes

- [ ] **Librería de animación principal** (elegir una):
  - **Remotion** — React components, server-side render (Lambda farm). Ideal para video con datos dinámicos, hooks de React, composición declarativa.
  - **Motion Canvas** — TypeScript + generadores, preview en navegador. Ideal para animaciones de sistema/motion design.
  - **GSAP** — DOM/SVG, runtime. Ideal para web interactivo más que para videos renderizables.
  - **Rive** — archivos `.riv` + state machines. Ideal para assets animados reutilizables.
  - **Framer Motion** — React, web-first. Mezcla con video si es una web-app con animaciones expuestas.
  - **Three.js / React Three Fiber** — 3D.

- [ ] **Pipeline de render:** local vs cloud (Lambda, Remotion Render, custom)
- [ ] **Formato de salida:** MP4 (H.264/H.265), WebM, GIF animado
- [ ] **Audio:** integrado en pipeline o post-producción externa (DaVinci, Premiere)
- [ ] **Assets:** repo vs CDN vs S3

### Stack base común (independiente de la librería)

- **Lenguaje:** TypeScript
- **Runtime:** Node.js ≥ 20
- **Package manager:** pnpm / bun
- **Ffmpeg** instalado globalmente (para post-procesamiento, conversión de formato)

### Comandos típicos (ajustar al elegir librería)

```bash
pnpm install
pnpm dev              # preview del video
pnpm render           # renderizar a video final
```

### Qué NO tocar

- `out/`, `build/`, `render/` — outputs de render
- `node_modules/`
- `.env*` — keys de cloud (AWS, etc.) si usás pipeline cloud

### MCPs globales disponibles

- `exa` — research de referencias visuales, librerías, tutoriales
- `context7` — docs de la librería de animación (cuando esté elegida)
- `chrome-devtools` — preview en navegador si aplica
- `obsidian` — scripts de video, storyboards

### Próximo paso

Cuando decidas librería:
1. Editá este `CLAUDE.md` con el stack concreto
2. Ajustá `settings.json` con permisos específicos (comandos de render, deploy, etc.)
3. Creá `rules/` con convenciones de animación (naming, duración, easing, paleta)
4. Considerá skills tipo `generate-intro`, `render-final`, `export-gif`

### Contexto del proyecto

<!-- Edita esta sección al aplicar el perfil -->

- **Tipo de contenido:** TODO (tutorials, shorts, reviews, cinematics)
- **Duración típica:** TODO
- **Canal:** YouTube / TikTok / Twitter / LinkedIn / otro
- **Audiencia:** TODO
