import 'dart:math';

import 'package:feve_app/models/cardiac_cycle.dart';
import 'package:feve_app/models/feve_result.dart';
import 'package:feve_app/models/feve_status.dart';
import 'package:feve_app/models/frame_data.dart';
import 'package:feve_app/models/geometry_extraction.dart';
import 'package:feve_app/models/left_ventricule_data.dart';
import 'package:feve_app/models/savitz_golay_filter.dart';
import 'package:feve_app/models/segmentation_result.dart';
import 'package:feve_app/services/segmentation_service.dart';

class FeveController {
  final SegmentationService _segmentationService;

  FeveController(this._segmentationService);

  Map<String, SegmentationResult?> minResults = {};
  Map<String, SegmentationResult?> maxResults = {};

  SavitzkyGolayFilter _sgFilter = SavitzkyGolayFilter();

  Future<FeveStatus> segmentFrame(String patient, FrameData frame) async {
    final result = await _segmentationService.segmentImage(frame.bytes!);
    if (result == null) {
      return FeveError(segmentationResult: result);
    }

    final smoothResult = _sgFilter.process(result);
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

  Future<FeveResult> onFinishCycle() async {
    FeveResult finalResult = FeveResult();

    finalResult.maxResults = maxResults.map((key, value) {
      final lgAxisData = VentricleGeometryExtractor.extractLongAxis(
        value!.maskBytes,
      );
      final disks = VentricleGeometryExtractor.extractDisks(
        apex: lgAxisData!.apex,
        baseCenter: lgAxisData.baseCenter,
        maskBytes: value.maskBytes,
      );
      lgAxisData.disks = disks;

      return MapEntry(
        key,
        LeftVentriculeData(segmentationResult: value, longAxisData: lgAxisData),
      );
    });

    finalResult.minResults = minResults.map((key, value) {
      final lgAxisData = VentricleGeometryExtractor.extractLongAxis(
        value!.maskBytes,
      );
      final disks = VentricleGeometryExtractor.extractDisks(
        apex: lgAxisData!.apex,
        baseCenter: lgAxisData.baseCenter,
        maskBytes: value.maskBytes,
      );
      lgAxisData.disks = disks;
      return MapEntry(
        key,
        LeftVentriculeData(segmentationResult: value, longAxisData: lgAxisData),
      );
    });
    finalResult.ejectionFraction = calculateEjectionFraction(finalResult);
    return finalResult;
  }

  double calculateEjectionFraction(FeveResult result) {
    double calculateVolume(Map<String, LeftVentriculeData> data) {
      final a4c = data['A4C']!.longAxisData;
      final a2c = data['A2C']!.longAxisData;

      final lengthA4c = (a4c.apex - a4c.baseCenter).distance;
      final lengthA2c = (a2c.apex - a2c.baseCenter).distance;
      final averageLength = (lengthA4c + lengthA2c) / 2;

      final n = a4c.disks.length;
      if (n == 0) return 0.0;

      final h = averageLength / n;
      double volume = 0;

      for (int i = 0; i < n; i++) {
        final d4c = a4c.disks[i].diameter;
        final d2c = a2c.disks[i].diameter;
        volume += (pi / 4) * d4c * d2c * h;
      }

      return volume;
    }

    if (result.maxResults == null || result.minResults == null) return 0.0;

    final edv = calculateVolume(result.maxResults!);
    final esv = calculateVolume(result.minResults!);

    if (edv == 0) return 0.0;

    return ((edv - esv) / edv) * 100;
  }

  void reset({bool clearCycles = true}) {
    _sgFilter = SavitzkyGolayFilter();
  }
}
