class FrameMetrics {
  const FrameMetrics({required this.maskArea, required this.inferenceMs, required this.window});

  final int maskArea;
  final int inferenceMs;
  final String window;
}
