import 'package:feve_app/widgets/home_selector_button.dart';
import 'package:feve_app/widgets/model_selector_bottomsheet.dart';
import 'package:feve_app/widgets/round_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../viewmodels/frames_view_model.dart';
import '../viewmodels/model_view_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ModelViewModel>().loadModelNames();
    });
  }

  @override
  Widget build(BuildContext context) {
    final modelViewmodel = Provider.of<ModelViewModel>(context);
    final framesViewmodel = Provider.of<FramesViewModel>(context);
    bool canProceed =
        modelViewmodel.selectedModel != null &&
        framesViewmodel.selectedImages.isNotEmpty;
    return Scaffold(
      backgroundColor: Colors.blueGrey[900],
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Column(
              children: [
                Text(
                  "estimador de",
                  style: TextStyle(
                    color: Colors.lightBlueAccent,
                    fontWeight: FontWeight.w300,
                  ),
                ),
                Text(
                  "Fração de Ejeção no Ventrículo Esquerdo",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            HomeSelectorButton(
              title: "Modelo",
              textWhenNull: "Selecione um modelo",
              value: modelViewmodel.selectedModel,
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  builder: (_) => ModelSelectorBottomsheet(),
                );
              },
              isLoading: modelViewmodel.isLoading,
            ),
            HomeSelectorButton(
              title: "Imagens",
              textWhenNull: "Faça upload de imagens",
              value: framesViewmodel.selectedImages.isNotEmpty
                  ? "${framesViewmodel.selectedImages.length} imagens selecionadas"
                  : null,
              onTap: () => framesViewmodel.pickImages(),
              isLoading: framesViewmodel.isLoading,
            ),
            RoundButton(
              onTap: () {
                if (canProceed) {
                  Navigator.pushNamed(context, '/feve-run');
                }
              },
              isActive: canProceed,
              title: "Iniciar",
            ),
          ],
        ),
      ),
    );
  }
}
