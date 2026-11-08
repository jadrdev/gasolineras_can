# GasoCan

Aplicación Flutter para comparar estaciones de servicio de Canarias, consultar precios por combustible y guardar favoritos.

## Desarrollo

Validación de esta revisión: Flutter 3.47.4 / Dart 3.13.3. iOS usa CocoaPods; la barra nativa requiere compilar con Xcode 26 o superior y mantiene compatibilidad con iOS 15+.

```sh
flutter pub get
flutter analyze
flutter test
flutter run
```

La configuración local existente usa `.env` para `SUPABASE_URL`, `SUPABASE_ANON_KEY` (clave pública) y `GOOGLE_MAPS_API_KEY`. Las claves privadas de servidor nunca deben distribuirse en ese recurso. Android también configura Maps mediante `MAPS_API_KEY` en `android/local.properties`.

## Búsqueda y precios

- La búsqueda usa el catálogo de Canarias, no solo las estaciones situadas en 16 km. Ignora tildes, mayúsculas, signos y espacios repetidos; combina palabras de nombre, marca, dirección, municipio, localidad y provincia.
- «Cerca de mí» limita la lista inicial a 16 km. Al escribir se busca en todo el archipiélago; un municipio seleccionado sigue siendo un filtro explícito. «Toda Canarias» permite explorar sin GPS.
- El campo de búsqueda permanece visible al cargar, al fallar la conexión y cuando no hay coincidencias.
- La consulta Precioil usa el centro 28.5/-15.8, radio 300 km y límite 2000. La API documenta que `pagina` se conserva por compatibilidad y no permite asumir paginación real; si se alcanza el límite se rechaza el catálogo incompleto.
- Se conserva una caché de diez minutos. Una actualización fallida muestra los datos guardados con aviso; no modifica su fecha. Los precios de más de 48 horas o sin fecha se señalan en la lista.
- Los precios unitarios muestran tres decimales; los totales monetarios conservan dos. Las distancias de la lista son en línea recta, no por carretera.
- El mapa recibe los resultados y el combustible de la lista, sin cambiar la zona ni lanzar otra descarga.

API: https://api.precioil.es/api-docs/

La app no espera a AdMob ni solicita notificaciones antes de dibujar la interfaz. Sin permiso de ubicación, se puede buscar manualmente y activar «Usar mi ubicación» cuando se necesite. El permiso de notificaciones se pide después de guardar un favorito.

## Perfil y favoritos

Los cambios del vehículo se guardan con un botón explícito, validación y confirmación solo tras éxito. La lista y los favoritos reciben los cambios de preferencias. Los errores al eliminar favoritos se propagan para restaurar la estrella.

Los favoritos se cruzan con el catálogo de Canarias sin depender del GPS y se actualizan mediante el stream de Supabase. Los cambios de cuenta reconstruyen las pantallas para no reutilizar información de otro usuario.

Las alertas locales siguen siendo comprobaciones con la app activa cada treinta minutos. Ahora consultan el catálogo completo, separan las instantáneas por usuario, conservan las estaciones temporalmente ausentes y no notifican con precios de la caché de respaldo. El envío con la app cerrada, los umbrales y el ahorro neto por carretera quedan para una fase posterior con backend y rutas.

## Diseño en iOS

`GlassNavigationView.swift` usa `UIGlassEffect` nativo en iOS 26+ mediante una platform view y un canal de Flutter. En iOS anteriores usa material translúcido de UIKit. Respeta reducción de transparencia, alto contraste, selección accesible y tema claro/oscuro. Android utiliza Material 3. No se añade `cupertino_native` ni un puente FFI para la barra.

La lista incorpora una cabecera compacta, acceso visible a Lista/Mapa y precio con estimación para los litros configurados. Sin GPS, la zona visible indica «Toda Canarias». La ficha prioriza el precio y «Cómo llegar», con el mapa más abajo y combustible seleccionado identificado por texto.

La barra es la superficie Liquid Glass; las tarjetas mantienen fondos legibles. Debe comprobarse en dispositivo la composición con Flutter, el teclado, VoiceOver, texto grande y las áreas seguras.

## Dependencias

Se actualizaron las versiones permitidas por los rangos actuales y se eliminaron dependencias directas sin uso (`drift`, `fl_chart`, `formz`, `mockito`, `url_launcher`). `url_launcher` puede seguir presente como dependencia transitiva. `bloc_test` pertenece ahora a desarrollo.

Las migraciones mayores de anuncios, mapas externos, notificaciones, router, dotenv y fuentes se mantienen separadas: requieren revisar sus cambios de API y requisitos nativos. Consultar `flutter pub outdated` para las versiones que continúan limitadas.

## Comprobación manual antes de publicar

- Buscar una estación fuera de los 16 km, una marca junto a su municipio y un nombre sin tildes.
- Escribir una búsqueda sin resultados y corregirla sin salir del campo.
- Denegar GPS, elegir municipio, abrir mapa y volver conservando la búsqueda.
- Actualizar sin conexión tras una primera carga y comprobar el aviso de caché.
- Guardar diésel en el perfil y abrir una favorita; simular un fallo al eliminarla.
- Comprobar la barra en iOS 26+, iOS anterior y Android, y probar cambios de sesión y tema.
