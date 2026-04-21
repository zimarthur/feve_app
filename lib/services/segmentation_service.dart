import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../models/segmentation_result.dart';

class SegmentationService {
  static const platform = MethodChannel('feve_channel');

  Future<List<String>> getModelNames() async {
    try {
      final List<dynamic> modelNames = await platform.invokeMethod(
        'getModelNames',
      );
      return modelNames.cast<String>();
    } on PlatformException catch (e) {
      debugPrint("Erro ao obter nomes dos modelos: '${e.message}'.");
      return [];
    }
  }

  Future<void> selectModel(String modelName) async {
    try {
      await platform.invokeMethod('selectModel', {'modelName': modelName});
    } on PlatformException catch (e) {
      debugPrint("Erro ao selecionar modelo: '${e.message}'.");
    }
  }

  Future<SegmentationResult?> segmentImage(Uint8List imageBytes) async {
    try {
      final Map<dynamic, dynamic>? payload = await platform.invokeMethod(
        'segmentImage',
        {
        'imageBytes': imageBytes,
      },
      );

      if (payload == null) {
        return null;
      }

      final Uint8List? maskBytes = payload['maskBytes'] as Uint8List?;
      final String? viewClass = payload['viewClass'] as String?;
      final int? inferenceMs = (payload['inferenceMs'] as num?)?.toInt();

      if (maskBytes == null || viewClass == null || inferenceMs == null) {
        return null;
      }

      return SegmentationResult(
        maskBytes: maskBytes,
        viewClass: viewClass,
        inferenceMs: inferenceMs,
      );
    } on PlatformException catch (e) {
      debugPrint("Erro na segmentação: '${e.message}'.");
      return null;
    }
  }
}
