# Notas para la revisión de Apple (1.0.6)

Pegadas en App Store Connect → versión 1.0.6 → «Información para la revisión de la app» → Notas (12/11/2026). El vídeo de la 1.0.5 no se conservó, así que se explica que se adjuntó en esa revisión.

---

Hello, thank you for reviewing this update of Gasolineras de Canarias.

WHAT'S NEW IN 1.0.6
The app is now available in Spanish, English and German, following the iPhone's language (Spanish for any other language). Price-drop push notifications are also sent in the language of the app on each device. To review the translations, set the iPhone language to English or German and open the app.

1. SCREEN RECORDING
A screen recording on a physical iPhone was attached to the review of version 1.0.5, which was approved. The user flows (first-launch guide, Sign in with Apple, list and map, station details, favourites, profile and account deletion) have not changed.

2. PURPOSE AND AUDIENCE
Gasolineras de Canarias helps drivers in the Canary Islands (Spain), including visitors with a hire car, find the cheapest fuel near them. It shows every petrol station in the islands on a map and in a list, with up-to-date prices for each fuel type. Optionally, users can create an account to save favourite stations and receive a notification when the price drops at one of them.

3. HOW TO USE THE APP
- No login is needed for the main features. Allow location access to see nearby stations (the app still works without it).
- "Gasolineras" tab: stations near you, in a list sorted by price or on a map.
- Station details: prices for each fuel, address, a fuel cost calculator and a directions button.
- Favourites and price-drop notifications require an account ("Perfil" tab, log in or register, or Sign in with Apple).
- Account deletion: "Perfil" tab, "Eliminar cuenta", confirm.
Demo account: see the Sign-In Information fields.

The app has no user-generated content visible to other users, no paid content and no in-app purchases.

4. EXTERNAL SERVICES
- Fuel prices: public open data from the Spanish Ministry for the Ecological Transition (Geoportal de Gasolineras), through the precioil.es API.
- Supabase: accounts, authentication, favourites and profile.
- Sign in with Apple: optional login.
- Firebase Cloud Messaging (with APNs): price-drop notifications.
- Google Maps SDK and Directions API: map and routes.

5. REGIONAL DIFFERENCES
The app covers the Canary Islands only and is distributed in Spain only. It works the same way everywhere.

6. REGULATED INDUSTRY
Not applicable: the app only displays public price data published by the Spanish government as open data.

Thank you.
