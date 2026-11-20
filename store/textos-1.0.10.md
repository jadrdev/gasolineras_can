# Textos de la 1.0.10

La 1.0.10 (build 27) trae los puntos de carga de Red Eléctrica:

- Datos oficiales de mapaREVE (Red Eléctrica de España), actualizados cada 15 minutos: precio publicado por cada operador para la franja horaria y la potencia de cada conector, y cargadores libres, ocupados o averiados. Open Charge Map completa los puntos que no están en REVE.
- Botón ⚡/⛽ arriba, junto a la ubicación, para pasar de gasolineras a puntos de carga y volver.
- En iPhone, la barra de abajo con las medidas de las apps de Apple (cápsula de iOS 26; barra clásica en iOS anteriores).
- iPhone Duo: cerrado, la barra va en la franja de la cámara como el dock; abierto, la app llena la pantalla (sin `UIRequiresFullScreen`, con horizontal) y muestra lista y ficha a la vez. Capturas en `store/app-store/iphone-duo/`.

Servidor: función `charging-stations` y tabla `charging_stations` en producción desde el 20/11 (ver `supabase/puntos_recarga_reve.sql`). Las versiones anteriores siguen con `charging_points`.

## Novedades de la versión

Apple no acepta emojis en las novedades.

- **es:** `Puntos de carga con datos oficiales de Red Eléctrica: precio de cada operador y si los cargadores están libres, ocupados o averiados. Nuevo botón arriba para pasar de gasolineras a puntos de carga con un toque. En iPhone, barra de abajo renovada. Adaptada al iPhone Duo: abierto, ves la lista y la ficha a la vez.`
- **en:** `Charging points with official data from Red Eléctrica: each operator's price and whether chargers are free, in use or out of order. New button at the top to switch between petrol stations and charging points with one tap. On iPhone, a refreshed bottom bar. Ready for iPhone Duo: unfolded, you see the list and the details side by side.`
- **de:** `Ladepunkte mit offiziellen Daten von Red Eléctrica: Preis jedes Betreibers und ob die Ladesäulen frei, belegt oder defekt sind. Neue Taste oben, um mit einem Tipp zwischen Tankstellen und Ladepunkten zu wechseln. Auf dem iPhone eine überarbeitete untere Leiste. Angepasst an das iPhone Duo: aufgeklappt siehst du Liste und Details nebeneinander.`

**Google Play**
```
<es-ES>
Puntos de carga con datos oficiales de Red Eléctrica: precio de cada operador y si los cargadores están libres, ocupados o averiados. Nuevo botón arriba para pasar de gasolineras a puntos de carga con un toque. En iPhone, barra de abajo renovada. En pantallas grandes y plegables, la lista y la ficha a la vez.
</es-ES>
<en-GB>
Charging points with official data from Red Eléctrica: each operator's price and whether chargers are free, in use or out of order. New button at the top to switch between petrol stations and charging points with one tap. On iPhone, a refreshed bottom bar. On large and foldable screens, the list and the details side by side.
</en-GB>
<de-DE>
Ladepunkte mit offiziellen Daten von Red Eléctrica: Preis jedes Betreibers und ob die Ladesäulen frei, belegt oder defekt sind. Neue Taste oben, um mit einem Tipp zwischen Tankstellen und Ladepunkten zu wechseln. Auf dem iPhone eine überarbeitete untere Leiste. Auf großen und faltbaren Bildschirmen Liste und Details nebeneinander.
</de-DE>
```

## Descripción (App Store; cambian dos frases)

En la viñeta de coches eléctricos:
- **es:** `• Coches eléctricos: puntos de recarga de toda Canarias con precio por kWh, conectores, potencia y si están libres u ocupados. Datos de Red Eléctrica (mapaREVE) y Open Charge Map.`
- **en:** `• Electric cars: charging points across the Canary Islands with price per kWh, connectors, power and whether they are free or in use. Data from Red Eléctrica (mapaREVE) and Open Charge Map.`
- **de:** `• Elektroautos: Ladestationen auf allen Kanarischen Inseln mit Preis pro kWh, Anschlüssen, Leistung und ob sie frei oder belegt sind. Daten von Red Eléctrica (mapaREVE) und Open Charge Map.`

En «De dónde salen los precios»:
- **es:** `Los precios de recarga son los que publica cada operador en Red Eléctrica (mapaREVE); donde no los hay, los aporta la comunidad de Open Charge Map y son orientativos.`
- **en:** `Charging prices are those published by each operator on Red Eléctrica (mapaREVE); where there are none, they are provided by the Open Charge Map community and are indicative.`
- **de:** `Ladepreise sind die, die jeder Betreiber bei Red Eléctrica (mapaREVE) veröffentlicht; wo es keine gibt, stammen sie von der Open-Charge-Map-Community und sind Richtwerte.`

La nota para el revisor de Apple explica el botón nuevo (antes decía «selector de combustible → Electrico») y las dos fuentes.

Nombre, subtítulo, palabras clave y capturas: los mismos de la 1.0.8 (`store/textos-1.0.8.md`).

## Estado

- **App Store:** build 26 subida el 20/11 (procesándose); versión 1.0.10 creada con novedades, descripción y nota para el revisor en es/en-GB/de. **Sin enviar a revisión.**
- **Google Play:** AAB 1.0.10 (26) compilado el 20/11 (`build/app/outputs/bundle/release/app-release.aab`, 62,5 MB, con `.env`). Falta subirlo a Producción con las notas.
