import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'viewmodels/model_view_model.dart';
import 'viewmodels/segmentation_view_model.dart';
import 'views/segmentation_screen.dart';

void main() {
  runApp(const FeveApp());
}

class FeveApp extends StatelessWidget {
  const FeveApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ModelViewModel()),
        ChangeNotifierProvider(create: (_) => SegmentationViewModel()),
      ],
      child: MaterialApp(
        title: 'Segmentação de Ventrículo',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
        ),
        home: const SegmentationScreen(),
      ),
    );
  }
}
