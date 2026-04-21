import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/segmentation_view_model.dart';

class ImageDisplayWidget extends StatelessWidget {
  const ImageDisplayWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SegmentationViewModel>(
      builder: (context, segmentationViewModel, child) {
        return Container(
          width: 256,
          height: 256,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade400, width: 2),
            borderRadius: BorderRadius.circular(8),
            color: Colors.black,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(
                  segmentationViewModel.getCurrentAssetPath(),
                  fit: BoxFit.cover,
                  gaplessPlayback: true,
                ),
                if (segmentationViewModel.maskImage != null)
                  RawImage(
                    image: segmentationViewModel.maskImage,
                    fit: BoxFit.cover,
                  ),
                if (segmentationViewModel.isLoading)
                  Container(
                    color: Colors.black45,
                    child: const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
