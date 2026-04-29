import 'package:feve_app/models/segmentation_result.dart';

class CardiacCycle {
  const CardiacCycle({
    required this.maxVolumePoint,
    required this.minVolumePoint,
  });

  final SegmentationResult maxVolumePoint;
  final SegmentationResult minVolumePoint;
}
