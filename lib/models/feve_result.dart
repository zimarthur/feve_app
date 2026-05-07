import 'package:feve_app/models/segmentation_result.dart';

class FeveResult {
  final Map<String, SegmentationResult> segmentationResults;

  Map<String, SegmentationResult>? minResults;
  Map<String, SegmentationResult>? maxResults;
  double get meanInfTime {
    if (segmentationResults.isEmpty) return 0.0;
    final totalTime = segmentationResults.values
        .map((result) => result.inferenceMs)
        .reduce((a, b) => a + b);
    return totalTime / segmentationResults.length;
  }

  FeveResult({required this.segmentationResults});
}
