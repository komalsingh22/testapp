import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:test_app/models/forecast.dart';
import 'package:test_app/models/weather.dart';
import 'package:test_app/providers/weather_providers.dart';
import 'package:test_app/utils/flags.dart';

class WeatherScreen extends ConsumerWidget {
  const WeatherScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = ref.watch(selectedLocationProvider);
    final weatherAsync = ref.watch(currentWeatherProvider);
    final forecastAsync = ref.watch(fiveDayForecastProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(loc?.name ?? 'Weather'),
        actions: [
          IconButton(
            icon: const Icon(Icons.star_border),
            tooltip: 'Add to favorites',
            onPressed: loc == null
                ? null
                : () => ref.read(favoritesProvider.notifier).add(loc),
          ),
        ],
      ),
      body: SafeArea(
          child: RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(currentWeatherProvider);
              ref.invalidate(fiveDayForecastProvider);
              await Future.wait([
                ref.read(currentWeatherProvider.future),
                ref.read(fiveDayForecastProvider.future),
              ]);
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _CurrentWeatherSection(weatherAsync: weatherAsync),
                  const SizedBox(height: 24),
                  _ForecastSection(forecastAsync: forecastAsync),
                ],
              ),
            ),
          ),
        ),
    );
  }
}

class _CurrentWeatherSection extends StatelessWidget {
  final AsyncValue<Weather?> weatherAsync;
  const _CurrentWeatherSection({required this.weatherAsync});

  @override
  Widget build(BuildContext context) {
    return weatherAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => _ErrorBox(message: 'Failed to load weather: $e'),
      data: (weather) {
        if (weather == null) {
          return const _ErrorBox(message: 'No location selected');
        }
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: Card(
            key: ValueKey('${weather.cityName}-${weather.temperature}-${weather.icon}'),
            elevation: 4,
            color: Colors.black.withAlpha(77),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Image.network(
                    'https://openweathermap.org/img/wn/${weather.icon}@2x.png',
                    width: 88,
                    height: 88,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text('${weather.cityName} ', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white)),
                            Text(countryCodeToEmoji(weather.countryCode), style: const TextStyle(fontSize: 18)),
                          ],
                        ),
                        Text(
                          '${weather.temperature.toStringAsFixed(0)}°',
                          style: Theme.of(context).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w700, color: Colors.white),
                        ),
                        Text(
                          weather.description,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white70),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 16,
                          runSpacing: 8,
                          children: [
                            _Chip('Feels like: ${weather.feelsLike.toStringAsFixed(0)}°'),
                            _Chip('Humidity: ${weather.humidity}%'),
                            _Chip('Wind: ${weather.windSpeed.toStringAsFixed(1)} m/s'),
                            _Chip('Pressure: ${weather.pressure} hPa'),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ForecastSection extends StatelessWidget {
  final AsyncValue<Forecast?> forecastAsync;
  const _ForecastSection({required this.forecastAsync});

  Map<DateTime, List<ForecastItem>> _groupByDay(List<ForecastItem> items) {
    final Map<DateTime, List<ForecastItem>> grouped = {};
    for (final item in items) {
      final key = DateTime(item.dateTime.year, item.dateTime.month, item.dateTime.day);
      grouped.putIfAbsent(key, () => []).add(item);
    }
    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    return forecastAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => _ErrorBox(message: 'Failed to load forecast: $e'),
      data: (forecast) {
        if (forecast == null) return const SizedBox.shrink();
        final grouped = _groupByDay(forecast.items).entries.toList()
          ..sort((a, b) => a.key.compareTo(b.key));

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('5-Day Forecast', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            SizedBox(
              height: 150,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: grouped.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final entry = grouped[index];
                  final min = entry.value.map((e) => e.tempMin).reduce((a, b) => a < b ? a : b);
                  final max = entry.value.map((e) => e.tempMax).reduce((a, b) => a > b ? a : b);
                  final icon = entry.value[(entry.value.length / 2).floor()].icon;
                  final day = DateFormat('EEE').format(entry.key);
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    width: 130,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.black.withAlpha(77),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(20),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(day, style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white)),
                        const SizedBox(height: 8),
                        Image.network(
                          'https://openweathermap.org/img/wn/$icon.png',
                          width: 48,
                          height: 48,
                        ),
                        const SizedBox(height: 8),
                        Text('${min.toStringAsFixed(0)}° / ${max.toStringAsFixed(0)}°', style: const TextStyle(color: Colors.white)),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  const _Chip(this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(51),
        borderRadius: BorderRadius.circular(24),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Text(label, style: const TextStyle(color: Colors.white)),
    );
  }
}

class _ErrorBox extends StatelessWidget {
  final String message;
  const _ErrorBox({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(message, style: TextStyle(color: Theme.of(context).colorScheme.onErrorContainer)),
    );
  }
}