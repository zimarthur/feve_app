import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:feve_app/controllers/feve_controller.dart';
import 'package:feve_app/models/patient.dart';
import 'package:feve_app/viewmodels/patients_view_model.dart';
import 'package:flutter/material.dart';
import '../models/frame_data.dart';
import '../models/segmentation_result.dart';

class FeveSessionViewModel extends ChangeNotifier {
  final PatientsViewModel _patientsViewModel;
  final FeveController _feveController;

  FeveSessionViewModel(this._patientsViewModel, this._feveController);

  Patient? selectedPatient;
  EchocardiogramView? get selectedPatient2CH => selectedPatient?.view2CH;
  EchocardiogramView? get selectedPatient4CH => selectedPatient?.view4CH;

  EchocardiogramView? get currentView =>
      isShowing2CH ? selectedPatient?.view2CH : selectedPatient?.view4CH;
  bool isShowing2CH = true;
  int frameIndex = 0;

  FrameData? get currentFrame {
    if (currentView == null) return null;

    if (frameIndex < 0 || frameIndex >= currentView!.frames.length) return null;
    return currentView!.frames[frameIndex];
  }

  bool isLoading = false;

  Future<void> selectPatient(String patientId) async {
    if (_patientsViewModel.patientIds.contains(patientId)) {
      isLoading = true;
      notifyListeners();
      selectedPatient = _patientsViewModel.patientMap[patientId];
      await loadFrameBytes(selectedPatient!.view2CH);
      await loadFrameBytes(selectedPatient!.view4CH);
      frameIndex = 0;
      isShowing2CH = false;
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadFrameBytes(EchocardiogramView view) async {
    view.frames.sort((a, b) => a.index.compareTo(b.index));
    for (final frame in view.frames) {
      final bytes = await File(frame.path).readAsBytes();
      frame.bytes = bytes;
    }
  }

  Map<String, Map<String, SegmentationResult>> segmentationsResults = {};

  SegmentationResult? get currentSegmentationResult =>
      segmentationsResults[selectedPatient?.id]?[currentFrame?.path];

  final int fps = 1;
  bool _isPlaying = false;
  bool get isPlaying => _isPlaying;

  void play() async {
    if (currentView?.frames.isEmpty == true || _isPlaying) return;

    _isPlaying = true;
    _feveController.reset();
    segmentationsResults.putIfAbsent(selectedPatient!.id, () => {});
    segmentationsResults[selectedPatient!.id]?.clear();
    notifyListeners();

    final frameDuration = Duration(milliseconds: 1000 ~/ fps);
    for (int x = 0; x < 1; x++) {
      for (int i = 0; i < currentView!.frames.length; i++) {
        if (!_isPlaying) break;
        frameIndex = i;
        final feveStatus = await _feveController.segmentFrame(
          selectedPatient!.id,
          currentView!.frames[i],
        );

        segmentationsResults[selectedPatient!.id]![currentView!
                .frames[i]
                .path] =
            feveStatus.segmentationResult!;

        notifyListeners();
        await Future.delayed(frameDuration);
      }
    }

    _isPlaying = false;
    notifyListeners();
  }

  void stop() {
    if (!_isPlaying) return;
    _isPlaying = false;
    notifyListeners();
  }

  void reset() {
    stop();
    frameIndex = 0;
    notifyListeners();
  }

  void setFrame(int index) {
    if (index < 0 || index >= currentView!.frames.length) return;
    frameIndex = index;
    notifyListeners();
  }

  void goToNextPatient() {
    if (selectedPatient == null) return;
    final currentIndex = _patientsViewModel.patientIds.indexOf(
      selectedPatient!.id,
    );
    if (currentIndex < _patientsViewModel.patientIds.length - 1) {
      selectPatient(_patientsViewModel.patientIds[currentIndex + 1]);
    }
  }

  void goToPreviousPatient() {
    if (selectedPatient == null) return;
    final currentIndex = _patientsViewModel.patientIds.indexOf(
      selectedPatient!.id,
    );
    if (currentIndex > 0) {
      selectPatient(_patientsViewModel.patientIds[currentIndex - 1]);
    }
  }
}
