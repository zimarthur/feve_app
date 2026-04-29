import 'package:feve_app/viewmodels/patients_view_model.dart';
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
                          FeveInfoCard(metrics: mockFeveData),
                          ClipRRect(
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
                                          style: TextStyle(color: Colors.white),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),

                                if (viewmodel
                                        .currentSegmentationResult
                                        ?.maskImage !=
                                    null)
                                  RawImage(
                                    image: viewmodel
                                        .currentSegmentationResult!
                                        .maskImage,
                                    fit: BoxFit.fitWidth,
                                    width: double.infinity,
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(),
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

                  // SizedBox(
                  //   height: 50,
                  //   child: ListView.builder(
                  //     itemCount: patientsViewmodel.patientIds.length,
                  //     itemBuilder: (context, index) {
                  //       final patientId = patientsViewmodel.patientIds[index];
                  //       return ListTile(
                  //         title: Text(patientId),
                  //         onTap: () {
                  //           viewmodel.selectPatient(patientId);
                  //         },
                  //       );
                  //     },
                  //   ),
                  // ),
                  // FeveInfoCard(metrics: mockFeveData),

                  // SizedBox(
                  //   width: double.infinity,
                  //   height: 100,
                  //   child: ListView.builder(
                  //     itemCount: viewmodel.segmentationResults.length,
                  //     scrollDirection: Axis.horizontal,
                  //     itemBuilder: (context, index) {
                  //       final res = viewmodel.segmentationResults[index];
                  //       return InkWell(
                  //         onTap: () {
                  //           viewmodel.setFrame(index);
                  //         },
                  //         child: Column(
                  //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //           children: [
                  //             Text(
                  //               "${res.maskArea}",
                  //               style: TextStyle(color: Colors.white, fontSize: 10),
                  //             ),
                  //             Container(
                  //               margin: const EdgeInsets.symmetric(horizontal: 8),
                  //               color: Colors.white,
                  //               height: res.maskArea.toDouble() / 100,
                  //               width: 15,
                  //             ),
                  //           ],
                  //         ),
                  //       );
                  //     },
                  //   ),
                  // ),
                  // ClipRRect(
                  //   borderRadius: BorderRadius.circular(16),
                  //   child: Stack(
                  //     alignment: Alignment.center,
                  //     children: [
                  //       viewmodel.currentFrame?.bytes != null
                  //           ? Image.memory(
                  //               viewmodel.currentFrame!.bytes!,
                  //               gaplessPlayback: true,
                  //               fit: BoxFit.fitWidth,
                  //               width: double.infinity,
                  //             )
                  //           : const SizedBox(
                  //               width: double.infinity,
                  //               child: Text(
                  //                 "Nenhuma imagem carregada.",
                  //                 style: TextStyle(color: Colors.white),
                  //                 textAlign: TextAlign.center,
                  //               ),
                  //             ),

                  //       if (viewmodel.currentSegmentationResult?.maskImage != null)
                  //         RawImage(
                  //           image: viewmodel.currentSegmentationResult!.maskImage,
                  //           fit: BoxFit.fitWidth,
                  //           width: double.infinity,
                  //         ),
                  //     ],
                  //   ),
                  // ),
                ],
              ),
      ),
    );
  }
}
