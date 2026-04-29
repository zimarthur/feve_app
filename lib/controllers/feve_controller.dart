import 'package:feve_app/models/cardiac_cycle.dart';
import 'package:feve_app/models/feve_status.dart';
import 'package:feve_app/models/frame_data.dart';
import 'package:feve_app/models/segmentation_result.dart';
import 'package:feve_app/services/segmentation_service.dart';

class FeveController {
  final SegmentationService _segmentationService;

  FeveController(this._segmentationService);

  List<SegmentationResult> segmentationResults = [];

  List<CardiacCycle> cardiacCycles = [];
  SegmentationResult? currentCycleMax;
  SegmentationResult? currentCycleMin;
  bool isLookingForMax = true;

  Future<FeveStatus> segmentFrame(String patient, FrameData frame) async {
    final result = await _segmentationService.segmentImage(frame.bytes!);
    if (result == null) {
      return FeveError(segmentationResult: result);
    }
    print(
      '[LOG] New Area: ${result.maskArea} (MAX: ${currentCycleMax?.maskArea}, MIN: ${currentCycleMin?.maskArea})',
    );
    // validateCardiacCycle(result);
    return FeveCalculating(segmentationResult: result);
  }

  void validateCardiacCycle(SegmentationResult result) {
    if (isLookingForMax) {
      if (currentCycleMax == null ||
          result.maskArea > currentCycleMax!.maskArea) {
        print(
          '[LOG] Updated Max  ${currentCycleMax?.maskArea} -> ${result.maskArea}',
        );
        currentCycleMax = result;
        return;
      }
      print('[LOG] Found max ');
      isLookingForMax = false;
    }

    if (currentCycleMin == null ||
        result.maskArea < currentCycleMin!.maskArea) {
      currentCycleMin = result;
      print(
        '[LOG] Updated Min  ${currentCycleMin?.maskArea} -> ${result.maskArea}',
      );
      return;
    }
    print('[LOG] Found min ');
    cardiacCycles.add(
      CardiacCycle(
        maxVolumePoint: currentCycleMax!,
        minVolumePoint: currentCycleMin!,
      ),
    );
    reset(clearCycles: false);
  }

  void reset({bool clearCycles = true}) {
    if (clearCycles) {
      cardiacCycles.clear();
    }
    currentCycleMax = null;
    currentCycleMin = null;
    isLookingForMax = true;
  }
}
