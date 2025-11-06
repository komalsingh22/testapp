class ForecastItem {
  final DateTime dateTime;
  final double tempMin;
  final double tempMax;
  final String icon;
  final String description;

  ForecastItem({
    required this.dateTime,
    required this.tempMin,
    required this.tempMax,
    required this.icon,
    required this.description,
  });

  factory ForecastItem.fromJson(Map<String, dynamic> json) {
    final dt = json['dt'] as int? ?? 0;
    final main = json['main'] as Map<String, dynamic>? ?? {};
    final weatherList = json['weather'] as List<dynamic>? ?? [];
    final weather = weatherList.isNotEmpty
        ? weatherList.first as Map<String, dynamic>
        : <String, dynamic>{};

    return ForecastItem(
      dateTime: DateTime.fromMillisecondsSinceEpoch(dt * 1000, isUtc: true)
          .toLocal(),
      tempMin: (main['temp_min'] ?? 0).toDouble(),
      tempMax: (main['temp_max'] ?? 0).toDouble(),
      icon: (weather['icon'] ?? '') as String,
      description: (weather['description'] ?? '') as String,
    );
  }
}

class Forecast {
  final String cityName;
  final List<ForecastItem> items;

  Forecast({required this.cityName, required this.items});

  factory Forecast.fromJson(Map<String, dynamic> json) {
    final city = json['city'] as Map<String, dynamic>? ?? {};
    final list = json['list'] as List<dynamic>? ?? [];
    return Forecast(
      cityName: (city['name'] ?? '') as String,
      items: list
          .map((e) => ForecastItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}


