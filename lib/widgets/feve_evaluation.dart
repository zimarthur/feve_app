import 'package:feve_app/models/mask_viewer/long_axis_painter.dart';
import 'package:feve_app/viewmodels/feve_session_view_model.dart';
import 'package:feve_app/widgets/image_disks.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/geometry_extraction.dart';
import '../models/segmentation_result.dart';

class FeveEvaluation extends StatefulWidget {
  const FeveEvaluation({super.key});

  @override
  State<FeveEvaluation> createState() => _FeveEvaluationState();
}

class _FeveEvaluationState extends State<FeveEvaluation> {
  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<FeveSessionViewModel>();

    if (viewModel.isPlaying || viewModel.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (viewModel.currentFeveResult?.minResults == null ||
        viewModel.currentFeveResult?.maxResults == null) {
      return const Center(
        child: Text(
          "Não foi possível calcular FEVE",
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: InkWell(
        onTap: () => viewModel.refreshResults(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              "FEVE: ${viewModel.currentFeveResult?.ejectionFraction != null ? "${(viewModel.currentFeveResult!.ejectionFraction!).toStringAsFixed(2)}% (${(viewModel.selectedPatient?.view2CH.metadata?.ef)?.toStringAsFixed(2)}%)" : "Calculando..."}",
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const Text(
              "Sístole (Volume Mínimo)",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                ImageDisks(
                  title: 'A2C',
                  ventricleData:
                      viewModel.currentFeveResult?.minResults?['A2C'],
                ),
                const SizedBox(width: 16),
                ImageDisks(
                  title: 'A4C',
                  ventricleData:
                      viewModel.currentFeveResult?.minResults?['A4C'],
                ),
              ],
            ),

            const SizedBox(height: 32),

            const Text(
              "Diástole (Volume Máximo)",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                ImageDisks(
                  title: 'A2C',
                  ventricleData:
                      viewModel.currentFeveResult?.maxResults?['A2C'],
                ),
                const SizedBox(width: 16),
                ImageDisks(
                  title: 'A4C',
                  ventricleData:
                      viewModel.currentFeveResult?.maxResults?['A4C'],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
