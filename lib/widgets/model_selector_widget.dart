import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/model_view_model.dart';

class ModelSelectorWidget extends StatelessWidget {
  const ModelSelectorWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ModelViewModel>(
      builder: (context, modelViewModel, child) {
        if (modelViewModel.modelNames.isEmpty) {
          return const CircularProgressIndicator();
        }
        return Wrap(
          spacing: 8.0,
          children: modelViewModel.modelNames.map((modelName) {
            return ElevatedButton(
              onPressed: modelViewModel.selectedModel == modelName
                  ? null
                  : () => modelViewModel.selectModel(modelName),
              style: ElevatedButton.styleFrom(
                backgroundColor: modelViewModel.selectedModel == modelName
                    ? Colors.blue
                    : Colors.white,
              ),
              child: Text(
                modelName,
                style: TextStyle(
                  color: modelViewModel.selectedModel == modelName
                      ? Theme.of(context).colorScheme.onPrimary
                      : Theme.of(context).colorScheme.onSurface,
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}
