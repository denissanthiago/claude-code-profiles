# TODO — rules específicas al elegir librería

Este archivo existe como placeholder. Cuando elijas la librería de animación, reemplazá este archivo por rules concretas según el stack.

## Sugerencia de rules a crear

### Si elegís **Remotion**
- `remotion-components.md` — naming, composition structure, props schema con Zod
- `performance.md` — evitar re-renders en compositions, memoization de frames, assets pre-loaded
- `audio-sync.md` — sincronización con frame-accurate timing

### Si elegís **Motion Canvas**
- `scene-structure.md` — organización de `scenes/`, imports de signals
- `animation-timing.md` — uso de `yield*`, `waitFor`, tweens
- `reusable-elements.md` — cuándo abstraer a generators

### Si elegís **GSAP**
- `timeline-patterns.md` — cómo estructurar timelines complejas
- `accessibility.md` — respetar `prefers-reduced-motion`
- `dom-vs-svg.md` — qué animar con qué

### Si elegís **Rive**
- `state-machines.md` — naming y granularidad
- `interop.md` — cómo integrar `.riv` en web/mobile/native
- `animation-sync.md` — eventos desde Rive al código host

## Común a cualquier librería

- `storyboard-first.md` — no abrir editor sin storyboard escrito
- `asset-management.md` — dónde viven assets, convenciones de naming, optimización
- `accessibility-motion.md` — respetar motion reduction preferences
- `export-pipeline.md` — qué formato para qué canal (TikTok vs YouTube vs embed web)

## Borrar este archivo cuando las rules reales estén listas.
