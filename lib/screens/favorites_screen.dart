import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:test_app/providers/weather_providers.dart';
import 'package:test_app/screens/weather_screen.dart';

class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favorites = ref.watch(favoritesProvider);
    final api = ref.read(apiServiceProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Favorites'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: favorites.isEmpty
          ? const Center(child: Text('No favorites yet', style: TextStyle(color: Colors.white)))
          : ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: favorites.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final loc = favorites[index];
                return Slidable(
                  endActionPane: ActionPane(
                    motion: const DrawerMotion(),
                    children: [
                      SlidableAction(
                        onPressed: (_) => ref.read(favoritesProvider.notifier).remove(loc),
                        icon: Icons.delete,
                        label: 'Remove',
                        backgroundColor: Colors.redAccent,
                      ),
                    ],
                  ),
                  child: FutureBuilder(
                    future: api.fetchCurrentWeather(lat: loc.lat, lon: loc.lon),
                    builder: (context, snapshot) {
                      final isLoading = snapshot.connectionState == ConnectionState.waiting;
                      final weather = snapshot.data;
                      return ListTile(
                        tileColor: Colors.white.withOpacity(0.1),
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
                                style: TextStyle(color: Colors.white.withOpacity(0.7)),
                              )
                            : null,
                        onTap: () {
                          ref.read(selectedLocationProvider.notifier).select(loc);
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const WeatherScreen()),
                          );
                        },
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}


