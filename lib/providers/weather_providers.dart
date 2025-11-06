import 'dart:convert';

import 'package:riverpod/riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test_app/models/forecast.dart';
import 'package:test_app/models/weather.dart';
import 'package:test_app/services/api_service.dart';

// Simple container for a selected location
class SelectedLocation {
  final String name;
  final double lat;
  final double lon;
  SelectedLocation({required this.name, required this.lat, required this.lon});

  Map<String, dynamic> toJson() => {"name": name, "lat": lat, "lon": lon};
  factory SelectedLocation.fromJson(Map<String, dynamic> json) => SelectedLocation(
        name: (json['name'] ?? '') as String,
        lat: (json['lat'] ?? 0).toDouble(),
        lon: (json['lon'] ?? 0).toDouble(),
      );
}

final apiServiceProvider = Provider<ApiService>((ref) => ApiService());

// Favorites management with shared_preferences
final favoritesProvider = NotifierProvider<FavoritesNotifier, List<SelectedLocation>>(
  FavoritesNotifier.new,
);

class FavoritesNotifier extends Notifier<List<SelectedLocation>> {
  FavoritesNotifier();

  static const _prefsKey = 'favorite_cities';

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_prefsKey) ?? [];
    state = raw
        .map((e) => SelectedLocation.fromJson(jsonDecode(e) as Map<String, dynamic>))
        .toList();
  }

  Future<void> add(SelectedLocation loc) async {
    if (state.any((e) => e.name == loc.name)) return;
    final updated = [...state, loc];
    state = updated;
    await _persist();
  }

  Future<void> remove(SelectedLocation loc) async {
    state = state.where((e) => e.name != loc.name).toList();
    await _persist();
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _prefsKey,
      state.map((e) => jsonEncode(e.toJson())).toList(),
    );
  }

  @override
  List<SelectedLocation> build() {
    // Initialize from storage asynchronously; start with empty, then load.
    // Fire and forget; UI will update after load completes.
    state = const [];
    load();
    return state;
  }
}

// Selected location provider using Notifier
final selectedLocationProvider = NotifierProvider<SelectedLocationNotifier, SelectedLocation?>(
  SelectedLocationNotifier.new,
);

class SelectedLocationNotifier extends Notifier<SelectedLocation?> {
  @override
  SelectedLocation? build() => null;

  void select(SelectedLocation value) {
    state = value;
  }

  void clear() {
    state = null;
  }
}

// Async weather and forecast providers depending on selectedLocation
final currentWeatherProvider = FutureProvider.autoDispose<Weather?>((ref) async {
  final loc = ref.watch(selectedLocationProvider);
  if (loc == null) return null;
  final api = ref.watch(apiServiceProvider);
  return api.fetchCurrentWeather(lat: loc.lat, lon: loc.lon);
});

final fiveDayForecastProvider = FutureProvider.autoDispose<Forecast?>((ref) async {
  final loc = ref.watch(selectedLocationProvider);
  if (loc == null) return null;
  final api = ref.watch(apiServiceProvider);
  return api.fetchFiveDayForecast(lat: loc.lat, lon: loc.lon);
});


