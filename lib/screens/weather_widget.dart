// lib/screens/weather_widget.dart
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

class WeatherWidget extends StatefulWidget {
  const WeatherWidget({super.key});

  @override
  State<WeatherWidget> createState() => _WeatherWidgetState();
}

class _WeatherWidgetState extends State<WeatherWidget> {
  String? _description;
  double? _tempC;
  String? _city;
  String? _error;
  bool _loading = true;

  //  Replace with your actual OpenWeatherMap API key
  static const String _apiKey = 'API_KEY_HERE';

  @override
  void initState() {
    super.initState();
    _fetchWeather();
  }

  Future<void> _fetchWeather() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      // 1️⃣ Check if location services are enabled
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _error = 'Location services are disabled. Please enable them.';
          _loading = false;
        });
        return;
      }

      // 2️⃣ Handle permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied) {
        setState(() {
          _error = 'Location permission denied. Please allow it in settings.';
          _loading = false;
        });
        return;
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _error =
              'Location permission permanently denied. Enable it in system settings.';
          _loading = false;
        });
        return;
      }

      // 3️⃣ Get current position
      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 12),
      );

      await _fetchWeatherForCoordinates(pos.latitude, pos.longitude);
    } on TimeoutException {
      setState(() {
        _error = 'Location request timed out. Try again.';
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Error fetching location: $e';
        _loading = false;
      });
    }
  }

  Future<void> _fetchWeatherForCoordinates(double lat, double lon) async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final url =
          'https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lon&appid=$_apiKey&units=metric';

      final response =
          await http.get(Uri.parse(url)).timeout(const Duration(seconds: 10));

      // Debug print — helps diagnose 401/429/etc.
      // ignore: avoid_print
      print('Weather API response: ${response.statusCode}');
      // ignore: avoid_print
      print('Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _description = (data['weather']?[0]?['description'] ?? '').toString();
          _tempC = double.tryParse(data['main']?['temp']?.toString() ?? '');
          _city = data['name']?.toString() ?? '';
          _loading = false;
        });
      } else {
        String msg = 'Failed (code ${response.statusCode})';
        try {
          final parsed = jsonDecode(response.body);
          if (parsed is Map && parsed['message'] != null) {
            msg += ': ${parsed['message']}';
          }
        } catch (_) {}
        setState(() {
          _error = msg;
          _loading = false;
        });
      }
    } on TimeoutException {
      setState(() {
        _error = 'Weather request timed out. Check your internet.';
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Error: $e';
        _loading = false;
      });
    }
  }

  void _showEnterCoordinatesDialog() {
    final latCtl = TextEditingController();
    final lonCtl = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Enter Coordinates'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: latCtl,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'Latitude'),
            ),
            TextField(
              controller: lonCtl,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'Longitude'),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              final lat = double.tryParse(latCtl.text.trim());
              final lon = double.tryParse(lonCtl.text.trim());
              if (lat != null && lon != null) {
                _fetchWeatherForCoordinates(lat, lon);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Invalid coordinates')),
                );
              }
            },
            child: const Text('Fetch'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Card(
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Error: $_error',
                style: const TextStyle(color: Colors.red),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: [
                  ElevatedButton.icon(
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                    onPressed: _fetchWeather,
                  ),
                  OutlinedButton.icon(
                    icon: const Icon(Icons.edit_location),
                    label: const Text('Enter coords'),
                    onPressed: _showEnterCoordinatesDialog,
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      elevation: 4,
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.wb_sunny, size: 48, color: Colors.orange),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _city ?? '--',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${_tempC?.toStringAsFixed(1) ?? '--'}°C, ${_description ?? '--'}',
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
            IconButton(
              tooltip: 'Refresh',
              icon: const Icon(Icons.refresh),
              onPressed: _fetchWeather,
            ),
          ],
        ),
      ),
    );
  }
}
