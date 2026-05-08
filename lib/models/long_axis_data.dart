import 'dart:ui';

class VentricleDisk {
  final Offset point1;
  final Offset point2;
  final double diameter;

  VentricleDisk({
    required this.point1,
    required this.point2,
    required this.diameter,
  });
}

class LongAxisData {
  final Offset apex;
  final Offset baseCenter;
  List<VentricleDisk> disks;

  LongAxisData({
    required this.apex,
    required this.baseCenter,
    this.disks = const [],
  });
}
