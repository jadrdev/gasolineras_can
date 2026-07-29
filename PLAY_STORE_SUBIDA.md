# GasoCan - Guía de subida a Google Play Console

> Proyecto Flutter: `gasolineras_can`  
> Application ID: `com.jadrdev.gasolinera`  
> Fecha de preparación: 2026-07-27  
> Versión de compilación actual: `1.0.1+2`

---

## Situación actual

Se perdió el keystore anterior de subida (`upload-keystore.jks`) y el certificado PEM no era válido. La aplicación **ya está publicada en Google Play Console con Play App Signing activado**, por lo que solo era necesario generar un **nuevo upload key** y solicitar a Google su actualización.

### Resultado

- Nuevo keystore generado: `android/app/upload-keystore.jks`
- Certificado público generado: `android/app/upload_certificate.pem`
- `android/key.properties` actualizado con las nuevas credenciales.
- `pubspec.yaml` actualizado a `version: 1.0.1+2`.
- NDK reinstalado para solucionar el error de strip de símbolos nativos.
- App Bundle release compilado correctamente:
  - Ruta: `build/app/outputs/bundle/release/app-release.aab`
  - Tamaño: ~66,2 MB
- Firma verificada con el nuevo certificado.

### SHA1 del nuevo certificado de subida

```text
3F:D1:44:D2:44:CD:C1:51:39:7D:19:C7:4C:D2:AC:F0:04:9E:B9:08
```

---

## Archivos críticos generados

| Archivo | Descripción | ¿Subir a Git? |
|---|---|---|
| `android/app/upload-keystore.jks` | Keystore privado de subida. Firma el AAB. | **NO** |
| `android/key.properties` | Contraseñas y ruta del keystore. | **NO** |
| `keystore_credentials.txt` | Copia de seguridad de la contraseña. | **NO** |
| `android/app/upload_certificate.pem` | Certificado público para Play Console. | **NO** (público, pero mejor no) |
| `build/app/outputs/bundle/release/app-release.aab` | App Bundle listo para subir. | **NO** |

> **Importante:** guarda `upload-keystore.jks`, `key.properties` y la contraseña en un gestor de contraseñas o almacenamiento seguro. Si se vuelven a perder, no se podrán subir más actualizaciones.

---

## Pasos a seguir en Google Play Console

1. Entra en [Google Play Console](https://play.google.com/console).
2. Selecciona la aplicación `com.jadrdev.gasolinera`.
3. Ve a **Configuración > Firma de aplicaciones**.
4. Busca la sección **"Clave de carga de aplicaciones"** (Upload key).
5. Solicita **"Cambiar la clave de carga"** o **"Reset upload key"**.
6. Sube el archivo:
   ```
   android/app/upload_certificate.pem
   ```
7. Google revisará y aprobará el cambio (normalmente horas, ocasionalmente 1-2 días).
8. Una vez aprobado, sube el AAB generado:
   ```
   build/app/outputs/bundle/release/app-release.aab
   ```
9. Rellena la ficha de la versión (notas de lanzamiento, etc.).
10. Guarda y envía a revisión.

---

## Cómo compilar una nueva versión en el futuro

Cada subida a Play Console requiere un `versionCode` mayor.

1. Edita `pubspec.yaml` e incrementa el número tras el `+`:
   ```yaml
   version: 1.0.2+3
   ```
2. Ejecuta:
   ```bash
   flutter clean
   flutter pub get
   flutter build appbundle --release
   ```
3. El AAB estará en:
   ```
   build/app/outputs/bundle/release/app-release.aab
   ```

---

## Configuración del proyecto

### `pubspec.yaml`

```yaml
name: gasolineras_can
description: "A new Flutter project."
publish_to: 'none'
version: 1.0.1+2

environment:
  sdk: ^3.11.5

# ... dependencias ...
```

### `android/app/build.gradle.kts`

- Application ID: `com.jadrdev.gasolinera`
- SDK mínimo/target: gestionado por Flutter (`flutter.minSdkVersion`, `flutter.targetSdkVersion`)
- NDK: `28.2.13676358`
- Compilación: Java 17, Kotlin JVM target 17
- Minificación y shrink de recursos activados en release.
- Firma release cargada desde `android/key.properties`.

### `android/key.properties`

```properties
storeFile=../app/upload-keystore.jks
storePassword=***OCULTO***
keyAlias=upload
keyPassword=***OCULTO***
```

> No modificar a mano salvo que se vuelva a generar el keystore.

---

## Dependencias principales

- **Estado:** `flutter_bloc`, `equatable`
- **Backend/Auth:** `supabase_flutter`
- **Firebase:** `firebase_core`, `firebase_messaging`
- **Mapas/Ubicación:** `geolocator`, `google_maps_flutter`, `map_launcher`
- **Notificaciones:** `flutter_local_notifications`
- **Anuncios:** `google_mobile_ads`
- **UI/Utilidades:** `go_router`, `google_fonts`, `fl_chart`, `url_launcher`
- **Persistencia:** `drift`, `shared_preferences`

---

## Notas técnicas

- `enable-swift-package-manager: false` en `pubspec.yaml` para evitar conflictos con `google_mobile_ads` en iOS.
- `debugSymbolLevel = "none"` no está configurado; el NDK ya proporciona las herramientas necesarias.
- La clave de firma de la app (`app signing key`) sigue siendo la misma gestionada por Google. Solo cambia la **clave de carga**.

---

## Cambios recientes en el repositorio

- `.gitignore`: añadidas exclusiones para `keystore_credentials.txt` y `*.pem`.
- `pubspec.yaml`: `version` cambiada de `1.0.0+1` a `1.0.1+2`.
- `android/app/build.gradle.kts`: eliminada la configuración de strip/debug symbols manual que ya no era necesaria.

---

## Contacto / Responsable

Desarrollador: Joshua A. Díaz Robayna  
Empresa/Proyecto: jadrdev  
Ubicación certificado: Las Palmas, España

---

*Documento generado automáticamente el 2026-07-27.*
