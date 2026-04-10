import 'package:flutter/material.dart';
import '../core/constants.dart';

class ToastNotifier extends ChangeNotifier {
  String _message = '';
  bool _visible = false;

  String get message => _message;
  bool get visible => _visible;

  void show(String msg) {
    _message = msg;
    _visible = true;
    notifyListeners();
    Future.delayed(const Duration(milliseconds: 2800), () {
      _visible = false;
      notifyListeners();
    });
  }
}

// Singleton
final toastNotifier = ToastNotifier();

void showToast(String msg) => toastNotifier.show(msg);

class ToastOverlay extends StatelessWidget {
  final Widget child;
  const ToastOverlay({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        AnimatedBuilder(
          animation: toastNotifier,
          builder: (_, __) => AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
            bottom: toastNotifier.visible ? 40 : -60,
            left: 20,
            right: 20,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 300),
              opacity: toastNotifier.visible ? 1 : 0,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 18, vertical: 12),
                decoration: BoxDecoration(
                  color: kText,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(.2),
                        blurRadius: 16,
                        offset: const Offset(0, 4))
                  ],
                ),
                child: Text(
                  toastNotifier.message,
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 13),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
