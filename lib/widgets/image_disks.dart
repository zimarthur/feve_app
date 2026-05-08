import 'package:feve_app/models/left_ventricule_data.dart';
import 'package:flutter/material.dart';

import '../models/mask_viewer/long_axis_painter.dart';

class ImageDisks extends StatelessWidget {
  final String title;
  final LeftVentriculeData? ventricleData;
  const ImageDisks({super.key, required this.title, this.ventricleData});

  @override
  Widget build(BuildContext context) {
    if (ventricleData == null) {
      return Expanded(
        child: Center(
          child: Text(
            'Sem dados $title',
            style: const TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          AspectRatio(
            aspectRatio: 1.0,
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white24),
                color: Colors.black,
              ),
              child: CustomPaint(
                painter: LongAxisPainter(
                  maskImage: ventricleData!.segmentationResult.maskImage,
                  leftVentriculeData: ventricleData!,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
