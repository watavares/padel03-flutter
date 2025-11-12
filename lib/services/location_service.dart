import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import '../models/user_model.dart';

/// Service for handling location operations
class LocationService {
  static final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  /// Request location permission
  static Future<LocationPermission> requestPermission() async {
    if (kIsWeb) {
      // Web doesn't use the geolocator package for permissions
      return LocationPermission.always; // Assume permission for web
    }

    LocationPermission permission = await Geolocator.checkPermission();
    
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    await _analytics.logEvent(
      name: 'location_permission_requested',
      parameters: {
        'permission_status': permission.name,
      },
    );

    return permission;
  }

  /// Check if location services are enabled
  static Future<bool> isLocationServiceEnabled() async {
    if (kIsWeb) {
      return true; // Assume location services are available on web
    }
    return await Geolocator.isLocationServiceEnabled();
  }

  /// Get current position
  static Future<Position?> getCurrentPosition() async {
    try {
      if (kIsWeb) {
        // Web-specific location handling
        return await _getWebPosition();
      }

      // Check if location services are enabled
      final bool serviceEnabled = await isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Location services are disabled');
      }

      // Check permission
      final permission = await requestPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        throw Exception('Location permission denied');
      }

      // Get position with timeout
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      await _analytics.logEvent(
        name: 'location_obtained',
        parameters: {
          'source': 'gps',
          'accuracy': position.accuracy,
        },
      );

      return position;
    } catch (e) {
      await _analytics.logEvent(
        name: 'location_error',
        parameters: {
          'error': e.toString(),
        },
      );
      
      throw Exception('Failed to get location: $e');
    }
  }

  /// Web-specific position handling
  static Future<Position> _getWebPosition() async {
    try {
      // For web, we'll use the HTML5 Geolocation API through geolocator
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 15),
      );
    } catch (e) {
      throw Exception('Web location access failed: $e');
    }
  }

  /// Reverse geocode position to get city and country
  static Future<UserLocation> reverseGeocode(Position position) async {
    try {
      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isEmpty) {
        throw Exception('No location data found');
      }

      final placemark = placemarks.first;
      final city = placemark.locality ?? 
                   placemark.subAdministrativeArea ?? 
                   placemark.administrativeArea ?? 
                   'Unknown City';
      
      final country = placemark.country ?? 'Unknown Country';

      final location = UserLocation(
        lat: position.latitude,
        lng: position.longitude,
        city: city,
        country: country,
        source: 'auto',
      );

      await _analytics.logEvent(
        name: 'location_geocoded',
        parameters: {
          'city': city,
          'country': country,
        },
      );

      return location;
    } catch (e) {
      // Fallback to coordinates if geocoding fails
      final location = UserLocation(
        lat: position.latitude,
        lng: position.longitude,
        city: 'Unknown City',
        country: 'Unknown Country',
        source: 'auto',
      );

      await _analytics.logEvent(
        name: 'geocoding_failed',
        parameters: {
          'error': e.toString(),
        },
      );

      return location;
    }
  }

  /// Get user location automatically
  static Future<UserLocation> getUserLocation() async {
    final position = await getCurrentPosition();
    if (position == null) {
      throw Exception('Could not obtain location');
    }
    return await reverseGeocode(position);
  }

  /// Create manual location from city and country input
  static Future<UserLocation> createManualLocation({
    required String city,
    required String country,
  }) async {
    try {
      // Try to geocode the manual input to get coordinates
      final locations = await locationFromAddress('$city, $country');
      
      if (locations.isNotEmpty) {
        final location = locations.first;
        final userLocation = UserLocation(
          lat: location.latitude,
          lng: location.longitude,
          city: city.trim(),
          country: country.trim(),
          source: 'manual',
        );

        await _analytics.logEvent(
          name: 'manual_location_created',
          parameters: {
            'city': city,
            'country': country,
          },
        );

        return userLocation;
      } else {
        throw Exception('Could not find coordinates for this location');
      }
    } catch (e) {
      // If geocoding fails, create location without coordinates
      final userLocation = UserLocation(
        lat: 0.0, // Default coordinates
        lng: 0.0,
        city: city.trim(),
        country: country.trim(),
        source: 'manual',
      );

      await _analytics.logEvent(
        name: 'manual_location_fallback',
        parameters: {
          'city': city,
          'country': country,
          'error': e.toString(),
        },
      );

      return userLocation;
    }
  }

  /// Search for places matching a query
  static Future<List<Location>> searchPlaces(String query) async {
    try {
      if (query.trim().isEmpty) {
        return [];
      }

      final locations = await locationFromAddress(query);
      return locations;
    } catch (e) {
      return [];
    }
  }

  /// Get location suggestions for autocomplete
  static Future<List<String>> getLocationSuggestions(String query) async {
    try {
      // This is a simple implementation. For production, consider using
      // Google Places API or similar service for better results
      if (query.length < 3) {
        return [];
      }

      // Common city/country combinations for demo
      final suggestions = [
        'Madrid, Spain',
        'Barcelona, Spain',
        'Valencia, Spain',
        'Sevilla, Spain',
        'Málaga, Spain',
        'London, United Kingdom',
        'Paris, France',
        'Berlin, Germany',
        'Rome, Italy',
        'Amsterdam, Netherlands',
        'New York, United States',
        'Los Angeles, United States',
        'Buenos Aires, Argentina',
        'Mexico City, Mexico',
        'São Paulo, Brazil',
      ].where((suggestion) => 
        suggestion.toLowerCase().contains(query.toLowerCase())
      ).toList();

      return suggestions.take(5).toList();
    } catch (e) {
      return [];
    }
  }

  /// Calculate distance between two locations in kilometers
  static double calculateDistance({
    required double lat1,
    required double lng1,
    required double lat2,
    required double lng2,
  }) {
    return Geolocator.distanceBetween(lat1, lng1, lat2, lng2) / 1000; // Convert to km
  }

  /// Check if location permission is granted
  static Future<bool> hasLocationPermission() async {
    if (kIsWeb) {
      return true; // Assume permission on web
    }

    final permission = await Geolocator.checkPermission();
    return permission == LocationPermission.always || 
           permission == LocationPermission.whileInUse;
  }

  /// Open location settings
  static Future<bool> openLocationSettings() async {
    if (kIsWeb) {
      return false; // Cannot open settings on web
    }

    return await Geolocator.openLocationSettings();
  }

  /// Open app settings
  static Future<bool> openAppSettings() async {
    if (kIsWeb) {
      return false; // Cannot open settings on web
    }

    return await Geolocator.openAppSettings();
  }
}