---
paths:
  - "src/**/*.{ts,tsx}"
  - "App.{ts,tsx}"
  - "components/**/*.{ts,tsx}"
---

# Diferencias iOS vs Android

Se carga al tocar código de la app.

## Cuándo divergir por plataforma

1. **UX guidelines específicas:** iOS HIG vs Material Design (ej. tab bars position, nav transitions).
2. **APIs nativas diferentes:** permissions, push notifications, deep links.
3. **Componentes con comportamiento distinto:** `Picker`, `DatePicker`, `Alert`.

## Patrones de implementación

### Platform.select (inline)

Para diferencias pequeñas:

```typescript
import { Platform, StyleSheet } from 'react-native';

const styles = StyleSheet.create({
  container: {
    paddingTop: Platform.select({ ios: 20, android: 0 }),
  },
});
```

### Archivos separados por plataforma

Para componentes con lógica divergente:

```
Button.tsx          # compartido (interfaz común, re-exporta)
Button.ios.tsx      # iOS-specific
Button.android.tsx  # Android-specific
```

Metro bundler resuelve automáticamente por plataforma.

### Platform.OS checks

```typescript
if (Platform.OS === 'ios') {
  // ...
}
```

Usar solo cuando es imposible refactorizar a `Platform.select`. Ensucia el código.

## Áreas típicamente divergentes

### Navigation
- iOS: slide-from-right nativa, swipe-back gesture.
- Android: hardware back button debe funcionar siempre.

### Permisos
- iOS: Info.plist con `NSCameraUsageDescription` etc.
- Android: `AndroidManifest.xml` + runtime request para APIs 23+.

### Notifications
- iOS: `UNUserNotificationCenter`, requiere provisioning profile con aps-environment.
- Android: `FirebaseMessaging` + canales de notificación (API 26+).

### Status bar / safe area
- iOS: notch/dynamic island. Usar `react-native-safe-area-context`.
- Android: edge-to-edge + insets. También SafeArea.

### Fonts
- iOS: arrastrar .ttf a Xcode + registrar en Info.plist.
- Android: meter en `android/app/src/main/assets/fonts/`.
- `react-native-asset` ayuda a sincronizar.

### Linking
- iOS: Universal Links (asociado a dominios con `apple-app-site-association`).
- Android: App Links (con `assetlinks.json`).

## Lo que NO hay que diferenciar

La mayoría del código (80%+) debe ser **idéntico** entre plataformas. Si te encontrás divergiendo mucho, preguntate si React Native es el stack correcto.
