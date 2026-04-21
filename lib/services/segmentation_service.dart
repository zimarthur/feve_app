import 'package:flutter/services.dart';
import 'dart:typed_data';

class SegmentationService {
  static const platform = MethodChannel('feve_channel');

  Future<List<String>> getModelNames() async {
    try {
      final List<dynamic> modelNames = await platform.invokeMethod(
        'getModelNames',
      );
      return modelNames.cast<String>();
    } on PlatformException catch (e) {
      print("Erro ao obter nomes dos modelos: '${e.message}'.");
      return [];
    }
  }

  Future<void> selectModel(String modelName) async {
    try {
      await platform.invokeMethod('selectModel', {'modelName': modelName});
    } on PlatformException catch (e) {
      print("Erro ao selecionar modelo: '${e.message}'.");
    }
  }

  Future<Uint8List?> segmentImage(Uint8List imageBytes) async {
    try {
      // Envia os bytes para o Android nativo
      final Uint8List? maskBytes = await platform.invokeMethod('segmentImage', {
        'imageBytes': imageBytes,
      });

      return maskBytes;
    } on PlatformException catch (e) {
      print("Erro na segmentação: '${e.message}'.");
      return null;
    }
  }
}
