class Weather {
  final String cityName;
  final String countryCode;
  final String description;
  final String icon;
  final double temperature;
  final double feelsLike;
  final int humidity;
  final double windSpeed;
  final int pressure;

  Weather({
    required this.cityName,
    required this.countryCode,
    required this.description,
    required this.icon,
    required this.temperature,
    required this.feelsLike,
    required this.humidity,
    required this.windSpeed,
    required this.pressure,
  });

  factory Weather.fromJson(Map<String, dynamic> json) {
    return Weather(
      cityName: json['name'] ?? '',
      countryCode: (json['sys']?['country'] ?? '') as String,
      description: (json['weather'] != null && json['weather'].isNotEmpty)
          ? json['weather'][0]['description'] ?? ''
          : '',
      icon: (json['weather'] != null && json['weather'].isNotEmpty)
          ? json['weather'][0]['icon'] ?? ''
          : '',
      temperature: (json['main']?['temp'] ?? 0).toDouble(),
      feelsLike: (json['main']?['feels_like'] ?? 0).toDouble(),
      humidity: (json['main']?['humidity'] ?? 0).toInt(),
      windSpeed: (json['wind']?['speed'] ?? 0).toDouble(),
      pressure: (json['main']?['pressure'] ?? 0).toInt(),
    );
  }
}


