# Notas para la revisión de Apple (1.0.5)

Pegar en App Store Connect → versión 1.0.5 → «Información para la revisión de la app» → **Notas**.
Rellenar antes la cuenta de prueba (`[CORREO]` / `[CONTRASEÑA]`) y el enlace al vídeo (`[ENLACE AL VÍDEO]`).

---

Hello, thank you for reviewing Gasolineras de Canarias. Here is the information you requested.

1. SCREEN RECORDING
Attached to this App Review Information section. Recorded on a physical iPhone running the latest iOS. It starts at app launch and shows: the first-launch guide, login with Sign in with Apple, the list and map of stations sorted by price, station details and directions, adding a favorite, the profile and account deletion.

2. PURPOSE AND AUDIENCE
Gasolineras de Canarias helps drivers in the Canary Islands (Spain) find the cheapest fuel near them. It shows every petrol station in the islands on a map and in a list, with up-to-date prices for each fuel type, so users can compare stations and save money. Optionally, users can create an account to save favorite stations and receive a notification when the price drops at one of them.

3. HOW TO USE THE APP
- No login is needed for the main features. On first launch a short guide explains the app; then allow location access to see nearby stations (the app still works without it).
- "Gasolineras" tab: stations near you, in a list sorted by price for the selected fuel or on a map. On the map, nearby stations are grouped and expand when tapped.
- Station details: prices for each fuel, address, a fuel cost calculator and a directions button.
- Favorites and price-drop notifications require an account ("Perfil" tab → log in or register, or Sign in with Apple). Once logged in, the "Favoritos" tab appears.
- Account deletion: "Perfil" tab → "Eliminar cuenta" → confirm. It deletes the account and all its data immediately.
Demo account: see the Sign-In Information fields (email and password login).

The app has no user-generated content visible to other users (favorites and profile data are private to each user), no paid content and no in-app purchases.

4. EXTERNAL SERVICES
- Fuel prices: public open data from the Spanish Ministry for the Ecological Transition (Geoportal de Gasolineras), obtained through the precioil.es API.
- Supabase: user accounts, authentication and storage of favorites and profile.
- Sign in with Apple: optional login.
- Firebase Cloud Messaging (with APNs): price-drop push notifications.
- Google Maps SDK and Directions API: map and routes.

5. REGIONAL DIFFERENCES
The app covers petrol stations in the Canary Islands only and is distributed in Spain only. It works the same way everywhere; there are no region-specific features.

6. REGULATED INDUSTRY / THIRD-PARTY MATERIAL
Not applicable. The app does not sell fuel or process payments; it only displays public price data published by the Spanish government as open data.

Thank you.
