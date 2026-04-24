import 'package:flutter/material.dart';

class RoundButton extends StatefulWidget {
  final String? title;
  final IconData? icon;
  final VoidCallback onTap;
  final bool isActive;
  const RoundButton({
    super.key,
    required this.onTap,
    required this.isActive,
    this.title,
    this.icon,
  });

  @override
  State<RoundButton> createState() => _RoundButtonState();
}

class _RoundButtonState extends State<RoundButton> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        widget.onTap();
      },
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: widget.isActive ? Colors.lightBlueAccent : Colors.white,
        ),
        padding: EdgeInsets.all(32),
        alignment: Alignment.center,
        child: widget.icon != null
            ? Icon(
                widget.icon,
                color: widget.isActive ? Colors.white : Colors.lightBlueAccent,
                size: 20,
              )
            : Text(
                widget.title ?? "",
                style: TextStyle(
                  color: widget.isActive
                      ? Colors.white
                      : Colors.lightBlueAccent,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
      ),
    );
  }
}
