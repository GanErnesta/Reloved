import 'package:flutter/material.dart';

class LogoutButton extends StatelessWidget {
  final VoidCallback onPressed;

  const LogoutButton({
    super.key,
    required this.onPressed,
  });
  
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: const Icon(
          Icons.logout,
          color: Colors.red,
        ),
        label: const Text(
          "Keluar",
          style: TextStyle(
            color: Colors.red,
          ),
        ),
      ),
    );
  }
}