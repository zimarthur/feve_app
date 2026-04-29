import 'package:feve_app/models/segmentation_result.dart';

abstract class FeveStatus {
  final SegmentationResult? segmentationResult;

  FeveStatus({required this.segmentationResult});
}

class FeveCalculating extends FeveStatus {
  FeveCalculating({required super.segmentationResult});
}

class FeveError extends FeveStatus {
  FeveError({required super.segmentationResult});
}

class FeveComplete extends FeveStatus {
  final double feve;

  FeveComplete({required this.feve, required super.segmentationResult});
}
