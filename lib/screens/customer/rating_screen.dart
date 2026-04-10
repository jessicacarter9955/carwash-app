import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants.dart';
import '../../state/app_state.dart';
import '../../widgets/toast_overlay.dart';

class RatingScreen extends StatefulWidget {
  final VoidCallback onDone;
  const RatingScreen({super.key, required this.onDone});
  @override
  State<RatingScreen> createState() => _RatingScreenState();
}

class _RatingScreenState extends State<RatingScreen> {
  int _rating = 0;
  final Set<String> _selectedTags = {};

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    return Container(
      color: kBg,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('✅', style: TextStyle(fontSize: 56)),
          const SizedBox(height: 14),
          const Text(
            'Order Complete!',
            style: TextStyle(
              fontFamily: kFontHead,
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Your laundry is delivered',
            style: TextStyle(
              color: kMuted,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            state.fmt(state.grandTotal),
            style: const TextStyle(
              fontFamily: kFontHead,
              fontSize: 34,
              fontWeight: FontWeight.w900,
              color: kCyan3,
            ),
          ),
          const Text(
            'Payment confirmed',
            style: TextStyle(
              fontSize: 13,
              color: kMuted,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Rate your experience',
            style: TextStyle(
              fontFamily: kFontHead,
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          // Stars
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              5,
              (i) => GestureDetector(
                onTap: () {
                  setState(() => _rating = i + 1);
                  if (i + 1 >= 4) showToast('⭐ Thanks for the great rating!');
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Text(
                    '★',
                    style: TextStyle(
                      fontSize: 32,
                      color: i < _rating ? kYellow : const Color(0xFFD4DDE6),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Tags
          Wrap(
            alignment: WrapAlignment.center,
            children:
                [
                  'Great Service 👍',
                  'On Time ⏰',
                  'Clean & Fresh 🧺',
                  'Friendly Driver 😊',
                ].map((tag) {
                  final sel = _selectedTags.contains(tag);
                  return GestureDetector(
                    onTap: () => setState(
                      () => sel
                          ? _selectedTags.remove(tag)
                          : _selectedTags.add(tag),
                    ),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      margin: const EdgeInsets.all(4),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: sel ? kCyan3.withOpacity(.1) : kSurface,
                        border: Border.all(
                          color: sel ? kCyan3 : kBorder,
                          width: 1.5,
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        tag,
                        style: TextStyle(
                          fontFamily: kFontHead,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: sel ? kCyan3 : kText,
                        ),
                      ),
                    ),
                  );
                }).toList(),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: 220,
            child: ElevatedButton(
              onPressed: widget.onDone,
              style: ElevatedButton.styleFrom(
                backgroundColor: kCyan3,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text(
                'Done 🏠',
                style: TextStyle(
                  fontFamily: kFontHead,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
