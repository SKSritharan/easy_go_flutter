import 'package:flutter/material.dart';

class CustomElevatedButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool isLoading;
  final String label;

  const CustomElevatedButton({
    Key? key,
    required this.onPressed,
    required this.isLoading,
    required this.label,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        fixedSize: const Size(0, 50),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(50),
        ),
      ),
      child: isLoading ? const CircularProgressIndicator() : Text(label),
    );
  }
}
