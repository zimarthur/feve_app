class FeveFrameRecord {
  const FeveFrameRecord({
    required this.frameIndex,
    required this.viewClass,
    required this.maskArea,
    this.modelName,
  });

  final int frameIndex;
  final String viewClass;
  final int maskArea;
  final String? modelName;
}
