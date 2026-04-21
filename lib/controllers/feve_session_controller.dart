import 'package:flutter/foundation.dart';
import '../models/feve_frame_record.dart';
import '../models/feve_min_max.dart';

class FeveSessionController extends ChangeNotifier {
  final List<FeveFrameRecord> _records = [];
  final Map<String, FeveFrameRecord> _minByView = {};
  final Map<String, FeveFrameRecord> _maxByView = {};

  List<FeveFrameRecord> get records => List.unmodifiable(_records);

  FeveMinMax? getExtremaForView(String viewClass) {
    final minRecord = _minByView[viewClass];
    final maxRecord = _maxByView[viewClass];
    if (minRecord == null || maxRecord == null) {
      return null;
    }
    return FeveMinMax(minRecord: minRecord, maxRecord: maxRecord);
  }

  void addRecord({
    required int frameIndex,
    required String viewClass,
    required Uint8List maskBytes,
    String? modelName,
  }) {
    final maskArea = _countPositivePixels(maskBytes);
    final record = FeveFrameRecord(
      frameIndex: frameIndex,
      viewClass: viewClass,
      maskArea: maskArea,
      modelName: modelName,
    );

    _records.add(record);
    _updateExtrema(record);
    notifyListeners();
  }

  void clearSession() {
    _records.clear();
    _minByView.clear();
    _maxByView.clear();
    notifyListeners();
  }

  int _countPositivePixels(Uint8List maskBytes) {
    var area = 0;
    for (final value in maskBytes) {
      if (value > 0) {
        area++;
      }
    }
    return area;
  }

  void _updateExtrema(FeveFrameRecord record) {
    final minRecord = _minByView[record.viewClass];
    final maxRecord = _maxByView[record.viewClass];

    if (minRecord == null || record.maskArea < minRecord.maskArea) {
      _minByView[record.viewClass] = record;
    }
    if (maxRecord == null || record.maskArea > maxRecord.maskArea) {
      _maxByView[record.viewClass] = record;
    }
  }
}
