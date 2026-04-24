import 'package:feve_app/services/segmentation_service.dart';
import 'package:feve_app/viewmodels/feve_session_view_model.dart';
import 'package:feve_app/viewmodels/frames_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/image_picker_service.dart';
import 'viewmodels/model_view_model.dart';
import 'views/feve_run_screen.dart';
import 'views/home_screen.dart';

void main() {
  runApp(const FeveApp());
}

class FeveApp extends StatelessWidget {
  const FeveApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<SegmentationService>(create: (_) => SegmentationService()),
        Provider<ImagePickerService>(create: (_) => ImagePickerService()),
        ChangeNotifierProvider(
          create: (context) =>
              ModelViewModel(context.read<SegmentationService>()),
        ),
        ChangeNotifierProvider(
          create: (context) =>
              FramesViewModel(context.read<ImagePickerService>()),
        ),
        ChangeNotifierProvider(
          create: (context) => FeveSessionViewModel(
            context.read<FramesViewModel>(),
            context.read<SegmentationService>(),
          ),
        ),
      ],
      child: MaterialApp(
        title: 'Segmentação de Ventrículo',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          fontFamily: 'Montserrat',
          useMaterial3: true,
        ),
        routes: {
          '/': (context) => const HomeScreen(),
          '/feve-run': (context) => const FeveRunScreen(),
        },
      ),
    );
  }
}
