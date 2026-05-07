import 'package:feve_app/models/segmentation_result.dart';

class SavitzkyGolayFilter {
  static const List<int> _coeffs = [-3, 12, 17, 12, -3];
  static const int _norm = 35;

  final List<SegmentationResult> _buffer = [];

  final Map<String, int> _classCounts = {};

  SegmentationResult? process(SegmentationResult newResult) {
    String incomingClass = newResult.viewClass;
    _classCounts[incomingClass] = (_classCounts[incomingClass] ?? 0) + 1;

    _buffer.add(newResult);

    if (_buffer.length > 5) {
      SegmentationResult oldestResult = _buffer.removeAt(0);
      String outgoingClass = oldestResult.viewClass;

      if (_classCounts.containsKey(outgoingClass)) {
        _classCounts[outgoingClass] = _classCounts[outgoingClass]! - 1;
      }
    }

    if (_buffer.length == 5) {
      double smoothedArea = 0;
      for (int i = 0; i < 5; i++) {
        smoothedArea += _buffer[i].maskArea * _coeffs[i];
      }
      smoothedArea = smoothedArea / _norm;

      String majorityClass = '';
      int maxVotes = -1;
      for (var entry in _classCounts.entries) {
        if (entry.value > maxVotes) {
          maxVotes = entry.value;
          majorityClass = entry.key;
        }
      }

      SegmentationResult centerResult = _buffer[2];

      return SegmentationResult(
        maskBytes: centerResult.maskBytes,
        maskImage: centerResult.maskImage,
        inferenceMs: centerResult.inferenceMs,
        viewClass: majorityClass,
        maskArea: smoothedArea.round(),
      );
    }

    return null;
  }
}
