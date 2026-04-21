import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/segmentation_view_model.dart';

class SegmentationButtonWidget extends StatelessWidget {
  const SegmentationButtonWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SegmentationViewModel>(
      builder: (context, segmentationViewModel, child) {
        return FilledButton.icon(
          onPressed:
              segmentationViewModel.isLoading ||
                  !segmentationViewModel.hasSelectedImages
              ? null
              : () => segmentationViewModel.segmentCurrentImage(context),
          icon: const Icon(Icons.analytics),
          label: const Text('Segmentar Ventrículo (Native)'),
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            textStyle: const TextStyle(fontSize: 16),
          ),
        );
      },
    );
  }
}
