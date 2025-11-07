import 'package:geolocator/geolocator.dart';

class LocationService {
  static Future<Position> getCurrentLocation() async {
    // ⚠️ POUR LE DÉVELOPPEMENT - Utilise toujours la position simulée
    // Tu pourras remettre la vraie localisation plus tard
    print('📍 UTILISATION POSITION SIMULÉE (Ouagadougou)');

    return Position(
      latitude: 12.3713, // Ouagadougou, Burkina Faso
      longitude: -1.5197,
      timestamp: DateTime.now(),
      accuracy: 50.0,
      altitude: 300.0,
      altitudeAccuracy: 0.0,
      heading: 0,
      headingAccuracy: 0.0,
      speed: 0,
      speedAccuracy: 0,
    );

    /* 
    // CODE ORIGINAL (à remettre plus tard)
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return getMockLocation(); // Fallback
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return getMockLocation(); // Fallback
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return getMockLocation(); // Fallback
      }

      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.low,
      );
    } catch (e) {
      return getMockLocation(); // Fallback en cas d'erreur
    }
    */
  }
}
