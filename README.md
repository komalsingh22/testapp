# Weather Forecast App (OpenWeatherMap)

Clean-architecture Flutter app with:
- City search with autocomplete
- Current weather
- 5-day forecast (min/max)
- Favorites (local storage)
- Error handling and loading states

## 1) Setup

1. Install Flutter and set up devices.
2. Get a free API key from OpenWeatherMap.
3. Open `lib/services/constants.dart` and set `openWeatherApiKey`.
4. Install dependencies:

```bash
flutter pub get
```

## 2) Run

```bash
flutter run
```

## 3) Project Structure

- `lib/models/` — Plain models (`Weather`, `Forecast`, etc.)
- `lib/services/` — `ApiService`, `AppConstants`
- `lib/providers/` — Riverpod providers for API, selection, favorites, data
- `lib/screens/` — `SearchScreen`, `WeatherScreen`

## 4) Features

- Search cities via OpenWeatherMap Geocoding API (autocomplete)
- Current weather: temp, feels-like, humidity, wind, description
- 5-day forecast: grouped by day with min/max and icon
- Save favorite cities using `shared_preferences`
- Robust errors and loading indicators

## 5) Notes

- Units are metric by default. Change in `AppConstants.units`.
- If images don’t load on some platforms, ensure network permissions are enabled by Flutter defaults.

