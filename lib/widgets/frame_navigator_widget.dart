import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/segmentation_view_model.dart';
import 'image_display_widget.dart';

class FrameNavigatorWidget extends StatelessWidget {
  const FrameNavigatorWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SegmentationViewModel>(
      builder: (context, segmentationViewModel, child) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, size: 32),
              onPressed:
                  segmentationViewModel.currentFrame > 0 &&
                      !segmentationViewModel.isLoading
                  ? segmentationViewModel.previousFrame
                  : null,
              color: Theme.of(context).colorScheme.primary,
            ),
            ImageDisplayWidget(),
            IconButton(
              icon: const Icon(Icons.arrow_forward_ios, size: 32),
              onPressed:
                  segmentationViewModel.currentFrame <
                          segmentationViewModel.maxFrames &&
                      !segmentationViewModel.isLoading
                  ? segmentationViewModel.nextFrame
                  : null,
              color: Theme.of(context).colorScheme.primary,
            ),
          ],
        );
      },
    );
  }
}
