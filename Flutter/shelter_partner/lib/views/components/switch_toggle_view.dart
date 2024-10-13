import 'package:flutter/material.dart';

class SwitchToggleView extends StatelessWidget {
  final String title;  // Title for the switch
  final bool value;    // Current value of the switch
  final ValueChanged<bool> onChanged;  // Callback to handle value change

  const SwitchToggleView({
    super.key,
    required this.title,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title),
        Switch(
          value: value,
          onChanged: onChanged,  // Handle switch toggle
        ),
      ],
    );
  }
}