import 'package:feve_app/models/patient.dart';
import 'package:feve_app/viewmodels/feve_session_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FramesList extends StatelessWidget {
  const FramesList({super.key});

  @override
  Widget build(BuildContext context) {
    final viewmodel = Provider.of<FeveSessionViewModel>(context);
    return viewmodel.selectedPatient == null
        ? Container()
        : Column(
            children: [
              Expanded(
                child: ViewFrameList(
                  view: "A2C",
                  echoView: viewmodel.selectedPatient2CH!,
                ),
              ),
              SizedBox(height: 8),
              Expanded(
                child: ViewFrameList(
                  view: "A4C",
                  echoView: viewmodel.selectedPatient4CH!,
                ),
              ),
            ],
          );
  }
}

class ViewFrameList extends StatelessWidget {
  final String view;
  final EchocardiogramView echoView;

  const ViewFrameList({super.key, required this.view, required this.echoView});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.blueGrey,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(8),
              bottomLeft: Radius.circular(8),
            ),
          ),
          height: double.infinity,
          padding: EdgeInsets.all(8),
          alignment: Alignment.center,
          child: Text(
            view,
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),

        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: echoView.frames.length,
                itemBuilder: (context, index) {
                  final frame = echoView.frames[index];
                  return SizedBox(
                    width: constraints.maxHeight,
                    height: constraints.maxHeight,
                    child: Image.memory(
                      frame.bytes!,
                      gaplessPlayback: true,
                      fit: BoxFit.cover,
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
