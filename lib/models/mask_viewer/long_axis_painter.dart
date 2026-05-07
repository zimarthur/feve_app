import 'package:flutter/material.dart';
import 'dart:ui' as ui;

import '../geometry_extraction.dart';

class LongAxisPainter extends CustomPainter {
  final ui.Image maskImage;
  final LongAxisData longAxisData;

  LongAxisPainter({required this.maskImage, required this.longAxisData});

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Redimensionar a máscara para o tamanho real do Canvas na tela
    final srcRect = Rect.fromLTWH(
      0,
      0,
      maskImage.width.toDouble(),
      maskImage.height.toDouble(),
    );
    final dstRect = Rect.fromLTWH(0, 0, size.width, size.height);

    // Desenhando a imagem escalada
    canvas.drawImageRect(maskImage, srcRect, dstRect, Paint());

    // 2. Calcular o Fator de Escala
    // (Tamanho do Canvas na Tela / Tamanho Original da Máscara)
    final scaleX = size.width / 256.0;
    final scaleY = size.height / 256.0;

    // 3. Multiplicar as coordenadas calculadas pelo fator de escala
    final scaledApex = Offset(
      longAxisData.apex.dx * scaleX,
      longAxisData.apex.dy * scaleY,
    );
    final scaledBaseCenter = Offset(
      longAxisData.baseCenter.dx * scaleX,
      longAxisData.baseCenter.dy * scaleY,
    );

    // 4. Configurar pincéis
    final linePaint = Paint()
      ..color = Colors.green
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    final dotPaint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.fill;

    canvas.drawLine(scaledApex, scaledBaseCenter, linePaint);
    canvas.drawCircle(scaledApex, 2.0, dotPaint);
    canvas.drawCircle(scaledBaseCenter, 2.0, dotPaint);
  }

  @override
  bool shouldRepaint(covariant LongAxisPainter oldDelegate) {
    return oldDelegate.maskImage != maskImage ||
        oldDelegate.longAxisData != longAxisData;
  }
}
