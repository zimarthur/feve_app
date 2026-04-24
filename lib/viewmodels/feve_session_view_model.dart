import 'dart:async';
import 'dart:typed_data';
import 'package:feve_app/models/segmentation_result.dart';
import 'package:feve_app/services/segmentation_service.dart';
import 'package:feve_app/viewmodels/frames_view_model.dart';
import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import '../models/picked_image_data.dart';

class FeveSessionViewModel extends ChangeNotifier {
  final FramesViewModel _framesViewModel;
  final SegmentationService _segmentationService;

  FeveSessionViewModel(this._framesViewModel, this._segmentationService);

  int currentFrameIndex = 0;
  List<PickedImageData> get selectedImages => _framesViewModel.selectedImages;

  PickedImageData? get currentImage =>
      selectedImages.isNotEmpty ? selectedImages[currentFrameIndex] : null;

  SegmentationResult? get currentResult =>
      currentImage != null ? results[currentImage!.name] : null;

  final int fps = 15;
  bool _isPlaying = false;
  bool get isPlaying => _isPlaying;

  Map<String, SegmentationResult> results = {};

  void play() async {
    if (selectedImages.isEmpty || _isPlaying) return;

    _isPlaying = true;
    results.clear();
    notifyListeners();

    final frameDuration = Duration(milliseconds: 1000 ~/ fps);
    for (int i = 0; i < selectedImages.length; i++) {
      if (!_isPlaying) break;
      currentFrameIndex = i;
      runSegmentation(selectedImages[i]);
      await Future.delayed(frameDuration);
    }
    _isPlaying = false;
    notifyListeners();
  }

  void runSegmentation(PickedImageData image) async {
    final result = await _segmentationService.segmentImage(image.bytes);
    if (result == null) return;
    results[image.name] = result;
    notifyListeners();
  }

  Future<ui.Image> bytesToImage(Uint8List rgbaBytes, int width, int height) {
    final Completer<ui.Image> completer = Completer();

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

  void stop() {
    if (!_isPlaying) return;
    _isPlaying = false;
    notifyListeners();
  }

  void reset() {
    stop();
    currentFrameIndex = 0;
    notifyListeners();
  }
}
