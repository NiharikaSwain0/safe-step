# GPS Integration Guide for SafeStep

This guide explains how GPS has been integrated into the SafeStep application for real-time location tracking and monitoring.

## Overview

SafeStep now includes real-time GPS location tracking that:
- Gets current GPS coordinates (latitude, longitude)
- Reverse geocodes coordinates to get human-readable addresses
- Displays location accuracy
- Continuously tracks location updates
- Shows GPS status on the dashboard

## Dependencies Added

The following packages were added to `pubspec.yaml`:
- **geolocator**: ^9.0.2 - Core location tracking
- **geocoding**: ^2.1.1 - Convert coordinates to addresses

## Files Created/Modified

### New Files:
- `lib/services/gps_service.dart` - GPS service class with all location logic

### Modified Files:
- `pubspec.yaml` - Added geolocator and geocoding dependencies
- `lib/dashboard_screen.dart` - Integrated GPS display and tracking
- `android/app/src/main/AndroidManifest.xml` - Added location permissions
- `ios/Runner/Info.plist` - Added iOS location permission descriptions

## Features

### GPSService Class (`lib/services/gps_service.dart`)

```dart
// Get current position
Position? position = await gpsService.getCurrentPosition();

// Listen to real-time location updates
gpsService.getPositionStream().listen((Position position) {
  // Handle position update
});

// Convert coordinates to address (reverse geocoding)
String? address = await gpsService.getAddressFromCoordinates(
  latitude, 
  longitude
);

// Calculate distance between two points
double distance = GPSService.getDistance(
  startLatitude, startLongitude,
  endLatitude, endLongitude
);

// Format coordinates for display
String formatted = GPSService.formatCoordinates(position);
```

### Dashboard Integration

The GPS information is displayed in the **Sensor Snapshot** section:
- **Coordinates**: Current GPS coordinates
- **Status**: Location tracking status or human-readable address
- **Accuracy**: GPS accuracy in meters (when available)
- **Refresh Button**: Manual location refresh

## Setup Instructions

### 1. Get Dependencies
```bash
flutter pub get
```

### 2. Android Setup

The required permissions are already added to `AndroidManifest.xml`:
```xml
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_BACKGROUND_LOCATION" />
```

**Note**: For background location tracking on Android 11+, you may need to:
1. Request `ACCESS_BACKGROUND_LOCATION` separately
2. Have the app on the user's battery optimization whitelist

### 3. iOS Setup

iOS permission descriptions are configured in `ios/Runner/Info.plist`:
- `NSLocationWhenInUseUsageDescription` - For foreground location access
- `NSLocationAlwaysAndWhenInUseUsageDescription` - For background location
- `NSLocationAlwaysUsageDescription` - Legacy permission

Users will see permission dialogs when the app first tries to access location.

### 4. Runtime Permission Handling

The app automatically:
1. Checks if location services are enabled
2. Requests permission from the user
3. Handles permission denial gracefully
4. Opens app settings if permission is permanently denied

## Usage Example

```dart
import 'services/gps_service.dart';

// In your widget
final GPSService gpsService = GPSService();

@override
void initState() {
  super.initState();
  _initializeGPS();
}

void _initializeGPS() async {
  // Check if location service is enabled
  bool serviceEnabled = await gpsService.isLocationServiceEnabled();
  if (!serviceEnabled) {
    print('Location services are disabled');
    return;
  }

  // Request permission
  LocationPermission permission = 
    await gpsService.requestLocationPermission();
  
  if (permission == LocationPermission.deniedForever) {
    print('Location permission denied forever');
    return;
  }

  // Get current position
  Position? position = await gpsService.getCurrentPosition();
  if (position != null) {
    print('Latitude: ${position.latitude}');
    print('Longitude: ${position.longitude}');
  }

  // Listen to continuous updates
  gpsService.getPositionStream().listen((Position position) {
    print('Updated location: ${position.latitude}, ${position.longitude}');
  });
}
```

## Privacy & Security

⚠️ **Important Considerations**:
1. **Location Data**: Store location data securely and don't share unnecessarily
2. **User Consent**: Users can revoke location permissions anytime
3. **Background Tracking**: Only use background location when absolutely necessary
4. **Battery Impact**: Continuous GPS tracking consumes significant battery

## Troubleshooting

### Location shows "Getting location..."
- Ensure GPS/Location services are enabled on the device
- Check that permission has been granted to SafeStep
- Try moving outside if GPS is getting weak signal

### Address is not showing
- Reverse geocoding requires internet connection
- The device may not have geocoding service available
- This is handled gracefully by showing coordinates instead

### Accuracy is very low
- Move outside or to an area with better GPS signal
- Wait a few seconds for GPS to get a better fix
- GPS accuracy improves over time

### Permissions not working on Android
- Rebuild the app: `flutter clean && flutter pub get`
- For Android 6.0+, runtime permissions are required
- For Android 11+, background location requires separate permission

## Testing

To test GPS functionality:

1. **Emulator**: Use Android Emulator's extended controls to simulate GPS location
2. **Real Device**: Grant permissions and test in actual locations
3. **Offline Maps**: Use apps like Google Maps offline to test address display

## Future Enhancements

Potential features to add:
- [ ] Geofencing (alerts when entering/leaving areas)
- [ ] Route tracking and history
- [ ] Location sharing with emergency contacts
- [ ] Map integration with Google Maps
- [ ] GPS accuracy warnings
- [ ] Battery optimization modes

## References

- [Geolocator Package](https://pub.dev/packages/geolocator)
- [Geocoding Package](https://pub.dev/packages/geocoding)
- [Flutter Location Permissions](https://flutter.dev/docs/development/data-and-backend/google-maps)
- [Android Location Best Practices](https://developer.android.com/guide/topics/location)
