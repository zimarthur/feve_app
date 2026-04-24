import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../viewmodels/model_view_model.dart';

class ModelSelectorBottomsheet extends StatefulWidget {
  const ModelSelectorBottomsheet({super.key});

  @override
  State<ModelSelectorBottomsheet> createState() =>
      _ModelSelectorBottomsheetState();
}

class _ModelSelectorBottomsheetState extends State<ModelSelectorBottomsheet> {
  @override
  Widget build(BuildContext context) {
    final modelViewmodel = Provider.of<ModelViewModel>(context);
    return Container(
      padding: EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "Selecione o modelo",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),
          for (var model in modelViewmodel.modelNames)
            ListTile(
              title: Text(model),
              onTap: () {
                modelViewmodel.selectModel(model);
                Navigator.pop(context);
              },
            ),
        ],
      ),
    );
  }
}
