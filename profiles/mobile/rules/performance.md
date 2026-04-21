---
paths:
  - "src/**/*.{ts,tsx}"
  - "components/**/*.{ts,tsx}"
---

# Performance en React Native

## Listas

- **FlatList / SectionList / FlashList** — nunca `.map()` sobre arrays largos.
- `keyExtractor` con ID estable (no índice).
- `getItemLayout` cuando los items son de tamaño fijo → skipea measurement.
- `initialNumToRender`, `maxToRenderPerBatch`, `windowSize` ajustables para listas pesadas.
- FlashList (Shopify) supera a FlatList en casi todo — considerar migración.

## Re-renders

- `useMemo`/`useCallback` NO son default. Usar solo cuando hay un problema medible (fps drops, cascadas).
- `React.memo` para componentes puros caros en listas.
- Context → granular (uno por tipo de estado), no un god-context.

## Imágenes

- `react-native-fast-image` para performance > `<Image>` nativo.
- Redimensionar en backend antes de servir (no confiar en `resizeMode`).
- `priority={FastImage.priority.low}` para imágenes off-screen.
- Cachear agresivamente; invalidar por versión en URL.

## Animaciones

- **Reanimated 3** para animaciones que corren en el UI thread (60/120 fps).
- `Animated` API legacy se ejecuta en el JS thread → bloqueable por garbage collection.
- Evitar animar propiedades de layout (width/height/top/left) — preferir `transform`.

## Bridges nativos

- Cada llamada entre JS y nativo cruza el bridge (sincronicamente costoso en RN legacy).
- Nuevo archi (Fabric + TurboModules) reduce este costo pero sigue importando.
- Batch operaciones cuando sea posible.

## Startup time

- Lazy-load pantallas que no son la inicial (react-navigation lazy loading).
- Diferir `require` de módulos pesados hasta que se necesiten.
- Hermes engine activado (por default en RN recientes).
- Minimizar tamaño del bundle inicial.

## Memoria

- Monitorear con Xcode Instruments (iOS) o Android Profiler.
- Leaks típicos: event listeners sin cleanup en `useEffect`, setIntervals sin clear, referencias circulares en context/state.

## Profiling

- Flipper (si disponible para la versión de RN) para ver renders.
- `why-did-you-render` en dev para detectar re-renders innecesarios.
- `react-native-performance` para medir marks y measures custom.

## Targets razonables

- Cold start < 2s en dispositivos mid-range.
- List scroll 60 fps estable (sin drops visibles).
- Interacciones < 100ms de latencia perceptible.
