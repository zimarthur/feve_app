import 'package:feve_app/models/frame_data.dart';

class EchoMetadata {
  final int ed;
  final int es;
  final int nbFrame;
  final String sex;
  final int age;
  final String imageQuality;
  final double ef;
  final double frameRate;

  EchoMetadata({
    required this.ed,
    required this.es,
    required this.nbFrame,
    required this.sex,
    required this.age,
    required this.imageQuality,
    required this.ef,
    required this.frameRate,
  });

  factory EchoMetadata.fromJson(Map<String, dynamic> json) {
    return EchoMetadata(
      ed: int.tryParse(json['ED'].toString()) ?? 0,
      es: int.tryParse(json['ES'].toString()) ?? 0,
      nbFrame: int.tryParse(json['NbFrame'].toString()) ?? 0,
      sex: json['Sex'].toString(),
      age: int.tryParse(json['Age'].toString()) ?? 0,
      imageQuality: json['ImageQuality'].toString(),
      ef: double.tryParse(json['EF'].toString()) ?? 0.0,
      frameRate: double.tryParse(json['FrameRate'].toString()) ?? 0.0,
    );
  }
}

class EchocardiogramView {
  EchoMetadata? metadata;
  List<FrameData> frames = [];

  EchocardiogramView({this.metadata});
}

class Patient {
  final String id;
  final EchocardiogramView view2CH;
  final EchocardiogramView view4CH;

  String get name => "Paciente ${id.split("patient").last}";

  Patient({required this.id, required this.view2CH, required this.view4CH});
}
