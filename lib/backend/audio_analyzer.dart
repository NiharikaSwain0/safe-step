import 'dart:async';
import 'package:safestep/backend/risk_engine.dart';
import 'package:safestep/backend/threat_level.dart';

class AudioAnalyzer {
  final RiskEngine riskEngine;
  final void Function(ThreatLevel) onResult;

  bool _isRunning = false;
  Timer? _timer;

  AudioAnalyzer(this.riskEngine, this.onResult);

  void start() {
    if (_isRunning) return; // already running
    _isRunning = true;

    // Simulate audio analysis every 1 second
    _timer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
      final fakeMFCC = _generateFakeMFCC();
      final result = riskEngine.evaluate(fakeMFCC);
      onResult(result);
    });
  }

  void stop() {
    _isRunning = false;
    _timer?.cancel();
  }

  // --- FAKE MFCC GENERATOR (Replace later with real MFCC) ---
  List<List<double>> _generateFakeMFCC() {
    return List.generate(
      40,
      (i) => List.generate(150, (j) => 0.01),
    );
  }
}
