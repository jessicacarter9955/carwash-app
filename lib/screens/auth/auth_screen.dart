import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants.dart';
import '../../state/app_state.dart';
import '../../services/auth_service.dart';
import '../../services/pricing_service.dart';
import '../../widgets/toast_overlay.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});
  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool _isLogin = true;

  // Login controllers
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  // Register controllers
  final _nameCtrl = TextEditingController();
  final _regEmailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _regPassCtrl = TextEditingController();
  String _selectedRole = 'customer';

  bool _loading = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _nameCtrl.dispose();
    _regEmailCtrl.dispose();
    _phoneCtrl.dispose();
    _regPassCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_emailCtrl.text.trim().isEmpty || _passwordCtrl.text.isEmpty) {
      showToast('⚠️ Enter email and password');
      return;
    }
    setState(() => _loading = true);
    try {
      final res = await AuthService.login(
        _emailCtrl.text.trim(),
        _passwordCtrl.text,
      );
      if (res.user != null) {
        final state = context.read<AppState>();
        final profile = await AuthService.loadProfile(res.user!.id);
        state.setProfile(profile, res.user!.id, res.user!.email);
        await PricingService.loadFromDB(state);
        showToast('✅ Welcome back!');
      }
    } catch (e) {
      showToast('❌ ${e.toString()}');
    }
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _handleRegister() async {
    if (_nameCtrl.text.trim().isEmpty ||
        _regEmailCtrl.text.trim().isEmpty ||
        _regPassCtrl.text.isEmpty) {
      showToast('⚠️ Fill all fields');
      return;
    }
    if (_regPassCtrl.text.length < 6) {
      showToast('⚠️ Password min 6 chars');
      return;
    }
    setState(() => _loading = true);
    try {
      final res = await AuthService.register(
        name: _nameCtrl.text.trim(),
        email: _regEmailCtrl.text.trim(),
        password: _regPassCtrl.text,
        phone: _phoneCtrl.text.trim(),
        role: _selectedRole,
      );
      if (res.user != null) {
        showToast('✅ Account created! Check email.');
      }
    } catch (e) {
      showToast('❌ ${e.toString()}');
    }
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(-0.4, -1),
            radius: 1.2,
            colors: [Color(0x2649CBEB), Colors.transparent],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Container(
              width: double.infinity,
              constraints: const BoxConstraints(maxWidth: 400),
              decoration: BoxDecoration(
                color: kSurface,
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: kBorder),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(.12),
                    blurRadius: 40,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Logo
                  RichText(
                    text: const TextSpan(
                      children: [
                        TextSpan(
                          text: 'Wash',
                          style: TextStyle(
                            fontFamily: kFontHead,
                            fontSize: 34,
                            fontWeight: FontWeight.w900,
                            color: kCyan3,
                            letterSpacing: -1,
                          ),
                        ),
                        TextSpan(
                          text: 'Go',
                          style: TextStyle(
                            fontFamily: kFontHead,
                            fontSize: 34,
                            fontWeight: FontWeight.w900,
                            color: kText,
                            letterSpacing: -1,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Laundry pickup & delivery',
                    style: TextStyle(
                      color: kMuted,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Tab switcher
                  _TabSwitcher(
                    isLogin: _isLogin,
                    onLogin: () => setState(() => _isLogin = true),
                    onRegister: () => setState(() => _isLogin = false),
                  ),
                  const SizedBox(height: 20),

                  // Form
                  if (_isLogin)
                    _LoginForm(
                      emailCtrl: _emailCtrl,
                      passwordCtrl: _passwordCtrl,
                      loading: _loading,
                      onLogin: _handleLogin,
                    )
                  else
                    _RegisterForm(
                      nameCtrl: _nameCtrl,
                      emailCtrl: _regEmailCtrl,
                      phoneCtrl: _phoneCtrl,
                      passCtrl: _regPassCtrl,
                      selectedRole: _selectedRole,
                      onRoleChanged: (r) => setState(() => _selectedRole = r),
                      loading: _loading,
                      onRegister: _handleRegister,
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Tab Switcher ───────────────────────────
class _TabSwitcher extends StatelessWidget {
  final bool isLogin;
  final VoidCallback onLogin, onRegister;
  const _TabSwitcher({
    required this.isLogin,
    required this.onLogin,
    required this.onRegister,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: kBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: kBorder),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          _AuthTab(label: 'Sign In', active: isLogin, onTap: onLogin),
          _AuthTab(label: 'Register', active: !isLogin, onTap: onRegister),
        ],
      ),
    );
  }
}

class _AuthTab extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;
  const _AuthTab({
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 9),
          decoration: BoxDecoration(
            color: active ? kSurface : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            boxShadow: active
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(.06),
                      blurRadius: 3,
                    ),
                  ]
                : null,
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: kFontHead,
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: active ? kText : kMuted,
            ),
          ),
        ),
      ),
    );
  }
}

// ── Login Form ─────────────────────────────
class _LoginForm extends StatelessWidget {
  final TextEditingController emailCtrl, passwordCtrl;
  final bool loading;
  final VoidCallback onLogin;

  const _LoginForm({
    required this.emailCtrl,
    required this.passwordCtrl,
    required this.loading,
    required this.onLogin,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _FieldGroup(
          label: 'Email',
          ctrl: emailCtrl,
          hint: 'you@email.com',
          type: TextInputType.emailAddress,
        ),
        _FieldGroup(
          label: 'Password',
          ctrl: passwordCtrl,
          hint: '••••••••',
          obscure: true,
        ),
        const SizedBox(height: 4),
        _PrimaryBtn(
          label: loading ? 'Signing in...' : 'Sign In →',
          onTap: loading ? null : onLogin,
        ),
      ],
    );
  }
}

// ── Register Form ──────────────────────────
class _RegisterForm extends StatelessWidget {
  final TextEditingController nameCtrl, emailCtrl, phoneCtrl, passCtrl;
  final String selectedRole;
  final Function(String) onRoleChanged;
  final bool loading;
  final VoidCallback onRegister;

  const _RegisterForm({
    required this.nameCtrl,
    required this.emailCtrl,
    required this.phoneCtrl,
    required this.passCtrl,
    required this.selectedRole,
    required this.onRoleChanged,
    required this.loading,
    required this.onRegister,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _FieldGroup(label: 'Full Name', ctrl: nameCtrl, hint: 'John Smith'),
        _FieldGroup(
          label: 'Email',
          ctrl: emailCtrl,
          hint: 'you@email.com',
          type: TextInputType.emailAddress,
        ),
        _FieldGroup(
          label: 'Phone',
          ctrl: phoneCtrl,
          hint: '+1 555 000 0000',
          type: TextInputType.phone,
        ),
        _FieldGroup(
          label: 'Password',
          ctrl: passCtrl,
          hint: 'min 6 chars',
          obscure: true,
        ),
        const SizedBox(height: 4),
        Text(
          'I am a...'.toUpperCase(),
          style: const TextStyle(
            fontFamily: kFontHead,
            fontSize: 11,
            fontWeight: FontWeight.w800,
            color: kMuted,
            letterSpacing: .8,
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            _RoleCard(
              emoji: '👤',
              label: 'Customer',
              selected: selectedRole == 'customer',
              onTap: () => onRoleChanged('customer'),
            ),
            const SizedBox(width: 8),
            _RoleCard(
              emoji: '🚗',
              label: 'Driver',
              selected: selectedRole == 'driver',
              onTap: () => onRoleChanged('driver'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _PrimaryBtn(
          label: loading ? 'Creating...' : 'Create Account →',
          onTap: loading ? null : onRegister,
        ),
      ],
    );
  }
}

// ── Shared small widgets ───────────────────
class _FieldGroup extends StatelessWidget {
  final String label, hint;
  final TextEditingController ctrl;
  final bool obscure;
  final TextInputType type;
  const _FieldGroup({
    required this.label,
    required this.ctrl,
    required this.hint,
    this.obscure = false,
    this.type = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: const TextStyle(
              fontFamily: kFontHead,
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: kMuted,
              letterSpacing: .8,
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: ctrl,
            obscureText: obscure,
            keyboardType: type,
            style: const TextStyle(fontSize: 13, color: kText),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(color: kMuted),
              filled: true,
              fillColor: kBg,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 12,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: kBorder, width: 1.5),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: kBorder, width: 1.5),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: kCyan3, width: 1.5),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PrimaryBtn extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  const _PrimaryBtn({required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onTap,
        style:
            ElevatedButton.styleFrom(
              backgroundColor: kCyan3,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              elevation: 0,
            ).copyWith(
              shadowColor: WidgetStateProperty.all(kCyan3.withOpacity(.35)),
              elevation: WidgetStateProperty.all(4),
            ),
        child: Text(
          label,
          style: const TextStyle(
            fontFamily: kFontHead,
            fontSize: 14,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  final String emoji, label;
  final bool selected;
  final VoidCallback onTap;
  const _RoleCard({
    required this.emoji,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: selected ? kCyan3.withOpacity(.08) : kBg,
            border: Border.all(color: selected ? kCyan3 : kBorder, width: 1.5),
            borderRadius: BorderRadius.circular(10),
            boxShadow: selected
                ? [BoxShadow(color: kCyan3.withOpacity(.2), blurRadius: 12)]
                : null,
          ),
          child: Column(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 22)),
              const SizedBox(height: 4),
              Text(
                label,
                style: const TextStyle(
                  fontFamily: kFontHead,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
