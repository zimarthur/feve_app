import 'dart:math' as math;
import 'dart:ui';
import 'dart:typed_data';

import 'long_axis_data.dart';

class VentricleGeometryExtractor {
  static const int imageSize = 256;
  static const int totalPixels = imageSize * imageSize;
  static const int bytesPerPixel = 4;

  static LongAxisData? extractLongAxis(Uint8List maskBytes) {
    if (maskBytes.length != totalPixels * bytesPerPixel) {
      throw ArgumentError(
        'A máscara deve ter exatamente 256x256 pixels em formato RGBA (262144 bytes).',
      );
    }

    int maxY = -1;

    bool isMaskPixel(int pixelIndex) {
      int byteIndex = pixelIndex * bytesPerPixel;
      return maskBytes[byteIndex + 3] > 0;
    }

    // --- PASSO 1: Encontrar o limite inferior da máscara (maior Y) ---
    for (int p = 0; p < totalPixels; p++) {
      if (isMaskPixel(p)) {
        int y = p ~/ imageSize;
        if (y > maxY) {
          maxY = y;
        }
      }
    }

    if (maxY == -1) return null; // Máscara vazia

    // --- PASSO 2: Encontrar o centro da Base (Anel Mitral) ---
    int yThreshold = maxY - 5;

    int baseMinX = imageSize;
    int baseMaxX = -1;
    int baseSumY = 0;
    int baseCount = 0;

    for (int p = 0; p < totalPixels; p++) {
      if (isMaskPixel(p)) {
        int y = p ~/ imageSize;
        int x = p % imageSize;

        if (y >= yThreshold) {
          if (x < baseMinX) baseMinX = x;
          if (x > baseMaxX) baseMaxX = x;
          baseSumY += y;
          baseCount++;
        }
      }
    }

    double baseCenterX = (baseMinX + baseMaxX) / 2.0;
    double baseCenterY = baseSumY / baseCount;
    Offset baseCenter = Offset(baseCenterX, baseCenterY);

    // --- PASSO 3: Encontrar o Ápice Verdadeiro ---
    double maxDistanceSquared = -1;
    Offset apex = Offset.zero;

    for (int p = 0; p < totalPixels; p++) {
      if (isMaskPixel(p)) {
        int y = p ~/ imageSize;
        int x = p % imageSize;

        double dx = x - baseCenterX;
        double dy = y - baseCenterY;
        double distanceSquared = (dx * dx) + (dy * dy);

        if (distanceSquared > maxDistanceSquared) {
          maxDistanceSquared = distanceSquared;
          apex = Offset(x.toDouble(), y.toDouble());
        }
      }
    }

    return LongAxisData(apex: apex, baseCenter: baseCenter);
  }

  static List<VentricleDisk> extractDisks({
    required Offset apex,
    required Offset baseCenter,
    required Uint8List maskBytes,
    int maskWidth = 256,
    int maskHeight = 256,
    int numberOfDisks = 20,
  }) {
    List<VentricleDisk> disks = [];

    double dx = baseCenter.dx - apex.dx;
    double dy = baseCenter.dy - apex.dy;
    double axisLength = math.sqrt(dx * dx + dy * dy);

    Offset direction = baseCenter - apex;
    Offset normal = Offset(-direction.dy, direction.dx);
    double length = normal.distance;
    Offset unitNormal = normal / length;
    Offset oppositeUnitNormal = -unitNormal;

    if (axisLength == 0) return disks;

    for (int disk = 0; disk < numberOfDisks; disk++) {
      double pointMiddlePercentage = ((2 * disk + 1) / (2 * numberOfDisks))
          .abs();
      double xCenter =
          baseCenter.dx + pointMiddlePercentage * (apex.dx - baseCenter.dx);
      double yCenter =
          baseCenter.dy + pointMiddlePercentage * (apex.dy - baseCenter.dy);
      Offset center = Offset(xCenter, yCenter);
      double radius1 = findRadius(
        center,
        unitNormal,
        maskBytes,
        maskWidth,
        maskHeight,
      );
      double radius2 = findRadius(
        center,
        oppositeUnitNormal,
        maskBytes,
        maskWidth,
        maskHeight,
      );

      Offset left = center + (unitNormal * radius1);
      Offset right = center + (oppositeUnitNormal * radius2);
      disks.add(
        VentricleDisk(
          point1: left,
          point2: right,
          diameter: (left - right).distance,
        ),
      );
    }
    return disks;
  }

  static double findRadius(
    Offset centerPoint,
    Offset unitNormal,
    Uint8List mask,
    int width,
    int height,
  ) {
    double minRadius = 0.0;
    double maxRadius = width.toDouble();
    double threshold = 1;

    int centerX = centerPoint.dx.round();
    int centerY = centerPoint.dy.round();

    if (centerX >= 0 && centerX < width && centerY >= 0 && centerY < height) {
      int centerBaseIndex = ((centerY * width) + centerX) * 4;

      int centerOpacity = mask[centerBaseIndex + 3];

      if (centerOpacity == 0) {
        return 0.0;
      }
    }

    double currentRadius = maxRadius;
    while ((maxRadius - minRadius) > threshold) {
      currentRadius = minRadius + (maxRadius - minRadius) / 2;

      Offset checkPoint = centerPoint + (unitNormal * currentRadius);

      int x = checkPoint.dx.round();
      int y = checkPoint.dy.round();

      if (x < 0 || x >= width || y < 0 || y >= height) {
        maxRadius = currentRadius;
        continue;
      }

      int baseIndex = ((y * width) + x) * 4;

      int pixelOpacity = mask[baseIndex + 3];

      if (pixelOpacity > 0) {
        minRadius = currentRadius;
      } else {
        maxRadius = currentRadius;
      }
    }

    return currentRadius;
  }
}
