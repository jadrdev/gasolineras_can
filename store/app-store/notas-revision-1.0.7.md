# Notas para la revisión de Apple (1.0.7)

Pegadas en App Store Connect → versión 1.0.7 → Información para la revisión → Notas (16/11/2026).

---

Hello, thank you for reviewing this update of Gasolineras de Canarias.

WHAT'S NEW IN 1.0.7
- Charging points for electric and plug-in hybrid cars: in the "Gasolineras" tab, open the fuel selector ("95") and choose "Electrico". The list, map and detail then show charging points in the Canary Islands with connectors, power and an indicative price per kWh. The data comes from Open Charge Map (CC BY 4.0), downloaded daily by our server; the attribution is shown in the list, map and detail.
- "Invitame a un cafe" (Buy me a coffee), in the "Perfil" tab, also without logging in: three consumable in-app purchases (propina_cafe, propina_cafe_dulce, propina_desayuno) as voluntary tips. As a thank-you they unlock alternative app icons (Original, Night, Orange, Coffee) and a supporter badge. No app feature is locked behind them.

1. SCREEN RECORDING
A screen recording on a physical iPhone was attached to the review of version 1.0.5, which was approved. The existing user flows (first-launch guide, Sign in with Apple, list and map, station details, favourites, profile and account deletion) have not changed.

2. PURPOSE AND AUDIENCE
Gasolineras de Canarias helps drivers in the Canary Islands (Spain), including visitors with a hire car, find the cheapest fuel near them, and now also the cheapest places to charge an electric car. The app is available in Spanish, English and German.

3. HOW TO USE THE APP
- No login is needed for the main features. Allow location access to see nearby stations (the app still works without it).
- "Gasolineras" tab: stations near you, in a list sorted by price or on a map; choose "Electrico" for charging points.
- Station details: prices, address, a cost calculator and a directions button.
- Favourites and price-drop notifications require an account ("Perfil" tab, log in or register, or Sign in with Apple).
- Account deletion: "Perfil" tab, "Eliminar cuenta", confirm.
Demo account: see the Sign-In Information fields.

The app has no user-generated content visible to other users and no paid content: the only in-app purchases are the optional tips described above.

4. EXTERNAL SERVICES
- Fuel prices: public open data from the Spanish Ministry for the Ecological Transition, through the precioil.es API.
- Charging points: Open Charge Map API.
- Supabase: accounts, authentication, favourites and profile.
- Sign in with Apple: optional login.
- Apple In-App Purchase: optional tips.
- Firebase Cloud Messaging (with APNs): price-drop notifications.
- Google Maps SDK and Directions API: map and routes.

5. REGIONAL DIFFERENCES
The app covers the Canary Islands only and is distributed in Spain only. It works the same way everywhere.

6. REGULATED INDUSTRY
Not applicable: the app only displays public price data and community-provided charging data.

Thank you.
