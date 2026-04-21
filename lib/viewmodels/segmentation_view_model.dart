import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/segmentation_service.dart';

class SegmentationViewModel extends ChangeNotifier {
  final SegmentationService _segmentationService = SegmentationService();

  int _currentFrame = 0;
  final int _maxFrames = 12;
  ui.Image? _maskImage;
  bool _isLoading = false;

  int get currentFrame => _currentFrame;
  int get maxFrames => _maxFrames;
  ui.Image? get maskImage => _maskImage;
  bool get isLoading => _isLoading;

  String getCurrentAssetPath() =>
      'assets/feve_images/patient0451_2CH_frame${_currentFrame}_img.png';

  void nextFrame() {
    if (_currentFrame < _maxFrames) {
      _currentFrame++;
      _maskImage = null;
      notifyListeners();
    }
  }

  void previousFrame() {
    if (_currentFrame > 0) {
      _currentFrame--;
      _maskImage = null;
      notifyListeners();
    }
  }

  Future<void> segmentCurrentImage(BuildContext context) async {
    _isLoading = true;
    notifyListeners();

    try {
      final byteData = await rootBundle.load(getCurrentAssetPath());
      final imageBytes = byteData.buffer.asUint8List();

      final Uint8List? maskBytes = await _segmentationService.segmentImage(
        imageBytes,
      );

      if (maskBytes != null) {
        final uiImage = await _createMaskImage(maskBytes, 256, 256);
        _maskImage = uiImage;
      }
    } on PlatformException catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erro na segmentação: ${e.message}")),
        );
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<ui.Image> _createMaskImage(Uint8List rawBytes, int width, int height) {
    final Completer<ui.Image> completer = Completer();
    final rgbaBytes = Uint8List(width * height * 4);

    for (int i = 0; i < rawBytes.length; i++) {
      final pixel = rawBytes[i];
      final offset = i * 4;

      rgbaBytes[offset] = pixel; // R
      rgbaBytes[offset + 1] = 0; // G
      rgbaBytes[offset + 2] = 0; // B
      rgbaBytes[offset + 3] = pixel == 255 ? 64 : 0; // A
    }

    ui.decodeImageFromPixels(
      rgbaBytes,
      width,
      height,
      ui.PixelFormat.rgba8888,
      (ui.Image img) {
        completer.complete(img);
      },
    );

    return completer.future;
  }
}
