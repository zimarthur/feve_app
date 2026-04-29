import 'package:file_picker/file_picker.dart';

class ImagePickerService {
  static const List<String> _allowedExtensions = [
    'png',
    'jpg',
    'jpeg',
    'webp',
    'json',
  ];

  Future<List<String>> pickImages() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowMultiple: true,
      allowedExtensions: _allowedExtensions,
      withData: true,
    );

    return result?.paths.whereType<String>().toList() ?? [];
  }
}
