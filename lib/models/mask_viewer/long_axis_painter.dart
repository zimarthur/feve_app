import 'package:flutter/material.dart';
import 'dart:ui' as ui;

import '../left_ventricule_data.dart';

class LongAxisPainter extends CustomPainter {
  final ui.Image maskImage;
  final LeftVentriculeData leftVentriculeData;

  LongAxisPainter({required this.maskImage, required this.leftVentriculeData});

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
      leftVentriculeData.longAxisData.apex.dx * scaleX,
      leftVentriculeData.longAxisData.apex.dy * scaleY,
    );
    final scaledBaseCenter = Offset(
      leftVentriculeData.longAxisData.baseCenter.dx * scaleX,
      leftVentriculeData.longAxisData.baseCenter.dy * scaleY,
    );

    // 4. Configurar pincéis
    final linePaint = Paint()
      ..color = Colors.green
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    final dotPaint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.fill;

    // Desenha o eixo longo
    canvas.drawLine(scaledApex, scaledBaseCenter, linePaint);
    canvas.drawCircle(scaledApex, 2.0, dotPaint);
    canvas.drawCircle(scaledBaseCenter, 2.0, dotPaint);

    // 5. Desenhar apenas o primeiro disco (se existir)
    for (
      int diskIndex = 0;
      diskIndex < leftVentriculeData.longAxisData.disks.length;
      diskIndex++
    ) {
      final disk = leftVentriculeData.longAxisData.disks[diskIndex];

      // Aplica a mesma escala nos pontos do disco
      final scaledPoint1 = Offset(
        disk.point1.dx * scaleX,
        disk.point1.dy * scaleY,
      );
      final scaledPoint2 = Offset(
        disk.point2.dx * scaleX,
        disk.point2.dy * scaleY,
      );

      final diskPaint = Paint()
        ..color = Colors
            .blue // Azul para diferenciar do eixo longo
        ..strokeWidth = 1.5
        ..style = PaintingStyle.stroke;

      // Desenha a linha representando o disco¼
      canvas.drawLine(scaledPoint1, scaledPoint2, diskPaint);

      // Desenha as bolinhas nas bordas da máscara para esse disco
      canvas.drawCircle(scaledPoint1, 2.0, dotPaint);
      canvas.drawCircle(scaledPoint2, 2.0, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant LongAxisPainter oldDelegate) {
    return oldDelegate.maskImage != maskImage ||
        oldDelegate.leftVentriculeData != leftVentriculeData;
  }
}
