import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/model_view_model.dart';
import '../viewmodels/segmentation_view_model.dart';
import '../widgets/model_selector_widget.dart';
import '../widgets/frame_navigator_widget.dart';
import '../widgets/segmentation_button_widget.dart';

class SegmentationScreen extends StatefulWidget {
  const SegmentationScreen({super.key});

  @override
  State<SegmentationScreen> createState() => _SegmentationScreenState();
}

class _SegmentationScreenState extends State<SegmentationScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ModelViewModel>().loadModelNames();
    });
  }

  @override
  Widget build(BuildContext context) {
    final segmentationViewModel = context.watch<SegmentationViewModel>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Análise de Ultrassom 2CH'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const ModelSelectorWidget(),
            const SizedBox(height: 16),
            Text(
              'Frame ${segmentationViewModel.currentFrame} de ${segmentationViewModel.maxFrames}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            const FrameNavigatorWidget(),
            const SizedBox(height: 32),
            const SegmentationButtonWidget(),
          ],
        ),
      ),
    );
  }
}
