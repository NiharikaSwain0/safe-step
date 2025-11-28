import 'dart:async';
import 'risk_engine.dart';
import 'threat_level.dart';

class AudioAnalyzer {
  final RiskEngine riskEngine;
  final void Function(ThreatLevel) onResult;

  bool _isRunning = false;
  Timer? _timer;

  AudioAnalyzer(this.riskEngine, this.onResult);

  /// Start monitoring footsteps
  void start() {
    if (_isRunning) return;
    _isRunning = true;

    print(" Audio analyzer started");

    // Run MFCC + Model every 1 second
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_isRunning) return;

      // TEMPORARY FAKE MFCC INPUT (until you add real audio)
      List<List<double>> fakeMfcc = List.generate(
        riskEngine.mfccCount,
        (i) => List.generate(
          riskEngine.frameCount,
          (j) => 0.0,
        ),
      );

      ThreatLevel level = riskEngine.evaluate(fakeMfcc);
      onResult(level);
    });
  }

  /// Stop monitoring
  void stop() {
    if (!_isRunning) return;

    _isRunning = false;
    _timer?.cancel();
    print(" Audio analyzer stopped");
  }
}