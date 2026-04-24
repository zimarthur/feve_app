// import 'dart:async';
// import 'dart:ui' as ui;
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import '../controllers/feve_session_controller.dart';
// import '../models/frame_metrics.dart';
// import '../models/picked_image_data.dart';
// import '../models/segmentation_result.dart';
// import '../services/image_picker_service.dart';
// import '../services/segmentation_service.dart';

// class SegmentationViewModel extends ChangeNotifier {
//   SegmentationViewModel({
//     SegmentationService? segmentationService,
//     FeveSessionController? feveSessionController,
//     ImagePickerService? imagePickerService,
//   }) : _segmentationService = segmentationService ?? SegmentationService(),
//        _feveSessionController =
//            feveSessionController ?? FeveSessionController(),
//        _imagePickerService = imagePickerService ?? ImagePickerService();

//   final SegmentationService _segmentationService;
//   final FeveSessionController _feveSessionController;
//   final ImagePickerService _imagePickerService;

//   int _currentFrame = 0;
//   List<PickedImageData> _selectedImages = [];
//   ui.Image? _maskImage;
//   String? _lastViewClass;
//   final Map<int, FrameMetrics> _metricsByFrame = {};
//   bool _isLoading = false;

//   int get currentFrame => _currentFrame;
//   int get maxFrames => _selectedImages.isEmpty ? 0 : _selectedImages.length - 1;
//   int get selectedImagesCount => _selectedImages.length;
//   bool get hasSelectedImages => _selectedImages.isNotEmpty;
//   ui.Image? get maskImage => _maskImage;
//   String? get lastViewClass => _lastViewClass;
//   int? get currentFrameMaskArea => _metricsByFrame[_currentFrame]?.maskArea;
//   String? get currentFrameWindow => _metricsByFrame[_currentFrame]?.window;
//   int? get currentFrameInferenceMs =>
//       _metricsByFrame[_currentFrame]?.inferenceMs;
//   bool get isLoading => _isLoading;
//   String? get currentImageName =>
//       hasSelectedImages ? _selectedImages[_currentFrame].name : null;

//   Future<bool> pickImages() async {
//     final pickedImages = await _imagePickerService.pickImages();
//     if (pickedImages.isEmpty) {
//       return false;
//     }

//     _selectedImages = pickedImages;
//     _currentFrame = 0;
//     _maskImage = null;
//     _lastViewClass = null;
//     _metricsByFrame.clear();
//     _feveSessionController.clearSession();
//     notifyListeners();
//     return true;
//   }

//   Uint8List? getCurrentImageBytes() {
//     if (!hasSelectedImages) {
//       return null;
//     }
//     return _selectedImages[_currentFrame].bytes;
//   }

//   void nextFrame() {
//     if (_currentFrame < maxFrames) {
//       _currentFrame++;
//       _maskImage = null;
//       notifyListeners();
//     }
//   }

//   void previousFrame() {
//     if (_currentFrame > 0) {
//       _currentFrame--;
//       _maskImage = null;
//       notifyListeners();
//     }
//   }

//   Future<void> segmentCurrentImage(BuildContext context) async {
//     final imageBytes = getCurrentImageBytes();
//     if (imageBytes == null) {
//       if (context.mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text('Selecione pelo menos uma imagem para segmentar.'),
//           ),
//         );
//       }
//       return;
//     }

//     _isLoading = true;
//     notifyListeners();

//     try {
//       final SegmentationResult? segmentationResult = await _segmentationService
//           .segmentImage(imageBytes);

//       if (segmentationResult != null) {
//         final maskArea = _countMaskArea(segmentationResult.maskBytes);
//         _metricsByFrame[_currentFrame] = FrameMetrics(
//           maskArea: maskArea,
//           inferenceMs: segmentationResult.inferenceMs,
//           window: segmentationResult.viewClass,
//         );
//         _lastViewClass = segmentationResult.viewClass;
//         _feveSessionController.addRecord(
//           frameIndex: _currentFrame,
//           viewClass: segmentationResult.viewClass,
//           maskBytes: segmentationResult.maskBytes,
//         );
//         final uiImage = await _createMaskImage(
//           segmentationResult.maskBytes,
//           256,
//           256,
//         );
//         _maskImage = uiImage;
//       }
//     } on PlatformException catch (e) {
//       if (context.mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text("Erro na segmentação: ${e.message}")),
//         );
//       }
//     } finally {
//       _isLoading = false;
//       notifyListeners();
//     }
//   }

//   Future<ui.Image> _createMaskImage(Uint8List rawBytes, int width, int height) {
//     final Completer<ui.Image> completer = Completer();
//     final rgbaBytes = Uint8List(width * height * 4);

//     for (int i = 0; i < rawBytes.length; i++) {
//       final pixel = rawBytes[i];
//       final offset = i * 4;

//       rgbaBytes[offset] = pixel; // R
//       rgbaBytes[offset + 1] = 0; // G
//       rgbaBytes[offset + 2] = 0; // B
//       rgbaBytes[offset + 3] = pixel == 255 ? 64 : 0; // A
//     }

//     ui.decodeImageFromPixels(
//       rgbaBytes,
//       width,
//       height,
//       ui.PixelFormat.rgba8888,
//       (ui.Image img) {
//         completer.complete(img);
//       },
//     );

//     return completer.future;
//   }

//   int _countMaskArea(Uint8List maskBytes) {
//     var area = 0;
//     for (final pixel in maskBytes) {
//       if (pixel > 0) {
//         area++;
//       }
//     }
//     return area;
//   }
// }
