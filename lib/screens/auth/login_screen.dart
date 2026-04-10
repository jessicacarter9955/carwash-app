import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants.dart';
import '../../providers/auth_providers.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_toast.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});
  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _loading = false;
  bool _obscure = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_emailCtrl.text.trim().isEmpty || _passCtrl.text.isEmpty) {
      showToast(context, '⚠️ Enter email and password');
      return;
    }
    setState(() => _loading = true);
    try {
      await ref
          .read(authNotifierProvider.notifier)
          .signIn(_emailCtrl.text.trim(), _passCtrl.text);
      if (mounted) context.go('/home');
    } catch (e) {
      if (mounted)
        showToast(context, '❌ ${e.toString().replaceAll('Exception: ', '')}');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: const Alignment(-0.4, -1),
            radius: 1.5,
            colors: [kCyan.withOpacity(0.15), Colors.transparent],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Container(
                constraints: const BoxConstraints(maxWidth: 400),
                decoration: BoxDecoration(
                  color: kSurface,
                  border: Border.all(color: kBorder),
                  borderRadius: BorderRadius.circular(rXl),
                  boxShadow: shadowLg,
                ),
                padding: const EdgeInsets.all(32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
                      text: TextSpan(children: [
                        TextSpan(
                            text: 'Wash',
                            style: headStyle(
                                    size: 34,
                                    weight: FontWeight.w900,
                                    color: kCyan)
                                .copyWith(letterSpacing: -1)),
                        TextSpan(
                            text: 'Go',
                            style: headStyle(
                                    size: 34,
                                    weight: FontWeight.w900,
                                    color: kText)
                                .copyWith(letterSpacing: -1)),
                      ]),
                    ),
                    const SizedBox(height: 4),
                    Text('Car pickup & wash service',
                        style: bodyStyle(
                            size: 13, weight: FontWeight.w500, color: kMuted)),
                    const SizedBox(height: 28),
                    // Tabs
                    Container(
                      decoration: BoxDecoration(
                          color: kBg,
                          border: Border.all(color: kBorder),
                          borderRadius: BorderRadius.circular(rSm)),
                      padding: const EdgeInsets.all(4),
                      child: Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 9),
                              decoration: BoxDecoration(
                                  color: kSurface,
                                  borderRadius: BorderRadius.circular(8),
                                  boxShadow: shadowXs),
                              child: Text('Sign In',
                                  style: headStyle(
                                      size: 13,
                                      weight: FontWeight.w700,
                                      color: kText),
                                  textAlign: TextAlign.center),
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () => context.go('/register'),
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 9),
                                child: Text('Register',
                                    style: headStyle(
                                        size: 13,
                                        weight: FontWeight.w700,
                                        color: kMuted),
                                    textAlign: TextAlign.center),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    _FieldLabel('EMAIL'),
                    const SizedBox(height: 6),
                    _AppTextField(
                        controller: _emailCtrl,
                        hint: 'you@email.com',
                        keyboardType: TextInputType.emailAddress),
                    const SizedBox(height: 14),
                    _FieldLabel('PASSWORD'),
                    const SizedBox(height: 6),
                    _AppTextField(
                      controller: _passCtrl,
                      hint: '••••••••',
                      obscure: _obscure,
                      suffix: GestureDetector(
                        onTap: () => setState(() => _obscure = !_obscure),
                        child: Icon(
                            _obscure ? Icons.visibility_off : Icons.visibility,
                            color: kMuted,
                            size: 18),
                      ),
                    ),
                    const SizedBox(height: 20),
                    AppButton(
                        label: 'Sign In →', onTap: _login, loading: _loading),
                    const SizedBox(height: 16),
                    Row(children: [
                      Expanded(child: Divider(color: kBorder)),
                      Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Text('or continue as',
                              style: bodyStyle(
                                  size: 11,
                                  weight: FontWeight.w600,
                                  color: kMuted))),
                      Expanded(child: Divider(color: kBorder)),
                    ]),
                    const SizedBox(height: 12),
                    GestureDetector(
                      onTap: () => context.go('/home'),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: kBg,
                          border: Border.all(color: kBorder, width: 1.5),
                          borderRadius: BorderRadius.circular(rSm),
                        ),
                        child: Text('👤 Continue as Guest (Demo)',
                            style: headStyle(
                                size: 13,
                                weight: FontWeight.w700,
                                color: kText2),
                            textAlign: TextAlign.center),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);
  @override
  Widget build(BuildContext context) => Text(
        text,
        style: headStyle(size: 11, weight: FontWeight.w800, color: kMuted)
            .copyWith(letterSpacing: 0.8),
      );
}

class _AppTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final bool obscure;
  final TextInputType? keyboardType;
  final Widget? suffix;

  const _AppTextField(
      {required this.controller,
      required this.hint,
      this.obscure = false,
      this.keyboardType,
      this.suffix});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      style: bodyStyle(size: 13),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: bodyStyle(size: 13, color: kMuted),
        filled: true,
        fillColor: kBg,
        suffixIcon: suffix,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(rSm),
            borderSide: BorderSide(color: kBorder, width: 1.5)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(rSm),
            borderSide: BorderSide(color: kBorder, width: 1.5)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(rSm),
            borderSide: const BorderSide(color: kCyan, width: 1.5)),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
    );
  }
}
