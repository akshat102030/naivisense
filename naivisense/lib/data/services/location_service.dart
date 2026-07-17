import 'package:geolocator/geolocator.dart';

class LocationService {
  LocationService._();

  static Future<Position?> getCurrentLocation() async {
    try {
      print('📍 Checking if location service is enabled...');

      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      print('📍 Location service enabled: $serviceEnabled');

      if (!serviceEnabled) {
        print('❌ Location services are disabled.');
        return null;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      print('📍 Current permission: $permission');

      if (permission == LocationPermission.denied) {
        print('📍 Requesting location permission...');
        permission = await Geolocator.requestPermission();
        print('📍 Permission after request: $permission');

        if (permission == LocationPermission.denied) {
          print('❌ Location permission denied.');
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        print('❌ Location permission permanently denied.');
        return null;
      }

      print('📍 Fetching current location...');

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      print('✅ Location received!');
      print('Latitude : ${position.latitude}');
      print('Longitude: ${position.longitude}');
      print('Accuracy : ${position.accuracy}');
      print('Altitude : ${position.altitude}');
      print('Speed    : ${position.speed}');
      print('Time     : ${position.timestamp}');

      return position;
    } catch (e, stackTrace) {
      print('❌ Location Error: $e');
      print(stackTrace);
      return null;
    }
  }
}
