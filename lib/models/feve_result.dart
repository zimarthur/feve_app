import 'package:feve_app/models/left_ventricule_data.dart';
import 'package:feve_app/models/segmentation_result.dart';

class FeveResult {
  Map<String, LeftVentriculeData>? minResults;
  Map<String, LeftVentriculeData>? maxResults;

  double? ejectionFraction;
}
