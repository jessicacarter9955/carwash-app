import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants.dart';
import '../../providers/auth_providers.dart';
import '../../widgets/app_button.dart';
import '../../widgets/back_button_widget.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileProvider);
    final session = ref.watch(authStateProvider).value;

    return Scaffold(
      backgroundColor: kBg,
      body: Column(
        children: [
          Container(
            color: kBg.withOpacity(0.95),
            padding: EdgeInsets.fromLTRB(
                14, MediaQuery.of(context).padding.top + 12, 14, 10),
            child: Row(children: [
              const BackButtonWidget(),
              const SizedBox(width: 10),
              Text('Profile',
                  style: headStyle(size: 16, weight: FontWeight.w800)),
            ]),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                // Hero
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Column(children: [
                    Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [kCyan, kMint]),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                              color: kCyan.withOpacity(0.3), blurRadius: 16)
                        ],
                      ),
                      child: const Icon(Icons.person,
                          color: Colors.white, size: 36),
                    ),
                    const SizedBox(height: 10),
                    Text(profile.value?.fullName ?? 'User',
                        style: headStyle(size: 20, weight: FontWeight.w900)),
                    const SizedBox(height: 2),
                    Text(session?.user.email ?? '--',
                        style: bodyStyle(size: 12, color: kMuted)),
                    const SizedBox(height: 2),
                    Text(profile.value?.phone ?? '--',
                        style: bodyStyle(size: 12, color: kMuted)),
                  ]),
                ),
                // Menu
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                      color: kSurface,
                      border: Border.all(color: kBorder),
                      borderRadius: BorderRadius.circular(rMd)),
                  child: Column(
                    children: [
                      _MenuItem(
                          icon: '✏️', label: 'Edit Profile', onTap: () {}),
                      _MenuItem(
                          icon: '📦',
                          label: 'My Orders',
                          onTap: () => context.push('/orders')),
                      _MenuItem(
                          icon: '💳', label: 'Payment Methods', onTap: () {}),
                      _MenuItem(
                          icon: '🔔', label: 'Notifications', onTap: () {}),
                      _MenuItem(
                          icon: '❓',
                          label: 'Help & Support',
                          onTap: () {},
                          isLast: true),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: AppButton(
                    label: 'Sign Out',
                    color: kRed,
                    onTap: () async {
                      await ref.read(authNotifierProvider.notifier).signOut();
                      if (context.mounted) context.go('/login');
                    },
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final String icon, label;
  final VoidCallback onTap;
  final bool isLast;
  const _MenuItem(
      {required this.icon,
      required this.label,
      required this.onTap,
      this.isLast = false});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          border: isLast ? null : Border(bottom: BorderSide(color: kBorder)),
        ),
        child: Row(children: [
          SizedBox(
              width: 28,
              child: Text(icon,
                  style: const TextStyle(fontSize: 18),
                  textAlign: TextAlign.center)),
          const SizedBox(width: 12),
          Expanded(
              child: Text(label,
                  style: bodyStyle(size: 13, weight: FontWeight.w600))),
          const Icon(Icons.chevron_right, color: kMuted, size: 18),
        ]),
      ),
    );
  }
}
