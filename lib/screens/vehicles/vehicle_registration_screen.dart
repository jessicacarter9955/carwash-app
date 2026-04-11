import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants.dart';
import '../../widgets/app_button.dart';

class VehicleRegistrationScreen extends ConsumerStatefulWidget {
  const VehicleRegistrationScreen({super.key});

  @override
  ConsumerState<VehicleRegistrationScreen> createState() => _VehicleRegistrationScreenState();
}

class _VehicleRegistrationScreenState extends ConsumerState<VehicleRegistrationScreen> {
  final _makeCtrl = TextEditingController();
  final _modelCtrl = TextEditingController();
  final _yearCtrl = TextEditingController();
  final _colorCtrl = TextEditingController();
  final _plateCtrl = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _makeCtrl.dispose();
    _modelCtrl.dispose();
    _yearCtrl.dispose();
    _colorCtrl.dispose();
    _plateCtrl.dispose();
    super.dispose();
  }

  Future<void> _registerVehicle() async {
    if (_makeCtrl.text.trim().isEmpty ||
        _modelCtrl.text.trim().isEmpty ||
        _yearCtrl.text.trim().isEmpty ||
        _colorCtrl.text.trim().isEmpty ||
        _plateCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('⚠️ Please fill all required fields')),
      );
      return;
    }
    setState(() => _loading = true);
    
    // TODO: Save to Supabase vehicles table
    // For now, just navigate back
    await Future.delayed(const Duration(seconds: 1));
    
    setState(() => _loading = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Vehicle registered successfully')),
      );
      context.pop();
    }
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
              const Icon(Icons.directions_car, size: 64, color: kCyan),
              const SizedBox(height: 20),
              Text('Add Your Vehicle',
                  style: headStyle(size: 24, weight: FontWeight.w900)),
              const SizedBox(height: 8),
              Text('Register your car for easy booking',
                  style: bodyStyle(size: 13, color: kMuted)),
              const SizedBox(height: 30),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildTextField('Make', 'e.g., Toyota', _makeCtrl),
                      const SizedBox(height: 12),
                      _buildTextField('Model', 'e.g., Corolla', _modelCtrl),
                      const SizedBox(height: 12),
                      _buildTextField('Year', 'e.g., 2020', _yearCtrl, keyboardType: TextInputType.number, maxLength: 4),
                      const SizedBox(height: 12),
                      _buildTextField('Color', 'e.g., White', _colorCtrl),
                      const SizedBox(height: 12),
                      _buildTextField('License Plate', 'e.g., AB 123 CD', _plateCtrl, textUpperCase: true),
                      const SizedBox(height: 30),
                      AppButton(
                        label: 'Register Vehicle',
                        onTap: _registerVehicle,
                        loading: _loading,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    String hint,
    TextEditingController controller, {
    TextInputType? keyboardType,
    int? maxLength,
    bool textUpperCase = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: headStyle(size: 10, weight: FontWeight.w800, color: kMuted)
                .copyWith(letterSpacing: 0.8)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          style: bodyStyle(size: 14),
          keyboardType: keyboardType,
          maxLength: maxLength,
          textCapitalization: textUpperCase ? TextCapitalization.characters : TextCapitalization.none,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: bodyStyle(size: 14, color: kMuted),
            filled: true,
            fillColor: kSurface,
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(rSm),
                borderSide: BorderSide(color: kBorder, width: 1.5)),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(rSm),
                borderSide: BorderSide(color: kBorder, width: 1.5)),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(rSm),
                borderSide: const BorderSide(color: kCyan, width: 1.5)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          ),
        ),
      ],
    );
  }
}
