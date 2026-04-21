import 'dart:typed_data';

class SegmentationResult {
  const SegmentationResult({
    required this.maskBytes,
    required this.viewClass,
    required this.inferenceMs,
  });

  final Uint8List maskBytes;
  final String viewClass;
  final int inferenceMs;
}
