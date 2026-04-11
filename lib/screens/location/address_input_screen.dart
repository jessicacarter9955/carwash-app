import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants.dart';
import '../../providers/location_provider.dart';
import '../../widgets/app_button.dart';

class AddressInputScreen extends ConsumerStatefulWidget {
  const AddressInputScreen({super.key});

  @override
  ConsumerState<AddressInputScreen> createState() => _AddressInputScreenState();
}

class _AddressInputScreenState extends ConsumerState<AddressInputScreen> {
  final _addressCtrl = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _addressCtrl.dispose();
    super.dispose();
  }

  Future<void> _useCurrentLocation() async {
    setState(() => _loading = true);
    await ref.read(locationProvider.notifier).refresh();
    setState(() => _loading = false);
    if (mounted) context.pop();
  }

  Future<void> _submitAddress() async {
    if (_addressCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('⚠️ Please enter an address')),
      );
      return;
    }
    setState(() => _loading = true);
    // Geocode the address to get lat/lng coordinates
    await ref
        .read(locationProvider.notifier)
        .geocodeAddress(_addressCtrl.text.trim());
    setState(() => _loading = false);
    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 20),
              Align(
                alignment: Alignment.centerLeft,
                child: GestureDetector(
                  onTap: () => context.pop(),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: kSurface,
                      border: Border.all(color: kBorder),
                      borderRadius: BorderRadius.circular(rSm),
                    ),
                    child: const Icon(Icons.arrow_back, size: 18),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              const Icon(Icons.location_on, size: 64, color: kCyan),
              const SizedBox(height: 20),
              Text('Set Your Location',
                  style: headStyle(size: 24, weight: FontWeight.w900)),
              const SizedBox(height: 8),
              Text('Enter your pickup address',
                  style: bodyStyle(size: 13, color: kMuted)),
              const SizedBox(height: 30),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: kSurface,
                  border: Border.all(color: kBorder),
                  borderRadius: BorderRadius.circular(rMd),
                  boxShadow: shadowXs,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('ADDRESS',
                        style: headStyle(
                                size: 10,
                                weight: FontWeight.w800,
                                color: kMuted)
                            .copyWith(letterSpacing: 0.8)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _addressCtrl,
                      style: bodyStyle(size: 14),
                      decoration: InputDecoration(
                        hintText: 'Enter your address',
                        hintStyle: bodyStyle(size: 14, color: kMuted),
                        filled: true,
                        fillColor: kBg,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(rSm),
                            borderSide: BorderSide(color: kBorder, width: 1.5)),
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(rSm),
                            borderSide: BorderSide(color: kBorder, width: 1.5)),
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(rSm),
                            borderSide:
                                const BorderSide(color: kCyan, width: 1.5)),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 12),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              AppButton(
                label: '📍 Use Current Location',
                onTap: _useCurrentLocation,
                loading: _loading,
              ),
              const SizedBox(height: 12),
              AppButton(
                label: '✓ Confirm Address',
                onTap: _submitAddress,
                color: kCyan3,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
