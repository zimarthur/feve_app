import 'package:feve_app/models/patient.dart';
import 'package:feve_app/viewmodels/feve_session_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PatientCard extends StatelessWidget {
  const PatientCard({super.key});

  @override
  Widget build(BuildContext context) {
    final metadata = Provider.of<FeveSessionViewModel>(
      context,
    ).selectedPatient?.view2CH.metadata;
    return metadata == null
        ? Container()
        : Column(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: _PatientCardInfo(
                        icon: Icons.calendar_today_outlined,
                        label: "Idade",
                        value: '${metadata.age} anos',
                      ),
                    ),
                    Expanded(
                      child: _PatientCardInfo(
                        icon: Icons.favorite_border_outlined,
                        label: "FEVE",
                        value: '${metadata.ef.toStringAsFixed(0)}%',
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: _PatientCardInfo(
                        icon: Icons.person_outline,
                        label: "Sexo",
                        value: metadata.sex,
                      ),
                    ),
                    Expanded(
                      child: _PatientCardInfo(
                        icon: Icons.image_search_outlined,
                        label: "Qualidade da Imagem",
                        value: metadata.imageQuality,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
  }
}

class _PatientCardInfo extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _PatientCardInfo({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(icon, size: 20, color: Colors.lightBlueAccent[100]),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[400],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
