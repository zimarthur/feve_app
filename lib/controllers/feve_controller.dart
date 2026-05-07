import 'package:feve_app/models/cardiac_cycle.dart';
import 'package:feve_app/models/feve_status.dart';
import 'package:feve_app/models/frame_data.dart';
import 'package:feve_app/models/savitz_golay_filter.dart';
import 'package:feve_app/models/segmentation_result.dart';
import 'package:feve_app/services/segmentation_service.dart';

class FeveController {
  final SegmentationService _segmentationService;

  FeveController(this._segmentationService);

  Map<String, SegmentationResult?> minResults = {};
  Map<String, SegmentationResult?> maxResults = {};

  SavitzkyGolayFilter sgFilter = SavitzkyGolayFilter();

  Future<FeveStatus> segmentFrame(String patient, FrameData frame) async {
    final result = await _segmentationService.segmentImage(frame.bytes!);
    if (result == null) {
      return FeveError(segmentationResult: result);
    }

    final smoothResult = sgFilter.process(result);
    if (smoothResult != null) {
      final viewClass = smoothResult.viewClass;

      if (minResults[viewClass] == null ||
          smoothResult.maskArea < minResults[viewClass]!.maskArea) {
        minResults[viewClass] = smoothResult;
      }

      if (maxResults[viewClass] == null ||
          smoothResult.maskArea > maxResults[viewClass]!.maskArea) {
        maxResults[viewClass] = smoothResult;
      }
    }
    return FeveCalculating(segmentationResult: result);
  }

  void reset({bool clearCycles = true}) {
    sgFilter = SavitzkyGolayFilter();
  }
}
