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
        return SizedBox(
          width: 320,
          child: DropdownButtonFormField<String>(
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Modelo de segmentação',
            ),
            initialValue: modelViewModel.selectedModel,
            items: modelViewModel.modelNames
                .map(
                  (modelName) => DropdownMenuItem<String>(
                    value: modelName,
                    child: Text(modelName),
                  ),
                )
                .toList(),
            onChanged: (selectedValue) {
              if (selectedValue != null &&
                  selectedValue != modelViewModel.selectedModel) {
                modelViewModel.selectModel(selectedValue);
              }
            },
          ),
        );
      },
    );
  }
}
