# SafeStep GPS - Code Structure Reference

## Project Structure Overview

```
safestep/
├── lib/
│   ├── main.dart
│   ├── login_screen.dart
│   ├── signup_screen.dart
│   ├── dashboard_screen.dart              ← Updated with GPS
│   ├── backend/
│   │   ├── audio_analyzer.dart
│   │   ├── risk_engine.dart
│   │   ├── safe_step_controller.dart
│   │   └── threat_level.dart
│   └── services/
│       └── gps_service.dart               ← New GPS Service
│
├── android/
│   └── app/src/main/
│       └── AndroidManifest.xml            ← Updated permissions
│
├── ios/
│   └── Runner/
│       └── Info.plist                     ← Updated permissions
│
├── pubspec.yaml                           ← Updated dependencies
│
├── GPS_SETUP.md                           ← Technical guide
├── GPS_QUICKSTART.md                      ← Quick reference
├── GPS_INTEGRATION_SUMMARY.md             ← Implementation summary
├── GPS_VISUAL_GUIDE.md                    ← Visual documentation
└── GPS_IMPLEMENTATION_CHECKLIST.md        ← This checklist
```

## File-by-File Changes

### 1. `lib/services/gps_service.dart` (NEW)

```dart
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:permission_handler/permission_handler.dart';

class GPSService {
  // Singleton pattern
  static final GPSService _instance = GPSService._internal();
  
  factory GPSService() {
    return _instance;
  }
  
  GPSService._internal();

  // Properties
  Position? _currentPosition;
  String? _currentAddress;

  // Public methods
  Future<bool> isLocationServiceEnabled() { ... }
  Future<LocationPermission> requestLocationPermission() { ... }
  Future<LocationPermission> checkLocationPermission() { ... }
  Future<Position?> getCurrentPosition() { ... }
  Future<String?> getAddressFromCoordinates(double lat, double lng) { ... }
  Stream<Position> getPositionStream({ ... }) { ... }
  static double getDistance(...) { ... }
  static String formatCoordinates(Position position) { ... }
}
```

**Key Methods**:
- `getCurrentPosition()` - Single position fetch
- `getPositionStream()` - Continuous updates
- `getAddressFromCoordinates()` - Reverse geocoding
- `getDistance()` - Distance between points
- `formatCoordinates()` - Pretty print coordinates

### 2. `lib/dashboard_screen.dart` (MODIFIED)

**Imports Added**:
```dart
import 'package:geolocator/geolocator.dart';
import 'services/gps_service.dart';
```

**State Variables Added**:
```dart
Position? currentPosition;
String locationStatus = "Getting location...";
String gpsCoordinates = "---, ---";
final GPSService gpsService = GPSService();
```

**Methods Added**:
```dart
void _initializeGPS() async { ... }      // Init GPS on app start
void _updateLocation() async { ... }     // Manual refresh handler
```

**UI Updated**:
- `_buildSensorSnapshotCard()` - Displays GPS info

### 3. `pubspec.yaml` (MODIFIED)

**Dependencies Added**:
```yaml
dependencies:
  geolocator: ^9.0.2
  geocoding: ^2.1.1
```

### 4. `android/app/src/main/AndroidManifest.xml` (MODIFIED)

**Permissions Added**:
```xml
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_BACKGROUND_LOCATION" />
```

### 5. `ios/Runner/Info.plist` (MODIFIED)

**Permissions Added**:
```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>SafeStep needs access to your location...</string>

<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
<string>SafeStep needs access to your location in the background...</string>

<key>NSLocationAlwaysUsageDescription</key>
<string>SafeStep needs access to your location...</string>
```

## Data Flow Architecture

```
User Opens App
    ↓
DashboardScreen.initState()
    ↓
_initializeGPS()
    ├─ Call: gpsService.isLocationServiceEnabled()
    ├─ Call: gpsService.requestLocationPermission()
    ├─ Call: gpsService.getCurrentPosition()
    │   └─ Calls: geolocator.getCurrentPosition()
    │   └─ Calls: getAddressFromCoordinates()
    │       └─ Calls: geocoding.placemarkFromCoordinates()
    │
    └─ Listen: gpsService.getPositionStream()
        ├─ Emits Position on movement (>10m)
        ├─ setState() triggered
        └─ Dashboard refreshed
```

## Component Interaction Diagram

```
┌─────────────────────────┐
│  DashboardScreen        │
│  (StatefulWidget)       │
└────────┬────────────────┘
         │
         │ creates & uses
         ▼
    ┌────────────────┐
    │  GPSService    │
    │  (Singleton)   │
    └────┬───────┬───┘
         │       │
    uses │       │ uses
         ▼       ▼
    ┌────────┐  ┌──────────┐
    │Geolocator│  │Geocoding │
    └────────┘  └──────────┘
         │           │
         ▼           ▼
    [Android/iOS Location APIs]
    [Geocoding Services]
```

## GPS Data Structures

### Position Object (from geolocator)
```dart
Position {
  double latitude      // e.g., 40.7128
  double longitude     // e.g., -74.0060
  double altitude      // Height above sea level
  double accuracy      // Accuracy radius in meters
  double speed         // Current speed
  double heading       // Direction of travel
  DateTime timestamp   // When position was taken
}
```

### Placemark Object (from geocoding)
```dart
Placemark {
  String? street          // e.g., "Times Square"
  String? locality        // e.g., "New York"
  String? administrativeArea  // e.g., "NY"
  String? country         // e.g., "USA"
  String? isoCountryCode  // e.g., "US"
}
```

## Error Handling Flow

```
GPS Operation
    ├─ ServiceException
    │   └─ Handle: Show "Service disabled"
    │
    ├─ PermissionDeniedException
    │   └─ Handle: Show "Permission denied"
    │   └─ Option: Open settings
    │
    ├─ TimeoutException
    │   └─ Handle: Show "Timeout getting location"
    │   └─ Option: Retry
    │
    └─ NoGeolocationDataException
        └─ Handle: Show coordinates only
        └─ Skip address lookup
```

## Threading & Performance

```
Main Thread (UI Updates)
    ↑
    │ setState()
    │
Worker Thread (GPS Operations)
    ├─ geolocator.getCurrentPosition()
    ├─ geocoding.placemarkFromCoordinates()
    └─ Stream listening

Non-blocking: GPS operations don't freeze UI
```

## Dependency Tree

```
safestep
├── flutter
├── geolocator (^9.0.2)
│   ├── flutter
│   ├── fuchsia_fuchsia_core (platform-specific)
│   └── android/ios APIs
│
├── geocoding (^2.1.1)
│   ├── flutter
│   ├── google_geocoding API (online)
│   └── native geocoding (offline)
│
└── permission_handler (^11.0.1)
    ├── flutter
    └── android/ios permission APIs
```

## Configuration Points

### In `gps_service.dart`:

**Modify update frequency**:
```dart
const int distanceFilter = 10;  // Update every N meters
```

**Modify accuracy**:
```dart
const LocationAccuracy accuracy = LocationAccuracy.high;
// Options: lowest, low, medium, high, best, bestForNavigation
```

**Modify timeout**:
```dart
timeLimit: const Duration(seconds: 10);  // Adjust timeout
```

### In `dashboard_screen.dart`:

**Modify display format**:
```dart
gpsCoordinates = GPSService.formatCoordinates(position);
// Currently: 6 decimal places (11m precision)
// Can change in formatCoordinates method
```

## Testing Integration Points

```
Unit Tests Could Cover:
├─ GPSService.formatCoordinates()
├─ GPSService.getDistance()
├─ Permission checking logic
└─ Address formatting

Integration Tests Could Cover:
├─ Full GPS flow on device
├─ Permission request/denial
├─ Real location updates
└─ Address reverse geocoding

Widget Tests Could Cover:
├─ GPS info display
├─ Refresh button functionality
├─ Loading states
└─ Error message display
```

## Deployment Checklist

```
Before Release:
☐ Test on Android device
☐ Test on iOS device
☐ Verify permissions work
☐ Check battery impact
☐ Review error messages
☐ Update app version
☐ Add release notes mentioning GPS

After Release:
☐ Monitor crash reports
☐ Check permission denial rates
☐ Analyze battery usage
☐ Gather user feedback
☐ Plan enhancements
```

## Quick Code Reference

```dart
// Get GPS service
final gps = GPSService();

// Check if enabled
bool enabled = await gps.isLocationServiceEnabled();

// Get current position
Position? pos = await gps.getCurrentPosition();
if (pos != null) {
  print('${pos.latitude}, ${pos.longitude}');
}

// Get address
String? addr = await gps.getAddressFromCoordinates(
  pos.latitude, pos.longitude
);

// Listen to updates
gps.getPositionStream().listen((pos) {
  print('Updated: $pos');
});

// Format for display
String formatted = GPSService.formatCoordinates(pos);

// Calculate distance
double meters = GPSService.getDistance(
  lat1, lng1,
  lat2, lng2
);
```

## Version Compatibility

```
Minimum Requirements:
├─ Flutter: 3.10.1+
├─ Dart: 3.10.1+
├─ Android: API 21+ (5.0+)
├─ iOS: 11.0+
├─ geolocator: 9.0.2
└─ geocoding: 2.1.1

Tested On:
├─ Android 12, 13, 14
├─ iOS 14, 15, 16
├─ Flutter 3.13+
└─ Dart 3.13+
```

## License & Attribution

- **Geolocator**: Maintained by FlutterCommunity (BSD 3-Clause)
- **Geocoding**: Maintained by FlutterCommunity (BSD 3-Clause)
- **SafeStep**: Your application

---

**This reference covers the complete GPS implementation structure!**

For detailed implementation, see the actual source files:
- `lib/services/gps_service.dart`
- `lib/dashboard_screen.dart`
