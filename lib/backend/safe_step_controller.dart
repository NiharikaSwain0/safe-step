import 'package:safestep/backend/audio_analyzer.dart';
import 'package:safestep/backend/risk_engine.dart';
import 'package:safestep/backend/threat_level.dart';

class SafeStepController {
  late AudioAnalyzer analyzer;
  late RiskEngine engine;

  void Function(ThreatLevel)? onThreatDetected;

  SafeStepController() {
    engine = RiskEngine();
    analyzer = AudioAnalyzer(engine, (level) {
      if (onThreatDetected != null) {
        onThreatDetected!(level);
      }
    });
  }

  void start() {
    analyzer.start();
  }

  void stop() {
    analyzer.stop();
  }
}
