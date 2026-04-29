import 'package:feve_app/widgets/frames_list.dart';
import 'package:feve_app/widgets/patient_card.dart';
import 'package:flutter/material.dart';

enum Menu { data, frames, feve }

extension MenuExtension on Menu {
  String get title {
    switch (this) {
      case Menu.data:
        return "Dados";
      case Menu.frames:
        return "Imagens";
      case Menu.feve:
        return "FEVE";
    }
  }

  Widget get widget {
    switch (this) {
      case Menu.data:
        return PatientCard();
      case Menu.frames:
        return FramesList();
      case Menu.feve:
        return Placeholder();
    }
  }
}
