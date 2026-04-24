import 'dart:typed_data';
import 'dart:ui' as ui;

class SegmentationResult {
  const SegmentationResult({
    required this.maskBytes,
    required this.viewClass,
    required this.inferenceMs,
    required this.maskArea,
    required this.maskImage,
  });

  final Uint8List maskBytes;
  final String viewClass;
  final int inferenceMs;
  final int maskArea;
  final ui.Image maskImage;
}
