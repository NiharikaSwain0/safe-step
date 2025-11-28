import 'package:safestep/backend/threat_level.dart';

// Optional import for real TFLite. If the package isn't present or configured
// return to fallback behaviour. The package is declared in pubspec.yaml.

class RiskEngine {
  // If you have `tflite_flutter` configured for your target platform, you can
  // add code to load and run the model. For portability and to avoid
  // compile-time issues in unit tests, we use a simple heuristic.
  // tfl.Interpreter? _interpreter;
  final int mfccCount = 40;
  final int frameCount = 150;
  final int classCount = 3;

  RiskEngine() {
    _loadModel();
  }

  Future<void> _loadModel() async {
    // Placeholder for model loading. Currently disabled in favor of a
    // deterministic heuristic that's test-friendly and portable.
    print('⚠ Model loading disabled; using fallback heuristics');
  }

  ThreatLevel evaluate(List<List<double>> mfcc) {
    // If you later enable a model, replace this section with actual model
    // inference logic. For now, always use the heuristic.
    return _heuristic(mfcc);
  }

  ThreatLevel _heuristic(List<List<double>> mfcc) {
    final sum = mfcc.fold<double>(0.0, (prev, row) => prev + row.fold(0.0, (p, e) => p + e));
    final count = (mfccCount * frameCount).toDouble();
    final avg = sum / count;

    if (avg < 0.03) return ThreatLevel.low;
    if (avg < 0.05) return ThreatLevel.medium;
    return ThreatLevel.high;
  }
}
