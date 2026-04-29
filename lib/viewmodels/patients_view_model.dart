import 'dart:convert';
import 'dart:io';

import 'package:feve_app/models/frame_data.dart';
import 'package:feve_app/models/patient.dart';
import 'package:feve_app/services/image_picker_service.dart';
import 'package:flutter/material.dart';

class PatientsViewModel extends ChangeNotifier {
  final ImagePickerService _imagePickerService;
  PatientsViewModel(this._imagePickerService);

  Map<String, Patient> patientMap = {};
  List<String> get patientIds => patientMap.keys.toList();
  bool isLoading = false;

  Future<void> pickPatients() async {
    isLoading = true;
    patientMap.clear();
    notifyListeners();

    final paths = await _imagePickerService.pickImages();
    Map<String, dynamic> tempMetadata = {};

    for (final path in paths) {
      if (path.toLowerCase().endsWith('.json')) {
        final file = File(path);
        final content = await file.readAsString();
        tempMetadata = jsonDecode(content);
      } else {
        final fileName = path.split(Platform.pathSeparator).last;
        final parts = fileName.split('_');

        if (parts.length >= 3) {
          final patientId = parts[0];
          final viewType = parts[1];
          final framePart = parts[2];
          final frameIndex =
              int.tryParse(framePart.replaceAll('frame', '')) ?? 0;

          if (!patientMap.containsKey(patientId)) {
            patientMap[patientId] = Patient(
              id: patientId,
              view2CH: EchocardiogramView(),
              view4CH: EchocardiogramView(),
            );
          }

          final patient = patientMap[patientId]!;
          if (viewType == '2CH') {
            patient.view2CH.frames.add(
              FrameData(path: path, index: frameIndex),
            );
          } else {
            patient.view4CH.frames.add(
              FrameData(path: path, index: frameIndex),
            );
          }
        }
      }
    }
    patientMap.forEach((id, patient) {
      if (tempMetadata.containsKey(id)) {
        _applyMetadata(patient, tempMetadata[id]);
      }
    });
    isLoading = false;
    notifyListeners();
  }

  void _applyMetadata(Patient patient, Map<String, dynamic> data) {
    if (data.containsKey('2CH')) {
      patient.view2CH.metadata = EchoMetadata.fromJson(data['2CH']);
    }
    if (data.containsKey('4CH')) {
      patient.view4CH.metadata = EchoMetadata.fromJson(data['4CH']);
    }
  }
}
