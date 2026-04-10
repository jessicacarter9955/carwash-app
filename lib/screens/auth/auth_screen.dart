import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants.dart';
import '../../providers/auth_providers.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  bool _isLogin = true;
  bool _loading = false;
  bool _obscure = true;
  final List<String> _logs = [];

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    if (_emailCtrl.text.trim().isEmpty || _passCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('⚠️ Enter email and password')),
      );
      return;
    }
    setState(() => _loading = true);
    try {
      await ref.read(authNotifierProvider.notifier).signIn(
            _emailCtrl.text.trim(),
            _passCtrl.text,
          );
      if (mounted) context.go('/home');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('❌ ${e.toString().replaceAll('Exception: ', '')}')),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _register() async {
    if (_nameCtrl.text.trim().isEmpty ||
        _emailCtrl.text.trim().isEmpty ||
        _passCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('⚠️ Fill all required fields')),
      );
      return;
    }
    if (_passCtrl.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('⚠️ Password min 6 characters')),
      );
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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Account created! Please sign in.')),
        );
        setState(() => _isLogin = true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('❌ ${e.toString().replaceAll('Exception: ', '')}')),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _addLog(String message) {
    setState(() {
      _logs.add('${DateTime.now().toString().substring(11, 19)}: $message');
    });
  }

  void _continueAsGuest() async {
    _addLog('🔵 Continue as Guest button clicked');
    setState(() => _loading = true);
    _addLog('🔵 Loading state set to true');
    try {
      // Try to sign in with demo credentials first
      _addLog('🔵 Attempting to sign in with demo credentials...');
      try {
        await ref.read(authNotifierProvider.notifier).signIn(
              'demo@washgo.com',
              'demo123',
            );
        _addLog('✅ Demo user signed in successfully');
      } catch (signInError) {
        _addLog('⚠️ Sign in failed: $signInError, trying to register...');
        // If sign in fails, try to register
        try {
          await ref.read(authNotifierProvider.notifier).register(
                'Demo Guest',
                'demo@washgo.com',
                '+1 555 0000',
                'demo123',
              );
          _addLog('✅ Demo user registered successfully');
          // After registration, try to sign in immediately (handles email confirmation)
          _addLog('🔵 Attempting to sign in after registration...');
          await ref.read(authNotifierProvider.notifier).signIn(
                'demo@washgo.com',
                'demo123',
              );
          _addLog('✅ Signed in after registration');
        } catch (registerError) {
          _addLog('❌ Registration failed: $registerError');
          rethrow;
        }
      }
      if (mounted) {
        _addLog('✅ Navigating to /home');
        context.go('/home');
      }
    } catch (e) {
      _addLog('❌ Error: $e');
      if (mounted) {
        String errorMsg = e.toString().replaceAll('Exception: ', '');
        // Provide specific guidance for rate limit error
        if (errorMsg.contains('429') || errorMsg.contains('rate limit')) {
          errorMsg =
              'Rate limit exceeded. Please disable email confirmation in Supabase dashboard (Authentication → Email → Confirm email: OFF)';
        }
        _addLog('❌ Showing error: $errorMsg');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMsg),
            duration: const Duration(seconds: 8),
          ),
        );
      }
    } finally {
      _addLog('🔵 Setting loading to false');
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
                    Text(
                        _isLogin
                            ? 'Car pickup & wash service'
                            : 'Create your account',
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
                            child: GestureDetector(
                              onTap: () => setState(() => _isLogin = true),
                              child: Container(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 9),
                                decoration: _isLogin
                                    ? BoxDecoration(
                                        color: kSurface,
                                        borderRadius: BorderRadius.circular(8),
                                        boxShadow: shadowXs,
                                      )
                                    : null,
                                child: Text('Sign In',
                                    style: headStyle(
                                        size: 13,
                                        weight: FontWeight.w700,
                                        color: _isLogin ? kText : kMuted),
                                    textAlign: TextAlign.center),
                              ),
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() => _isLogin = false),
                              child: Container(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 9),
                                decoration: !_isLogin
                                    ? BoxDecoration(
                                        color: kSurface,
                                        borderRadius: BorderRadius.circular(8),
                                        boxShadow: shadowXs,
                                      )
                                    : null,
                                child: Text('Register',
                                    style: headStyle(
                                        size: 13,
                                        weight: FontWeight.w700,
                                        color: !_isLogin ? kText : kMuted),
                                    textAlign: TextAlign.center),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    if (!_isLogin) ...[
                      _FieldLabel('FULL NAME'),
                      const SizedBox(height: 6),
                      _AppTextField(controller: _nameCtrl, hint: 'John Smith'),
                      const SizedBox(height: 14),
                      _FieldLabel('PHONE'),
                      const SizedBox(height: 6),
                      _AppTextField(
                          controller: _phoneCtrl,
                          hint: '+1 555 000 0000',
                          keyboardType: TextInputType.phone),
                      const SizedBox(height: 14),
                    ],
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
                    _AppButton(
                      label: _isLogin ? 'Sign In →' : 'Create Account →',
                      onTap: _isLogin ? _signIn : _register,
                      loading: _loading,
                    ),
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
                      onTap: _continueAsGuest,
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
                    const SizedBox(height: 12),
                    // Debug log display
                    if (_logs.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.black87,
                          borderRadius: BorderRadius.circular(rSm),
                        ),
                        constraints: const BoxConstraints(maxHeight: 150),
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('DEBUG LOGS',
                                      style: headStyle(
                                          size: 10,
                                          weight: FontWeight.w800,
                                          color: kCyan)),
                                  GestureDetector(
                                    onTap: () => setState(() => _logs.clear()),
                                    child: Text('CLEAR',
                                        style: headStyle(
                                            size: 10,
                                            weight: FontWeight.w700,
                                            color: Colors.white70)),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              ..._logs.map((log) => Padding(
                                    padding: const EdgeInsets.only(bottom: 4),
                                    child: Text(log,
                                        style: bodyStyle(
                                            size: 10, color: Colors.white70)),
                                  )),
                            ],
                          ),
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

  const _AppTextField({
    required this.controller,
    required this.hint,
    this.obscure = false,
    this.keyboardType,
    this.suffix,
  });

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

class _AppButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final bool loading;

  const _AppButton({
    required this.label,
    required this.onTap,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: loading ? null : onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [kCyan, kMint]),
          borderRadius: BorderRadius.circular(rSm),
          boxShadow: shadowMd,
        ),
        child: loading
            ? const Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation(Colors.white),
                  ),
                ),
              )
            : Text(label,
                style: headStyle(
                    size: 14, weight: FontWeight.w700, color: Colors.white),
                textAlign: TextAlign.center),
      ),
    );
  }
}
