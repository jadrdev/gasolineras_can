# «Invítame a un café»: propinas en la app

Tarjeta en el perfil (con y sin sesión) que abre una hoja con tres propinas de pago único. Son productos **consumibles**: se pueden repetir. Código en `lib/features/propinas/`.

**Agradecimiento:** cualquier propina convierte al usuario en *colaborador*: insignia «☕ Colaborador» en el perfil y puede cambiar el **icono de la app** (Original, Noche, Naranja, Café). Se guarda en el móvil y, con sesión, en `users.colaborador` (`supabase/colaborador.sql`, hay que aplicarlo antes de publicar la 1.0.7).

- Iconos: `assets/icon/alternativos/` (vista previa), `ios/Runner/Assets.xcassets/AppIcon-{Noche,Naranja,Cafe}` (build setting `ASSETCATALOG_COMPILER_ALTERNATE_APPICON_NAMES`) y en Android `mipmap-*/ic_launcher_{noche,naranja,cafe}` con un `activity-alias` por icono en el manifiesto (`MainActivity.cambiarIcono`).
- En iOS el sistema avisa «Has cambiado el icono para GasoCan». En Android el lanzador puede tardar unos segundos en actualizarlo.

| ID de producto | Nombre (es / en / de) | Precio |
|---|---|---|
| `propina_cafe` | Un café / A coffee / Ein Kaffee | 1,99 € |
| `propina_cafe_dulce` | Café con dulce / Coffee and cake / Kaffee und Kuchen | 3,99 € |
| `propina_desayuno` | Un desayuno / A breakfast / Ein Frühstück | 6,99 € |

Los ID tienen que ser **exactamente** estos en las dos tiendas. Mientras no existan, la hoja dice «Las propinas no están disponibles ahora mismo».

## Antes de nada

- **Apple:** el *Acuerdo para apps de pago* tiene que estar **Activo** (Negocio → Acuerdos). El 12/11 estaba en «Información del usuario pendiente»: faltaba un formulario fiscal y la cuenta del BBVA estaba en proceso.
- **Google:** hace falta un **perfil de pagos** (cuenta de comerciante) vinculado a la cuenta de desarrollador: Play Console → Configuración → Perfil de pagos.

## App Store Connect

1. Apps → Gasolineras de Canarias → **Monetización → Compras dentro de la app** → «+» → **Consumible**.
2. Para cada fila de la tabla: nombre de referencia (p. ej. «Propina café»), ID de producto, precio (España y resto en automático) y localizaciones en español, inglés (Reino Unido) y alemán con el nombre de la tabla y una descripción corta («Invita a un café al desarrollador»).
3. **Información para la revisión:** una captura de la hoja de propinas (1206×2622 vale) y la nota «Voluntary tip. As a thank-you it unlocks alternative app icons and a supporter badge; no features are locked.»
4. La **primera** compra dentro de la app se envía **junto con una versión** (la 1.0.7). La página de la versión ya no tiene sección para elegirlas: se pulsa «Añadir a revisión» en cada compra (las mete en el borrador de envío, no envía nada) y luego se envía la versión, que se las lleva.

**Hecho el 16/11:** las tres creadas como consumibles (`propina_cafe` 1,99 €, `propina_cafe_dulce` 3,99 €, `propina_desayuno` 6,99 €; base España, 175 países), con nombre y descripción en es-ES, en-GB y de-DE, captura `store/app-store/propinas-revision.png` y la nota de revisión. Enviadas a revisión junto con la 1.0.7 (build 22) el 16/11.

## Google Play Console

1. Primero hay que subir un AAB que lleve la librería de pagos (la 1.0.7), aunque sea a pruebas internas: si no, Play no deja crear productos.
2. **Monetizar con Play → Productos → Productos únicos** → Crear producto, con el ID, nombre, descripción y precio de la tabla. Añadir traducciones en-GB y de-DE.
3. Activar los tres productos.

**Hecho el 16/11:** AAB 1.0.7 (22) subido a Producción y enviado a revisión; las tres propinas creadas y activas (opción de compra `compra`, es/en-GB/de-DE). Ojo: el precio en bloque suma el IVA (1,99 → 2,39 €), así que el de España se corrigió a mano a 1,99 / 3,99 / 6,99 €; la app solo se publica en España.

## Privacidad

No guardamos nada de las compras (las gestiona la tienda), así que no cambia la declaración de privacidad de Apple ni la sección «Seguridad de los datos» de Play.

## Probar

- **Simulador, desde Xcode:** `ios/Runner/Propinas.storekit` tiene los tres productos y está enlazado al esquema Runner. Abrir `ios/Runner.xcworkspace`, ▶︎ Run, Perfil → «Invítame a un café». El pago es simulado. (Con `flutter run` no se carga este archivo y la hoja dice «no disponibles».) La ruta del esquema es `../Runner/Propinas.storekit`; con `../../` Xcode no lo encontraba y tiraba del sandbox real.
- **iPhone de verdad:** con un usuario de pruebas *sandbox* (App Store Connect → Usuarios y acceso → Sandbox) cuando los productos estén creados.
- **Android:** con una cuenta de *tester de licencias* (Play Console → Configuración → Pruebas de licencias) y la app instalada desde pruebas internas.
