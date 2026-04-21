import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/feve_session_controller.dart';
import '../models/feve_min_max.dart';
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
    final feveSessionController = context.watch<FeveSessionController>();
    final a2cExtrema = feveSessionController.getExtremaForView('A2C');
    final a4cExtrema = feveSessionController.getExtremaForView('A4C');
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
              'Classe mockada atual: ${segmentationViewModel.lastViewClass ?? '-'}',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: segmentationViewModel.isLoading
                  ? null
                  : () => _pickImages(context),
              icon: const Icon(Icons.folder_open),
              label: const Text('Selecionar imagens'),
            ),
            const SizedBox(height: 8),
            Text(
              'Frame ${_displayFrame(segmentationViewModel)} de ${segmentationViewModel.selectedImagesCount}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            if (segmentationViewModel.currentImageName != null)
              Text(
                segmentationViewModel.currentImageName!,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            const SizedBox(height: 8),
            Text(
              'Tempo inferência (frame atual): ${_formatInferenceMs(segmentationViewModel.currentFrameInferenceMs)}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            Text(
              'Área máscara (frame atual): ${_formatMaskArea(segmentationViewModel.currentFrameMaskArea)}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            Text(
              'Janela (frame atual): ${segmentationViewModel.currentFrameWindow ?? "-"}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Registros FEVE: ${feveSessionController.records.length}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            Text(
              'A2C min/max: ${_formatExtrema(a2cExtrema)}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            Text(
              'A4C min/max: ${_formatExtrema(a4cExtrema)}',
              style: Theme.of(context).textTheme.bodySmall,
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

  String _formatExtrema(FeveMinMax? extrema) {
    if (extrema == null) {
      return '-';
    }
    return '${extrema.minRecord.maskArea} (f${extrema.minRecord.frameIndex}) / ${extrema.maxRecord.maskArea} (f${extrema.maxRecord.frameIndex})';
  }

  String _formatInferenceMs(int? value) {
    if (value == null) {
      return '-';
    }
    return '$value ms';
  }

  String _formatMaskArea(int? value) {
    if (value == null) {
      return '-';
    }
    return '$value px';
  }

  Future<void> _pickImages(BuildContext context) async {
    final segmentationViewModel = context.read<SegmentationViewModel>();
    final didPick = await segmentationViewModel.pickImages();
    if (!context.mounted || didPick) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Nenhuma imagem selecionada.')),
    );
  }

  int _displayFrame(SegmentationViewModel segmentationViewModel) {
    if (!segmentationViewModel.hasSelectedImages) {
      return 0;
    }
    return segmentationViewModel.currentFrame + 1;
  }
}
