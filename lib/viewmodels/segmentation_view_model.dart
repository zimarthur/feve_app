import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../controllers/feve_session_controller.dart';
import '../models/frame_metrics.dart';
import '../models/segmentation_result.dart';
import '../services/segmentation_service.dart';

class SegmentationViewModel extends ChangeNotifier {
  SegmentationViewModel({
    SegmentationService? segmentationService,
    FeveSessionController? feveSessionController,
  }) : _segmentationService = segmentationService ?? SegmentationService(),
       _feveSessionController = feveSessionController ?? FeveSessionController();

  final SegmentationService _segmentationService;
  final FeveSessionController _feveSessionController;

  int _currentFrame = 0;
  final int _maxFrames = 12;
  ui.Image? _maskImage;
  String? _lastViewClass;
  final Map<int, FrameMetrics> _metricsByFrame = {};
  bool _isLoading = false;

  int get currentFrame => _currentFrame;
  int get maxFrames => _maxFrames;
  ui.Image? get maskImage => _maskImage;
  String? get lastViewClass => _lastViewClass;
  int? get currentFrameMaskArea => _metricsByFrame[_currentFrame]?.maskArea;
  int? get currentFrameInferenceMs => _metricsByFrame[_currentFrame]?.inferenceMs;
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

      final SegmentationResult? segmentationResult = await _segmentationService
          .segmentImage(
        imageBytes,
      );

      if (segmentationResult != null) {
        final maskArea = _countMaskArea(segmentationResult.maskBytes);
        _metricsByFrame[_currentFrame] = FrameMetrics(
          maskArea: maskArea,
          inferenceMs: segmentationResult.inferenceMs,
        );
        _lastViewClass = segmentationResult.viewClass;
        _feveSessionController.addRecord(
          frameIndex: _currentFrame,
          viewClass: segmentationResult.viewClass,
          maskBytes: segmentationResult.maskBytes,
        );
        final uiImage = await _createMaskImage(
          segmentationResult.maskBytes,
          256,
          256,
        );
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

  int _countMaskArea(Uint8List maskBytes) {
    var area = 0;
    for (final pixel in maskBytes) {
      if (pixel > 0) {
        area++;
      }
    }
    return area;
  }
}
