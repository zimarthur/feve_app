import 'package:flutter/material.dart';

class HomeSelectorButton extends StatefulWidget {
  final String title;
  final String textWhenNull;
  final String? value;
  final VoidCallback onTap;
  final bool isLoading;
  const HomeSelectorButton({
    super.key,
    required this.title,
    required this.textWhenNull,
    required this.value,
    required this.onTap,
    required this.isLoading,
  });

  @override
  State<HomeSelectorButton> createState() => _HomeSelectorButtonState();
}

class _HomeSelectorButtonState extends State<HomeSelectorButton> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: widget.onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.blueGrey[700],
          borderRadius: BorderRadius.circular(16),
        ),
        padding: EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.title,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                  Text(
                    widget.value ?? widget.textWhenNull,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            if (widget.isLoading)
              CircularProgressIndicator(
                color: Colors.lightBlueAccent,
                strokeWidth: 2,
              )
            else if (widget.value != null)
              Icon(Icons.check_circle, color: Colors.lightBlueAccent),
          ],
        ),
      ),
    );
  }
}
