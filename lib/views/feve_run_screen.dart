import 'package:feve_app/enum/menu.dart';
import 'package:feve_app/viewmodels/patients_view_model.dart';

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
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<FeveSessionViewModel>(context, listen: false).selectPatient(
        Provider.of<PatientsViewModel>(context, listen: false).patientIds.first,
      );
    });
  }

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
        child: viewmodel.selectedPatient == null || viewmodel.isLoading
            ? Center(child: CircularProgressIndicator())
            : Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,

                children: [
                  SizedBox(height: 16),
                  Expanded(
                    child: Container(
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
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  viewmodel.selectedPatient!.name,
                                  style: TextStyle(
                                    color: Colors.lightBlueAccent,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              IconButton.filled(
                                style: IconButton.styleFrom(
                                  backgroundColor: viewmodel.isPlaying
                                      ? Colors.white
                                      : Colors.lightBlueAccent,
                                  foregroundColor: viewmodel.isPlaying
                                      ? Colors.lightBlueAccent
                                      : Colors.white,
                                ),
                                onPressed: () {
                                  if (viewmodel.isPlaying) {
                                    viewmodel.stop();
                                  } else {
                                    viewmodel.play();
                                  }
                                },
                                icon: Icon(
                                  viewmodel.isPlaying
                                      ? Icons.pause_rounded
                                      : Icons.play_arrow_rounded,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 16),
                          Row(
                            children: [
                              for (int i = 0; i < Menu.values.length; i++) ...[
                                Expanded(
                                  child: InkWell(
                                    onTap: () {
                                      viewmodel.setSelectedMenu(Menu.values[i]);
                                    },
                                    child: Text(
                                      Menu.values[i].title,
                                      style: TextStyle(
                                        color:
                                            Menu.values[i] ==
                                                viewmodel.selectedMenu
                                            ? Colors.white
                                            : Colors.grey,
                                        fontSize: 16,
                                        fontWeight:
                                            Menu.values[i] ==
                                                viewmodel.selectedMenu
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                                if (i < Menu.values.length - 1)
                                  Container(
                                    width: 1,
                                    height: 20,
                                    color: Colors.grey,
                                  ),
                              ],
                            ],
                          ),
                          SizedBox(height: 16),
                          Expanded(child: viewmodel.selectedMenu.widget),
                          if (!viewmodel.selectedMenu.shouldHideFrame) ...[
                            SizedBox(height: 16),
                            LayoutBuilder(
                              builder: (context, constraints) {
                                return SizedBox(
                                  width: constraints.maxWidth,
                                  height: constraints.maxWidth,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(16),
                                    child: Stack(
                                      alignment: Alignment.center,

                                      children: [
                                        viewmodel.currentFrame?.bytes != null
                                            ? Image.memory(
                                                viewmodel.currentFrame!.bytes!,
                                                gaplessPlayback: true,
                                                fit: BoxFit.fitWidth,
                                                width: double.infinity,
                                              )
                                            : const SizedBox(
                                                width: double.infinity,
                                                child: Text(
                                                  "Nenhuma imagem carregada.",
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                  ),
                                                  textAlign: TextAlign.center,
                                                ),
                                              ),

                                        if (viewmodel
                                                    .currentSegmentationResult
                                                    ?.maskImage !=
                                                null &&
                                            viewmodel.isShowingMask)
                                          RawImage(
                                            image: viewmodel
                                                .currentSegmentationResult!
                                                .maskImage,
                                            fit: BoxFit.fitWidth,
                                            width: double.infinity,
                                          ),
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Align(
                                            alignment:
                                                AlignmentGeometry.topRight,
                                            child: IconButton.filled(
                                              onPressed: () =>
                                                  viewmodel.toggleMask(),
                                              style: IconButton.styleFrom(
                                                backgroundColor:
                                                    Colors.blueGrey,
                                                foregroundColor: Colors.white,
                                              ),
                                              icon: Icon(
                                                viewmodel.isShowingMask
                                                    ? Icons.visibility
                                                    : Icons.visibility_off,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton.filled(
                        style: IconButton.styleFrom(
                          backgroundColor: viewmodel.isPlayingAllPatients
                              ? Colors.white
                              : Colors.lightBlueAccent,
                          foregroundColor: viewmodel.isPlayingAllPatients
                              ? Colors.lightBlueAccent
                              : Colors.white,
                        ),
                        onPressed: () => viewmodel.runOnAllPatients(),
                        icon: Icon(Icons.playlist_add_check_circle),
                      ),
                      Row(
                        children: [
                          IconButton.filled(
                            style: IconButton.styleFrom(
                              backgroundColor: Colors.lightBlueAccent,
                              foregroundColor: Colors.white,
                            ),
                            onPressed: () => viewmodel.goToPreviousPatient(),
                            icon: Icon(Icons.chevron_left),
                          ),
                          SizedBox(width: 8),
                          IconButton.filled(
                            style: IconButton.styleFrom(
                              backgroundColor: Colors.lightBlueAccent,
                              foregroundColor: Colors.white,
                            ),
                            onPressed: () => viewmodel.goToNextPatient(),
                            icon: Icon(Icons.chevron_right),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
      ),
    );
  }
}
