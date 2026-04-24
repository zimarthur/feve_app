import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';

import '../models/picked_image_data.dart';

class ImagePickerService {
  static const List<String> _allowedExtensions = ['png', 'jpg', 'jpeg', 'webp'];

  Future<List<PickedImageData>> pickImages() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowMultiple: true,
      allowedExtensions: _allowedExtensions,
      withData: true,
    );

    if (result == null) {
      return [];
    }

    final pickedImages = <PickedImageData>[];
    for (final file in result.files) {
      final bytes = await _resolveBytes(file);
      if (bytes == null || bytes.isEmpty) {
        continue;
      }
      pickedImages.add(PickedImageData(name: file.name, bytes: bytes));
    }

    return pickedImages;
  }

  Future<Uint8List?> _resolveBytes(PlatformFile file) async {
    if (file.bytes != null) {
      return file.bytes;
    }

    if (kIsWeb || file.path == null) {
      return null;
    }

    return File(file.path!).readAsBytes();
  }
}
