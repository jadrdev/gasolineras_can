# Textos de la 1.0.9

La 1.0.9 (build 25) no trae nada nuevo a la vista. Es la primera compilada con Flutter 3.50:

- Material y Cupertino desde `material_ui` / `cupertino_ui` (google_fonts 9, go_router 18).
- Android con Gradle 9.5, AGP 9.3.1 y Kotlin 2.4.20 (Gradle arranca con Java 21). El `.env` entra en el APK/AAB gracias a `ignoreAssetsPattern`.
- iOS con Swift Package Manager (Google Maps sigue con CocoaPods).

Probada en el simulador de iOS y en un Xiaomi con Android 13 (lista, ficha, mapa, propinas y `gasocan://app/electricos`).

## Novedades de la versión

Apple no acepta emojis en las novedades.

- **es:** `Mejoras de estabilidad y rendimiento.`
- **en:** `Stability and performance improvements.`
- **de:** `Verbesserungen bei Stabilität und Leistung.`

**Google Play**
```
<es-ES>
Mejoras de estabilidad y rendimiento.
</es-ES>
<en-GB>
Stability and performance improvements.
</en-GB>
<de-DE>
Verbesserungen bei Stabilität und Leistung.
</de-DE>
```

Nombre, subtítulo, palabras clave y capturas: los mismos de la 1.0.8 (`store/textos-1.0.8.md`).

## Estado

- **App Store:** build 25 subida el 18/11.
- **Google Play:** AAB 1.0.9 (25) en `build/app/outputs/bundle/release/app-release.aab`.
