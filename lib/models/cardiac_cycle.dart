import 'package:feve_app/models/segmentation_result.dart';

class CardiacCycle {
  CardiacCycle({required this.maxVolumePoint, required this.minVolumePoint});

  SegmentationResult maxVolumePoint;
  SegmentationResult minVolumePoint;
}
