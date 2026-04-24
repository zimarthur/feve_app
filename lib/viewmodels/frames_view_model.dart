import 'package:feve_app/services/image_picker_service.dart';
import 'package:flutter/material.dart';

import '../models/picked_image_data.dart';

class FramesViewModel extends ChangeNotifier {
  final ImagePickerService _imagePickerService;
  FramesViewModel(this._imagePickerService);

  List<PickedImageData> _selectedImages = [];
  List<PickedImageData> get selectedImages => _selectedImages;

  bool isLoading = false;

  Future<void> pickImages() async {
    isLoading = true;
    _selectedImages.clear();
    notifyListeners();

    _selectedImages = await _imagePickerService.pickImages();
    isLoading = false;
    notifyListeners();
  }
}
