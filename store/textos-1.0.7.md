# Textos de la 1.0.7

La 1.0.7 trae **puntos de recarga para eléctricos e híbridos enchufables** e **«Invítame a un café»** (propinas con iconos alternativos de regalo).

## Novedades de la versión

App Store («Novedades en esta versión») y Google Play (notas de la versión, con las etiquetas de idioma).

> **Apple no acepta emojis** en las novedades («Este campo contiene uno o más caracteres no válidos»): en el App Store se pusieron sin ⚡ ni ☕ y con una línea en blanco entre los dos párrafos (16/11). En Google Play sí valen.

**Español**
```
⚡ Nuevo: puntos de recarga para coches eléctricos e híbridos enchufables. Elige «Eléctrico» en el selector de combustible y verás los cargadores de Canarias ordenados por precio, con conectores, potencia y cómo llegar.
☕ Invítame a un café: si GasoCan te ahorra dinero, ahora puedes apoyarla. Como agradecimiento, podrás cambiar el icono de la app.
```

**English (UK)**
```
⚡ New: charging points for electric and plug-in hybrid cars. Choose "Electric" in the fuel selector to see chargers across the Canary Islands sorted by price, with connectors, power and directions.
☕ Buy me a coffee: if GasoCan saves you money, you can now support it. As a thank-you, you can change the app icon.
```

**Deutsch**
```
⚡ Neu: Ladestationen für Elektroautos und Plug-in-Hybride. Wähle „Elektro“ in der Kraftstoffauswahl und sieh die Ladestationen der Kanaren nach Preis sortiert, mit Anschlüssen, Leistung und Route.
☕ Spendier mir einen Kaffee: Wenn GasoCan dir Geld spart, kannst du die App jetzt unterstützen. Als Dankeschön kannst du das App-Symbol ändern.
```

**Google Play (todo junto)**
```
<es-ES>
⚡ Nuevo: puntos de recarga para coches eléctricos e híbridos enchufables, ordenados por precio. Elige «Eléctrico» en el selector de combustible.
☕ Invítame a un café: apoya la app y cambia su icono como agradecimiento.
</es-ES>
<en-GB>
⚡ New: charging points for electric and plug-in hybrid cars, sorted by price. Choose "Electric" in the fuel selector.
☕ Buy me a coffee: support the app and change its icon as a thank-you.
</en-GB>
<de-DE>
⚡ Neu: Ladestationen für Elektroautos und Plug-in-Hybride, nach Preis sortiert. Wähle „Elektro“ in der Kraftstoffauswahl.
☕ Spendier mir einen Kaffee: Unterstütze die App und ändere als Dankeschön ihr Symbol.
</de-DE>
```

## Añadir a la descripción de las fichas

Una viñeta nueva en «Qué puedes hacer», detrás de «Tu combustible»:

- **es:** `• Coches eléctricos: puntos de recarga de toda Canarias con precio por kWh, conectores y potencia. Datos de Open Charge Map.`
- **en:** `• Electric cars: charging points across the Canary Islands with price per kWh, connectors and power. Data from Open Charge Map.`
- **de:** `• Elektroautos: Ladestationen auf allen Kanarischen Inseln mit Preis pro kWh, Anschlüssen und Leistung. Daten von Open Charge Map.`

Y al final, antes de «De dónde salen los precios»:

- **es:** `GasoCan es gratis y sin anuncios. Si te ahorra dinero, puedes invitarme a un café desde el perfil.`
- **en:** `GasoCan is free and ad-free. If it saves you money, you can buy me a coffee from your profile.`
- **de:** `GasoCan ist kostenlos und werbefrei. Wenn die App dir Geld spart, kannst du mir im Profil einen Kaffee spendieren.`

En «De dónde salen los precios» añadir: «Los precios de recarga los aporta la comunidad de Open Charge Map y son orientativos.» (en: «Charging prices are provided by the Open Charge Map community and are indicative.»; de: «Ladepreise stammen von der Open-Charge-Map-Community und sind Richtwerte.»)

## Palabras clave (App Store)

Si caben, cambiar alguna por: `cargador`, `eléctrico`, `recarga` (es) · `ev charger`, `electric` (en) · `ladestation`, `elektroauto` (de). El límite es 100 caracteres.

## Antes de enviar

1. La 1.0.6 tiene que estar **publicada** en las dos tiendas (Apple no deja tener dos versiones en revisión; en Play un envío nuevo reinicia la revisión en curso).
2. **Propinas:** acuerdo de pago de Apple activo, perfil de pagos en Google y los tres productos creados (ver `store/propinas.md`). En Apple, las tres compras se añaden a la versión 1.0.7 al enviarla.
3. Probar en TestFlight y en el Android: ⚡ Eléctrico con ubicación, la calculadora de un punto de pago, el cambio de icono en Android y una propina en modo prueba.

## Hecho en App Store Connect (16/11)

Versión 1.0.7 creada con el build 22, novedades en es/en/de (sin emojis), descripción con la viñeta de eléctricos y la frase del café en los tres idiomas, texto promocional nuevo (no se copió de la 1.0.6) y notas de revisión en `store/app-store/notas-revision-1.0.7.md`. Publicación automática. **Sin enviar**: faltan las compras dentro de la app.
