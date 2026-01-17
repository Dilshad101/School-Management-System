import 'package:flutter/material.dart';

import '../../styles/app_styles.dart';

class MyFloatingActionButton extends StatelessWidget {
  const MyFloatingActionButton({super.key, required this.onPressed});
  final VoidCallback onPressed;
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      width: 64,
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(32),
      ),
      child: IconButton(
        icon: Icon(Icons.add, color: Colors.white),
        onPressed: onPressed,
      ),
    );
  }
}
