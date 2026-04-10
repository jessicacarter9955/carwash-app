import 'package:flutter/material.dart';
import '../core/constants.dart';

void showToast(BuildContext context, String message) {
  ScaffoldMessenger.of(context).clearSnackBars();
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message, style: headStyle(size: 13, color: kText)),
      backgroundColor: Colors.white.withOpacity(0.96),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      margin: const EdgeInsets.only(bottom: 30, left: 20, right: 20),
      elevation: 8,
      duration: const Duration(milliseconds: 2800),
    ),
  );
}
