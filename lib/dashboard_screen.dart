import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'services/gps_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  double riskLevel = 18;
  String riskStatus = "LOW";
  bool isMonitoring = true;

  // GPS Variables
  Position? currentPosition;
  String locationStatus = "Getting location...";
  String gpsCoordinates = "---, ---";
  final GPSService gpsService = GPSService();

  @override
  void initState() {
    super.initState();
    _initializeGPS();
  }

  /// Initialize GPS and start tracking
  void _initializeGPS() async {
    // Check location services
    bool serviceEnabled = await gpsService.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() {
        locationStatus = "Location service disabled";
      });
      return;
    }

    // Request permission
    LocationPermission permission = await gpsService.requestLocationPermission();
    if (permission == LocationPermission.deniedForever) {
      setState(() {
        locationStatus = "Location permission denied";
      });
      return;
    }

    // Get current position
    _updateLocation();

    // Listen to position updates
    gpsService.getPositionStream().listen((Position position) {
      setState(() {
        currentPosition = position;
        gpsCoordinates = GPSService.formatCoordinates(position);
        locationStatus = "Location tracking active";
      });
    });
  }

  /// Update location manually
  void _updateLocation() async {
    Position? position = await gpsService.getCurrentPosition();
    if (position != null) {
      String? address = await gpsService.getAddressFromCoordinates(
        position.latitude,
        position.longitude,
      );

      setState(() {
        currentPosition = position;
        gpsCoordinates = GPSService.formatCoordinates(position);
        locationStatus = address ?? "Location tracking active";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              children: [
                // ============== TOP BAR ==============
                _buildTopBar(),
                const SizedBox(height: 20),

                // ============== LIVE MONITORING CARD ==============
                _buildLiveMonitoringCard(),
                const SizedBox(height: 12),

                // ============== RISK LEVEL CARD ==============
                _buildRiskLevelCard(),
                const SizedBox(height: 12),

                // ============== SENSOR SNAPSHOT CARD ==============
                _buildSensorSnapshotCard(),
                const SizedBox(height: 12),

                // ============== AUDIO STREAM CARD ==============
                _buildAudioStreamCard(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: const Color(0xFF0052CC),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              "8:02 AM",
              style: TextStyle(fontSize: 14, color: Color(0xFF666666)),
            ),
          ],
        ),
        const Text(
          "Operator: Admin • 26 Nov 2025",
          style: TextStyle(fontSize: 14, color: Color(0xFF666666)),
        ),
      ],
    );
  }

  Widget _buildLiveMonitoringCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 18,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Live Monitoring",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: const Color(0xFF34C759),
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  "AI is analyzing footsteps, motion patterns, and audio data.",
                  style: TextStyle(fontSize: 14, color: Color(0xFF666666)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRiskLevelCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 18,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Current Risk Level",
            style: TextStyle(fontSize: 14, color: Color(0xFF666666)),
          ),
          const SizedBox(height: 10),
          // Progress bar
          Container(
            height: 10,
            decoration: BoxDecoration(
              color: const Color(0xFFE5E5EA),
              borderRadius: BorderRadius.circular(5),
            ),
            child: FractionallySizedBox(
              widthFactor: riskLevel / 100,
              child: Container(
                decoration: BoxDecoration(
                  color: _getRiskColor(),
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "$riskStatus ${riskLevel.toInt()}%",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: _getRiskColor(),
            ),
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () {
              setState(() {
                riskLevel = (riskLevel + 15) % 100;
                if (riskLevel == 0) riskLevel = 15;
                riskStatus = riskLevel > 60
                    ? "HIGH"
                    : riskLevel > 30
                        ? "MEDIUM"
                        : "LOW";
              });
            },
            child: Text(
              "Simulate risk change",
              style: TextStyle(
                fontSize: 14,
                color: const Color(0xFF0052CC),
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSensorSnapshotCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 18,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Sensor Snapshot",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              GestureDetector(
                onTap: _updateLocation,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0052CC).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(
                    Icons.refresh,
                    size: 16,
                    color: Color(0xFF0052CC),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildSensorRow("Footstep intensity", "Normal"),
          _buildSensorRow("Motion pattern", "Walking"),
          _buildSensorRow("Sound anomaly", "None"),
          _buildSensorRow("Location", "Block A - Corridor 3"),
          const Divider(height: 16),
          const Text(
            "GPS Information",
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF0052CC)),
          ),
          const SizedBox(height: 8),
          _buildSensorRow("Coordinates", gpsCoordinates),
          _buildSensorRow("Status", locationStatus, isGPS: true),
          if (currentPosition != null)
            _buildSensorRow("Accuracy", "${currentPosition!.accuracy.toStringAsFixed(1)}m"),
        ],
      ),
    );
  }

  Widget _buildSensorRow(String label, String value, {bool isGPS = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 14),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: TextStyle(
                fontSize: 14,
                color: isGPS ? const Color(0xFF0052CC) : const Color(0xFF666666),
                fontWeight: isGPS ? FontWeight.w500 : FontWeight.normal,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAudioStreamCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 18,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Live Audio Stream",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          _buildAudioRow("Connected", "●"),
          const SizedBox(height: 12),
          // Waveform placeholder
          Container(
            height: 50,
            decoration: BoxDecoration(
              color: const Color(0xFFF2F2F7),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  8,
                  (index) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: Container(
                      width: 3,
                      height: 15 + (index % 2) * 10,
                      decoration: BoxDecoration(
                        color: const Color(0xFF0052CC).withOpacity(0.6),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            "Listening for decibel spikes..",
            style: TextStyle(fontSize: 13, color: Color(0xFF666666)),
          ),
          const SizedBox(height: 4),
          const Text(
            "Last Alert: Normal movement detected.",
            style: TextStyle(fontSize: 13, color: Color(0xFF666666)),
          ),
          const SizedBox(height: 4),
          const Text(
            "Environment is stable.",
            style: TextStyle(fontSize: 13, color: Color(0xFF666666)),
          ),
        ],
      ),
    );
  }

  Widget _buildAudioRow(String label, String status) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14),
        ),
        Text(
          status,
          style: const TextStyle(fontSize: 14, color: Color(0xFF34C759)),
        ),
      ],
    );
  }

  Color _getRiskColor() {
    if (riskLevel > 60) return const Color(0xFFFF3B30);
    if (riskLevel > 30) return const Color(0xFFFF9500);
    return const Color(0xFF34C759);
  }
}
