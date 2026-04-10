import 'package:flutter/material.dart';
import '../core/constants.dart';

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final bool loading;
  final Color? color;
  final double? width;
  final Widget? leadingWidget;

  const AppButton({
    super.key,
    required this.label,
    this.onTap,
    this.loading = false,
    this.color,
    this.width,
    this.leadingWidget,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? double.infinity,
      child: GestureDetector(
        onTap: (loading || onTap == null) ? null : onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: (loading || onTap == null)
                ? (color ?? kCyan).withOpacity(0.55)
                : (color ?? kCyan),
            borderRadius: BorderRadius.circular(rMd),
            boxShadow: [
              BoxShadow(
                  color: kCyan.withOpacity(0.35),
                  blurRadius: 16,
                  offset: const Offset(0, 4))
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (loading)
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 2),
                )
              else if (leadingWidget != null) ...[
                leadingWidget!,
                const SizedBox(width: 8)
              ],
              Text(label,
                  style: headStyle(
                      size: 14, weight: FontWeight.w800, color: Colors.white)),
            ],
          ),
        ),
      ),
    );
  }
}

class AppSecondaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;

  const AppSecondaryButton({super.key, required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: kSurface,
          border: Border.all(color: kBorder, width: 1.5),
          borderRadius: BorderRadius.circular(rSm),
          boxShadow: shadowXs,
        ),
        child: Text(label,
            style: bodyStyle(size: 12, weight: FontWeight.w600, color: kText2),
            textAlign: TextAlign.center),
      ),
    );
  }
}
