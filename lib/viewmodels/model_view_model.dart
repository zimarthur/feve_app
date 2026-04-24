import 'package:flutter/material.dart';
import '../services/segmentation_service.dart';

class ModelViewModel extends ChangeNotifier {
  final SegmentationService _segmentationService;

  ModelViewModel(this._segmentationService);

  List<String> _modelNames = [];
  String? _selectedModel;

  bool isLoading = false;

  List<String> get modelNames => _modelNames;
  String? get selectedModel => _selectedModel;

  Future<void> loadModelNames() async {
    _modelNames = await _segmentationService.getModelNames();
    notifyListeners();
  }

  Future<void> selectModel(String modelName) async {
    isLoading = true;
    notifyListeners();
    await _segmentationService.selectModel(modelName);
    _selectedModel = modelName;
    isLoading = false;
    notifyListeners();
  }
}
