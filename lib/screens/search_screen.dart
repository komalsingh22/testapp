import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:test_app/providers/weather_providers.dart';
import 'package:test_app/screens/weather_screen.dart';
import 'package:test_app/utils/flags.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:test_app/models/weather.dart';
import 'package:test_app/widgets/background_widget.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final favorites = ref.watch(favoritesProvider);
    final api = ref.read(apiServiceProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Weather Finder'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Find the weather',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Search any city and get real-time forecasts',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white70),
                ),
                const SizedBox(height: 16),
                TypeAheadField<Map<String, dynamic>>(
              controller: _controller,
              debounceDuration: const Duration(milliseconds: 500),
              suggestionsCallback: (pattern) async {
                final trimmed = pattern.trim();
                if (trimmed.isEmpty) return <Map<String, dynamic>>[];
                try {
                  return await api.searchCities(trimmed);
                } catch (e) {
                  // Surface error via builder
                  throw Exception('Failed to search: $e');
                }
              },
              builder: (context, controller, focusNode) {
                return TextField(
                  controller: controller,
                  focusNode: focusNode,
                  style: const TextStyle(color: Colors.black87),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    hintText: 'Search city (e.g., London)',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                );
              },
              itemBuilder: (context, suggestion) {
                final name = suggestion['name'] ?? '';
                final country = suggestion['country'] ?? '';
                final flag = countryCodeToEmoji(country);
                return ListTile(
                  leading: Text(flag, style: const TextStyle(fontSize: 20)),
                  title: Text('$name, $country'),
                  subtitle: suggestion['state'] != null
                      ? Text(suggestion['state'])
                      : null,
                );
              },
              onSelected: (suggestion) {
                final name = suggestion['name'] as String? ?? '';
                final lat = (suggestion['lat'] ?? 0).toDouble();
                final lon = (suggestion['lon'] ?? 0).toDouble();
                final loc = SelectedLocation(name: name, lat: lat, lon: lon);
                ref.read(selectedLocationProvider.notifier).select(loc);
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const BackgroundWidget(child: WeatherScreen())),
                );
              },
                  loadingBuilder: (context) => const Padding(
                    padding: EdgeInsets.all(12),
                    child: Center(child: SpinKitThreeBounce(color: Colors.white, size: 24)),
                  ),
              emptyBuilder: (context) => const Padding(
                padding: EdgeInsets.all(12),
                child: Text('No cities found'),
              ),
                  errorBuilder: (context, error) => Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text('Error: $error'),
                  ),
                ),
                const SizedBox(height: 24),
                if (favorites.isNotEmpty)
                  Text(
                    'Favorites',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.w600),
                  ),
                if (favorites.isNotEmpty)
                  Expanded(
                    child: ListView.builder(
                      itemCount: favorites.length,
                      itemBuilder: (context, index) {
                        final loc = favorites[index];
                        return Container(
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          child: FutureBuilder<Weather?>(
                            future: api.fetchCurrentWeather(lat: loc.lat, lon: loc.lon),
                            builder: (context, snapshot) {
                              final isLoading = snapshot.connectionState == ConnectionState.waiting;
                              final weather = snapshot.data;
                              return ListTile(
                                tileColor: Colors.black.withAlpha(77),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                leading: isLoading
                                    ? const SizedBox(
                                        width: 40,
                                        height: 40,
                                        child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation(Colors.white)),
                                      )
                                    : Image.network(
                                        'https://openweathermap.org/img/wn/${weather?.icon ?? '01d'}.png',
                                        width: 40,
                                        height: 40,
                                      ),
                                title: Text(loc.name, style: const TextStyle(color: Colors.white)),
                                subtitle: weather != null
                                    ? Text(
                                        '${weather.temperature.toStringAsFixed(0)}° • ${weather.description}',
                                        style: TextStyle(color: Colors.white.withAlpha(179)),
                                      )
                                    : null,
                                onTap: () {
                                  ref.read(selectedLocationProvider.notifier).select(loc);
                                  Navigator.of(context).push(
                                    MaterialPageRoute(builder: (_) => const BackgroundWidget(child: WeatherScreen())),
                                  );
                                },
                                 trailing: IconButton(
                                  icon: const Icon(Icons.delete_outline, color: Colors.white),
                                  onPressed: () => ref.read(favoritesProvider.notifier).remove(loc),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
        ),
    );
  }
}


