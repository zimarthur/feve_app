import 'package:feve_app/models/mask_viewer/long_axis_painter.dart';
import 'package:feve_app/viewmodels/feve_session_view_model.dart';
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
  /// Método auxiliar para construir o card de cada vista e evitar código repetido
  Widget _buildMaskCard(String title, SegmentationResult? result) {
    if (result == null) {
      return Expanded(
        child: Center(
          child: Text(
            'Sem dados $title',
            style: const TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    // Calcula o eixo longo usando os bytes corretos da vista
    final axisData = VentricleGeometryExtractor.extractLongAxis(
      result.maskBytes,
    );

    if (axisData == null) {
      return Expanded(
        child: Center(
          child: Text(
            'Erro no eixo $title',
            style: const TextStyle(color: Colors.red),
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
          // AspectRatio garante que o canvas fique perfeitamente quadrado (256x256 escalado)
          AspectRatio(
            aspectRatio: 1.0,
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white24),
                color: Colors.black,
              ),
              child: CustomPaint(
                painter: LongAxisPainter(
                  maskImage: result.maskImage,
                  longAxisData: axisData,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

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

    // Usamos SingleChildScrollView caso a tela seja pequena na vertical
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            "Sístole (Volume Mínimo)",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildMaskCard(
                'A2C',
                viewModel.currentFeveResult?.minResults!['A2C'],
              ),
              const SizedBox(width: 16), // Espaçamento entre as imagens
              _buildMaskCard(
                'A4C',
                viewModel.currentFeveResult?.minResults!['A4C'],
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
              _buildMaskCard(
                'A2C',
                viewModel.currentFeveResult?.maxResults!['A2C'],
              ),
              const SizedBox(width: 16),
              _buildMaskCard(
                'A4C',
                viewModel.currentFeveResult?.maxResults!['A4C'],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
