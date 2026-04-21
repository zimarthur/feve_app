import 'package:flutter/material.dart';
import '../services/segmentation_service.dart';

class ModelViewModel extends ChangeNotifier {
  final SegmentationService _segmentationService = SegmentationService();

  List<String> _modelNames = [];
  String? _selectedModel;

  List<String> get modelNames => _modelNames;
  String? get selectedModel => _selectedModel;

  Future<void> loadModelNames() async {
    _modelNames = await _segmentationService.getModelNames();
    if (_modelNames.isNotEmpty && _selectedModel == null) {
      _selectedModel = _modelNames[0];
    }
    notifyListeners();
  }

  Future<void> selectModel(String modelName) async {
    await _segmentationService.selectModel(modelName);
    _selectedModel = modelName;
    notifyListeners();
  }
}
