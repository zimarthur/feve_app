import 'package:flutter/material.dart';

class FeveInfoCard extends StatelessWidget {
  final FeveMetrics metrics;

  const FeveInfoCard({super.key, required this.metrics});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.blueGrey[800],
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                "Cálculo FEVE",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.white70,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: _getFeveColor(
                    metrics.ejectionFraction,
                  ).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _getFeveColor(metrics.ejectionFraction),
                    width: 1,
                  ),
                ),
                child: Text(
                  "${metrics.ejectionFraction.toStringAsFixed(1)}%",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: _getFeveColor(metrics.ejectionFraction),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // --- BODY: Métricas A2C e A4C ---
          Row(
            children: [
              Expanded(
                child: _ChamberColumn(title: "Apical 2C", metrics: metrics.a2c),
              ),
              Container(
                height: 80,
                width: 1,
                color: Colors.white24,
                margin: const EdgeInsets.symmetric(horizontal: 16),
              ),
              Expanded(
                child: _ChamberColumn(title: "Apical 4C", metrics: metrics.a4c),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // --- ÁREA DE EXPANSÃO (Para futuras informações) ---
          // Você pode adicionar novos blocos aqui facilmente.
          // Divider(color: Colors.white12, height: 32),
          // const Text("Mais Informações...", style: TextStyle(color: Colors.white54)),
        ],
      ),
    );
  }

  // Lógica simples para colorir a FEVE dependendo do valor (pode ajustar os ranges médicos reais)
  Color _getFeveColor(double value) {
    if (value >= 55) return Colors.greenAccent;
    if (value >= 45) return Colors.orangeAccent;
    return Colors.redAccent;
  }
}

// ==========================================
// 3. SUB-COMPONENTES (WIDGETS INTERNOS)
// ==========================================

class _ChamberColumn extends StatelessWidget {
  final String title;
  final ChamberMetrics metrics;

  const _ChamberColumn({required this.title, required this.metrics});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        _DataRow(label: "Min", area: metrics.minArea, frame: metrics.minFrame),
        const SizedBox(height: 8),
        _DataRow(label: "Max", area: metrics.maxArea, frame: metrics.maxFrame),
      ],
    );
  }
}

class _DataRow extends StatelessWidget {
  final String label;
  final double area;
  final int frame;

  const _DataRow({
    required this.label,
    required this.area,
    required this.frame,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.white54),
        ),
        RichText(
          text: TextSpan(
            style: const TextStyle(fontSize: 13, color: Colors.white),
            children: [
              TextSpan(
                text: "${area.toStringAsFixed(1)} cm² ",
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              TextSpan(
                text: "(f: $frame)",
                style: const TextStyle(color: Colors.white38, fontSize: 11),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class ChamberMetrics {
  final double minArea;
  final int minFrame;
  final double maxArea;
  final int maxFrame;

  const ChamberMetrics({
    required this.minArea,
    required this.minFrame,
    required this.maxArea,
    required this.maxFrame,
  });
}

class FeveMetrics {
  final double ejectionFraction;
  final ChamberMetrics a2c;
  final ChamberMetrics a4c;

  const FeveMetrics({
    required this.ejectionFraction,
    required this.a2c,
    required this.a4c,
  });
}

// Dados mockados para teste
final mockFeveData = FeveMetrics(
  ejectionFraction: 58.5,
  a2c: const ChamberMetrics(
    minArea: 24.2,
    minFrame: 12,
    maxArea: 56.4,
    maxFrame: 45,
  ),
  a4c: const ChamberMetrics(
    minArea: 28.1,
    minFrame: 14,
    maxArea: 62.3,
    maxFrame: 48,
  ),
);
