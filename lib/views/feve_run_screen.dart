import 'package:feve_app/widgets/feve_info_card.dart';
import 'package:feve_app/widgets/round_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../viewmodels/feve_session_view_model.dart';

class FeveRunScreen extends StatefulWidget {
  const FeveRunScreen({super.key});

  @override
  State<FeveRunScreen> createState() => _FeveRunScreenState();
}

class _FeveRunScreenState extends State<FeveRunScreen> {
  @override
  Widget build(BuildContext context) {
    final viewmodel = Provider.of<FeveSessionViewModel>(context);
    return Scaffold(
      backgroundColor: Colors.blueGrey[900],
      appBar: AppBar(
        backgroundColor: Colors.blueGrey[900],
        foregroundColor: Colors.white,
        title: Text("Nova sessão"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            FeveInfoCard(metrics: mockFeveData),

            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  viewmodel.currentImage != null
                      ? Image.memory(
                          viewmodel.currentImage!.bytes,
                          gaplessPlayback: true,
                          fit: BoxFit.fitWidth,
                          width: double.infinity,
                        )
                      : const SizedBox(
                          width: double.infinity,
                          child: Text(
                            "Nenhuma imagem carregada.",
                            style: TextStyle(color: Colors.white),
                            textAlign: TextAlign.center,
                          ),
                        ),
                  if (viewmodel.currentResult?.maskImage != null)
                    RawImage(
                      image: viewmodel.currentResult!.maskImage,
                      fit: BoxFit.fitWidth,
                      width: double.infinity,
                    ),
                ],
              ),
            ),

            RoundButton(
              isActive: !viewmodel.isPlaying,
              icon: viewmodel.isPlaying
                  ? Icons.pause_rounded
                  : Icons.play_arrow_rounded,
              onTap: () {
                if (viewmodel.isPlaying) {
                  viewmodel.stop();
                } else {
                  viewmodel.play();
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
