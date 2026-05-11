import 'package:flutter/material.dart';

class EmojiRating extends StatelessWidget {
  final int? value;
  final ValueChanged<int> onChanged;

  static const _emojis = ['😢', '😟', '😐', '🙂', '😄'];
  static const _labels = ['Very Bad', 'Bad', 'Okay', 'Good', 'Great'];

  const EmojiRating({super.key, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(5, (i) {
        final score = i + 1;
        final selected = value == score;
        return GestureDetector(
          onTap: () => onChanged(score),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: selected
                  ? Theme.of(context).colorScheme.primaryContainer
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Text(
                  _emojis[i],
                  style: TextStyle(fontSize: selected ? 32 : 24),
                ),
                const SizedBox(height: 4),
                Text(
                  _labels[i],
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                      ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}
