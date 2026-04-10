import 'package:flutter/material.dart';
import '../core/constants.dart';

class BackButtonWidget extends StatelessWidget {
  const BackButtonWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).pop(),
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: kSurface,
          border: Border.all(color: kBorder, width: 1.5),
          borderRadius: BorderRadius.circular(rSm),
          boxShadow: shadowXs,
        ),
        child: const Icon(Icons.arrow_back_ios_new, size: 14, color: kText),
      ),
    );
  }
}
