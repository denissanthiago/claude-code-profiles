## Perfil: mobile

Stack base asumido (ajustá al aplicar si tu repo usa otro):

- **Framework:** React Native (bare o Expo managed)
- **Lenguaje:** TypeScript estricto
- **Plataformas:** iOS + Android
- **Navegación:** react-navigation
- **Estado:** zustand / jotai / redux (según proyecto)
- **Tests:** Jest + React Native Testing Library + Detox para E2E
- **iOS:** Xcode + CocoaPods
- **Android:** Gradle

### Convenciones

- Componentes funcionales + hooks. Jamás clases.
- `any` prohibido. Usar `unknown` + narrowing.
- Layouts con Flexbox. No estilos inline (usar `StyleSheet.create`).
- Platform-specific code explícito: `Platform.select` o archivos `.ios.ts`/`.android.ts`.
- Assets optimizados (imágenes, fonts) antes de commitear.
- Accesibilidad básica (accessibilityLabel, accessibilityRole) en controles interactivos.

### Comandos típicos

```bash
# Instalación inicial
pnpm install
cd ios && pod install && cd ..       # bare RN — no necesario en Expo managed

# Dev
pnpm start                           # Metro bundler
pnpm ios                             # corre en simulador iOS
pnpm android                         # corre en simulador/device Android

# iOS nativo
xcrun simctl list devices            # listar simuladores
xcrun simctl boot "iPhone 15 Pro"

# Android nativo
adb devices                          # listar dispositivos
./gradlew assembleDebug              # desde android/

# Build release
cd ios && xcodebuild -workspace ... archive    # o usar fastlane
cd android && ./gradlew bundleRelease

# Tests
pnpm test                            # Jest
pnpm test:e2e                        # Detox (si aplica)
```

### Qué NO tocar

- `ios/Pods/**` — dependencias CocoaPods. Regeneradas con `pod install`.
- `android/build/**`, `android/.gradle/**` — artefactos de build.
- `*.ipa`, `*.apk`, `*.aab` — binarios distribuibles.
- `node_modules/**`.
- `.env*` — configs sensibles.

### Debugging

- React DevTools standalone para inspección de componentes.
- Flipper para network + storage + layout (legacy — puede no funcionar con RN 0.76+).
- Xcode debugger para código nativo iOS.
- Android Studio logcat para código nativo Android.

### Plataformas: cuándo divergir

- UX por defecto: `Platform.select({ ios: {...}, android: {...} })` en el componente.
- Componentes enteros con diferencias grandes: archivos `MyComponent.ios.tsx` + `MyComponent.android.tsx`.
- Evitar duplicación innecesaria — la mayoría del código debe ser compartido.

### Contexto del proyecto

<!-- Edita esta sección al aplicar el perfil -->

- **Nombre del proyecto:** TODO
- **Qué hace:** TODO
- **Tipo:** Expo managed / bare React Native
- **Versión RN:** TODO
- **Plataformas target:** iOS 15+ / Android 7+ (ajustar)
- **Distribución:** App Store / Play Store / internal (TestFlight/Firebase)
