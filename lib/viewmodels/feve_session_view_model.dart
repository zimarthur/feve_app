import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:feve_app/controllers/feve_controller.dart';
import 'package:feve_app/enum/menu.dart';
import 'package:feve_app/models/feve_result.dart';
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
  bool isShowingMask = true;

  Menu selectedMenu = Menu.data;

  Future<void> selectPatient(String patientId) async {
    if (_patientsViewModel.patientIds.contains(patientId)) {
      isLoading = true;
      _isPlaying = false;
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

  Map<String, FeveResult> segmentationsResults = {};

  FeveResult? get currentFeveResult =>
      segmentationsResults[selectedPatient?.id];
  SegmentationResult? get currentSegmentationResult =>
      currentFeveResult?.segmentationResults[currentFrame?.path];

  final int fps = 1;
  bool _isPlaying = false;
  bool get isPlaying => _isPlaying;

  bool _isPlayingAllPatients = false;
  bool get isPlayingAllPatients => _isPlayingAllPatients;

  Future<void> play() async {
    if (currentView?.frames.isEmpty == true || _isPlaying) return;

    _isPlaying = true;
    _feveController.reset();
    segmentationsResults.putIfAbsent(
      selectedPatient!.id,
      () => FeveResult(segmentationResults: {}),
    );
    segmentationsResults[selectedPatient!.id]?.segmentationResults.clear();
    notifyListeners();

    isShowing2CH = true;
    await loopFrames();
    isShowing2CH = false;
    await loopFrames();

    final a2cMin = _feveController.minResults['A2C'];
    final a2cMax = _feveController.maxResults['A2C'];
    final a4cMin = _feveController.minResults['A4C'];
    final a4cMax = _feveController.maxResults['A4C'];
    if (a2cMin != null && a2cMax != null && a4cMin != null && a4cMax != null) {
      segmentationsResults[selectedPatient!.id]?.minResults = {
        'A2C': a2cMin,
        'A4C': a4cMin,
      };
      segmentationsResults[selectedPatient!.id]?.maxResults = {
        'A2C': a2cMax,
        'A4C': a4cMax,
      };
    }
    _isPlaying = false;
    notifyListeners();
  }

  Future<void> loopFrames() async {
    final frameDuration = Duration(
      milliseconds: 1000 ~/ currentView!.metadata!.frameRate,
    );
    for (int x = 0; x < 1; x++) {
      for (int i = 0; i < currentView!.frames.length; i++) {
        if (!_isPlaying) break;
        frameIndex = i;
        final feveStatus = await _feveController.segmentFrame(
          selectedPatient!.id,
          currentView!.frames[i],
        );
        print("TEST ${feveStatus.segmentationResult?.viewClass}");
        segmentationsResults[selectedPatient?.id]
                ?.segmentationResults[currentView!.frames[i].path] =
            feveStatus.segmentationResult!;

        notifyListeners();
        await Future.delayed(frameDuration);
      }
    }
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
    double totalSum = 0;
    for (var res in segmentationsResults.values) {
      totalSum += res.meanInfTime;
      print("RESULTS: ${res.meanInfTime}");
    }
    print("TOTAL SUM: ${totalSum / segmentationsResults.length}");
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

  void toggleMask() {
    isShowingMask = !isShowingMask;
    notifyListeners();
  }

  void setSelectedMenu(Menu menu) {
    selectedMenu = menu;
    notifyListeners();
  }

  Future<void> runOnAllPatients() async {
    if (isPlayingAllPatients) {
      _isPlayingAllPatients = false;
      notifyListeners();
      return;
    }
    if (_isPlaying || isLoading) return;
    _isPlayingAllPatients = true;
    notifyListeners();
    for (final patientId in _patientsViewModel.patientIds) {
      await selectPatient(patientId);
      await play();
    }
    _isPlayingAllPatients = false;
    notifyListeners();
  }
}
