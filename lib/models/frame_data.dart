import 'dart:typed_data';

class FrameData {
  FrameData({required this.path, required this.index});

  final String path;
  final int index;
  Uint8List? bytes;
}
