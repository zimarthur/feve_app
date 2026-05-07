import 'dart:ui';
import 'dart:typed_data';

class LongAxisData {
  final Offset apex;
  final Offset baseCenter;

  LongAxisData({required this.apex, required this.baseCenter});
}

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
}
