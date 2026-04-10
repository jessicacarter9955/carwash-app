import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants.dart';
import '../../providers/auth_providers.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_toast.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});
  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _loading = false;
  bool _obscure = true;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (_nameCtrl.text.trim().isEmpty ||
        _emailCtrl.text.trim().isEmpty ||
        _passCtrl.text.isEmpty) {
      showToast(context, '⚠️ Fill all required fields');
      return;
    }
    if (_passCtrl.text.length < 6) {
      showToast(context, '⚠️ Password min 6 characters');
      return;
    }
    setState(() => _loading = true);
    try {
      await ref.read(authNotifierProvider.notifier).register(
            _nameCtrl.text.trim(),
            _emailCtrl.text.trim(),
            _phoneCtrl.text.trim(),
            _passCtrl.text,
          );
      if (mounted) {
        showToast(context, '✅ Account created! Check your email.');
        context.go('/login');
      }
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
            center: const Alignment(0.7, 1),
            radius: 1.2,
            colors: [kMint.withOpacity(0.1), Colors.transparent],
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
                    Text('Create your account',
                        style: bodyStyle(
                            size: 13, weight: FontWeight.w500, color: kMuted)),
                    const SizedBox(height: 28),
                    Container(
                      decoration: BoxDecoration(
                          color: kBg,
                          border: Border.all(color: kBorder),
                          borderRadius: BorderRadius.circular(rSm)),
                      padding: const EdgeInsets.all(4),
                      child: Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () => context.go('/login'),
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 9),
                                child: Text('Sign In',
                                    style: headStyle(
                                        size: 13,
                                        weight: FontWeight.w700,
                                        color: kMuted),
                                    textAlign: TextAlign.center),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 9),
                              decoration: BoxDecoration(
                                  color: kSurface,
                                  borderRadius: BorderRadius.circular(8),
                                  boxShadow: shadowXs),
                              child: Text('Register',
                                  style: headStyle(
                                      size: 13,
                                      weight: FontWeight.w700,
                                      color: kText),
                                  textAlign: TextAlign.center),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    _FieldLabel('FULL NAME'),
                    const SizedBox(height: 6),
                    _AppTextField(controller: _nameCtrl, hint: 'John Smith'),
                    const SizedBox(height: 14),
                    _FieldLabel('EMAIL'),
                    const SizedBox(height: 6),
                    _AppTextField(
                        controller: _emailCtrl,
                        hint: 'you@email.com',
                        keyboardType: TextInputType.emailAddress),
                    const SizedBox(height: 14),
                    _FieldLabel('PHONE'),
                    const SizedBox(height: 6),
                    _AppTextField(
                        controller: _phoneCtrl,
                        hint: '+1 555 000 0000',
                        keyboardType: TextInputType.phone),
                    const SizedBox(height: 14),
                    _FieldLabel('PASSWORD'),
                    const SizedBox(height: 6),
                    _AppTextField(
                      controller: _passCtrl,
                      hint: 'min 6 characters',
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
                        label: 'Create Account →',
                        onTap: _register,
                        loading: _loading),
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
