---
paths:
  - "ios/**/*"
  - "android/**/*"
  - "src/**/NativeModules/**/*"
  - "modules/**/*"
---

# Código nativo (iOS + Android)

Se carga al tocar archivos nativos o wrappers de native modules.

## Cuándo tocar código nativo

Primero: **¿se puede resolver con JS?** La respuesta suele ser sí. Tocar nativo implica:
- Dos implementaciones a mantener.
- Tests más complejos.
- Riesgo mayor de crashes no capturados.

Tocar solo si:
1. La API nativa no está expuesta por React Native ni por una lib madura de la comunidad.
2. Performance: algo pesado que no puede cruzar el bridge constantemente.
3. Integración con SDK de terceros que requieren código nativo.

## Antes de implementar uno propio

Buscar en:
- [reactnative.directory](https://reactnative.directory)
- npm con tag `react-native`
- Expo modules (si bare pero se podría migrar).

Una lib mantenida con 10k+ stars es casi siempre mejor que escribir uno propio.

## iOS (Swift/Objective-C)

- Preferir Swift sobre Objective-C en módulos nuevos (mejor error handling, tipos más claros).
- Bridging header si hay que interoperar con código Obj-C existente.
- CocoaPods para dependencias. `pod install` después de cada cambio en `Podfile`.
- Info.plist: permissions necesarios (camera, microphone, location, etc.) con mensajes claros al usuario.

## Android (Kotlin/Java)

- Preferir Kotlin sobre Java.
- `AndroidManifest.xml`: permissions y activities registradas.
- Runtime permissions (API 23+) con flujo explícito.
- ProGuard/R8 rules si obfuscation rompe reflection (reflection es frecuente en RN native modules).

## Registrar un native module

### iOS (Swift)

```swift
@objc(MiModulo)
class MiModulo: NSObject {
  @objc
  func hacerAlgo(_ arg: String, resolver resolve: @escaping RCTPromiseResolveBlock,
                 rejecter reject: @escaping RCTPromiseRejectBlock) {
    // ...
  }
  @objc static func requiresMainQueueSetup() -> Bool { return false }
}
```

### Android (Kotlin)

```kotlin
class MiModuloModule(reactContext: ReactApplicationContext) : ReactContextBaseJavaModule(reactContext) {
  override fun getName() = "MiModulo"

  @ReactMethod
  fun hacerAlgo(arg: String, promise: Promise) {
    // ...
  }
}
```

Registrar en `MainApplication.kt` (Android) o autolink en RN 0.60+ (iOS suele ser automático).

## Threading

- iOS: UI operations en main queue (`DispatchQueue.main.async`).
- Android: UI operations en UI thread (`runOnUiThread`).
- Operaciones pesadas → background queues / coroutines.

## Error handling

- Nunca crashear. Rejection del promise con código descriptivo.
- Loggear en el lado nativo para debugging.
- Documentar códigos de error esperables.

## Testing

- Unit tests del código nativo (XCTest iOS, JUnit Android).
- Integration tests desde JS con el módulo instalado.
- Detox para E2E que cruzan el bridge.

## Builds

- **Limpiar después de cambios profundos:** `cd ios && pod deintegrate && pod install` / `cd android && ./gradlew clean`.
- Para cambios en deps nativas, Metro cache a veces queda desincronizado → `pnpm start --reset-cache`.
