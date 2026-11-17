# Textos de la 1.0.8 (visibilidad en las tiendas)

La 1.0.8 no trae nada nuevo a la vista. Lo que cambia es para que la app salga más en las búsquedas:

- **Petición de valoración** (`lib/core/valoracion.dart`): la ventanita oficial de Apple y Google («¿Te gusta GasoCan?»). Sale como pronto a los 3 días del primer uso, después de abrir la ruta 3 veces o de usar la app 5 días distintos, y como mucho una vez cada 120 días. Si se cumple tras abrir la ruta, sale al volver a la app, no al irse al mapa. Además las tiendas limitan cuántas veces se enseña (Apple, 3 al año).
- **Nombre, subtítulo y palabras clave nuevos.** Ahora la búsqueda «GasoCan» no encuentra la app: la marca no estaba en el nombre ni en las palabras clave. Tampoco salía por «cargador» o «recarga».

En el App Store, el nombre, el subtítulo y las palabras clave solo cambian con una versión nueva: se meten al preparar la 1.0.8. En Google Play se pueden cambiar cuando quieras.

## Reglas de Apple que se han seguido

- Las palabras del nombre y del subtítulo ya cuentan para la búsqueda: no se repiten en las palabras clave (ahora se repetían «precio» y «combustible»).
- Palabras clave separadas por comas y sin espacios, 100 caracteres como máximo.
- Apple combina las palabras entre sí: con «gasoil» en las palabras clave y «Canarias» en el nombre, ya sale por «gasoil Canarias».

## App Store

| Campo | Ahora | 1.0.8 |
|---|---|---|
| **Nombre (30)** | Gasolineras de Canarias | `GasoCan: Gasolineras Canarias` (29) |
| **Subtítulo (30)** | Precios de combustible al día | `Gasolina barata y cargadores` (28) |
| **Palabras clave (100)** | gasolina,diésel,precio,combustible,Tenerife,Gran Canaria,Lanzarote,Fuerteventura,repostar,ahorro | `gasoil,diesel,precio,combustible,Tenerife,Gran Canaria,Lanzarote,Fuerteventura,recarga,eléctrico` (96) |

**English (UK)**

- Name: `GasoCan: Canary Fuel Prices` (27)
- Subtitle: `Cheap petrol and EV chargers` (28)
- Keywords: `petrol,diesel,fuel,station,islands,tenerife,gran canaria,lanzarote,fuerteventura,charging,ev` (92)

**Deutsch**

- Name: `GasoCan: Spritpreise Kanaren` (28)
- Untertitel: `Günstig tanken und laden` (24)
- Schlüsselwörter: `tankstelle,benzin,diesel,sprit,teneriffa,gran canaria,lanzarote,fuerteventura,ladestation,e-auto` (95)

Nombre y subtítulo están en **Información de la app** (arriba a la derecha se cambia el idioma). Las palabras clave están en la página de la versión 1.0.8.

## Google Play

En Play cuentan el título, la descripción breve y la descripción completa, y se pueden cambiar ya sin esperar a la 1.0.8.

- **Título (30):** `GasoCan: Gasolineras Canarias`
- **Descripción breve (80):** `Gasolina y gasoil más baratos de Canarias, puntos de recarga y avisos de precio` (79)
**Hecho el 17/11 (es-ES):** título y descripción breve cambiados y enviados a revisión. Antes eran «Gasolineras de Canarias» y «La gasolina más barata de Canarias: precios, mapa y avisos de bajada». El mismo día se cambiaron también en-GB y de-DE (los 6 cambios fueron juntos a revisión):

- **en-GB:** `GasoCan: Canary Fuel Prices` / `Cheapest petrol and diesel in the Canary Islands, EV chargers and price alerts` (antes «Canary Islands Fuel Prices»)
- **de-DE:** `GasoCan: Spritpreise Kanaren` / `Günstig tanken auf den Kanaren: Spritpreise, Ladestationen und Preisalarme` (antes «Spritpreise Kanaren»)

- **Descripción completa:** que salgan de forma natural «gasolina barata», «gasoil», el nombre de cada isla y «puntos de recarga». No repetir palabras en lista: Google lo penaliza.

## Novedades de la versión

Apple no acepta emojis en las novedades.

- **es:** `Mejoras de rendimiento y pequeños ajustes.`
- **en:** `Performance improvements and small tweaks.`
- **de:** `Leistungsverbesserungen und kleine Anpassungen.`

## Después de publicar

- **Eventos dentro de la app** (App Store Connect → Eventos dentro de la app): son tarjetas gratis que salen en la tienda y en la búsqueda. Por ejemplo, «Puntos de recarga en Canarias».
- **Responder a las reseñas** que lleguen, en las dos tiendas.
- Mirar en un mes en Análisis → Adquisición si suben las impresiones (82 en iOS hasta el 15/11).

## Estado (17/11)

**Enviada a revisión en las dos tiendas el 17/11** (Apple: «Pendiente de revisión»; Play: lanzamiento completo en producción). La ficha de Play con el título nuevo ya estaba publicada ese mismo día.


- **App Store:** versión 1.0.8 creada con la compilación 23, nombre y subtítulo nuevos (Información de la app) y novedades y palabras clave en es, en-GB y de. Guardada **sin enviar a revisión**.
- **Google Play:** AAB 1.0.8 (23) subido a Producción (arrastrado a mano: 60 MB) con notas en es-ES, en-GB y de-DE. Guardada **sin enviar a revisión** (Resumen de publicación → Enviar cambios a revisión).
