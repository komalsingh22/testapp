import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:test_app/models/weather.dart';
import 'package:test_app/models/forecast.dart';
import 'package:test_app/services/constants.dart';

class ApiService {
  final http.Client _client;

  ApiService({http.Client? client}) : _client = client ?? http.Client();

  Future<List<Map<String, dynamic>>> searchCities(String query) async {
    if (query.trim().isEmpty) return [];
    final url = Uri.parse(
      '${AppConstants.geoUrl}/direct?q=${Uri.encodeComponent(query)}&limit=5&appid=${AppConstants.openWeatherApiKey}',
    );

    final res = await _client.get(url);
    if (res.statusCode != 200) {
      throw Exception('City search failed (${res.statusCode})');
    }
    final decoded = jsonDecode(res.body) as List<dynamic>;
    return decoded.cast<Map<String, dynamic>>();
  }

  Future<Weather> fetchCurrentWeather({required double lat, required double lon}) async {
    final url = Uri.parse(
      '${AppConstants.baseUrl}/weather?lat=$lat&lon=$lon&appid=${AppConstants.openWeatherApiKey}&units=${AppConstants.units}',
    );
    final res = await _client.get(url);
    if (res.statusCode != 200) {
      throw Exception('Weather fetch failed (${res.statusCode})');
    }
    return Weather.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
  }

  Future<Forecast> fetchFiveDayForecast({required double lat, required double lon}) async {
    final url = Uri.parse(
      '${AppConstants.baseUrl}/forecast?lat=$lat&lon=$lon&appid=${AppConstants.openWeatherApiKey}&units=${AppConstants.units}',
    );
    final res = await _client.get(url);
    if (res.statusCode != 200) {
      throw Exception('Forecast fetch failed (${res.statusCode})');
    }
    return Forecast.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
  }
}


