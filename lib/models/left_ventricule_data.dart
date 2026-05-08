import 'package:feve_app/models/geometry_extraction.dart';
import 'package:feve_app/models/segmentation_result.dart';

import 'long_axis_data.dart';

class LeftVentriculeData {
  final SegmentationResult segmentationResult;
  final LongAxisData longAxisData;

  LeftVentriculeData({
    required this.segmentationResult,
    required this.longAxisData,
  });
}
