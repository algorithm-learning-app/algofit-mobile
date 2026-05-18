import 'package:flutter/material.dart';

/// Five-slot heart display (filled vs dimmed).
class HeartsIndicator extends StatelessWidget {
  const HeartsIndicator({
    super.key,
    required this.hearts,
    this.iconSize = 18,
  });

  final int hearts;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    final filled = hearts.clamp(0, 5);
    return Semantics(
      label: '하트 $filled개',
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(5, (i) {
          return Padding(
            padding: EdgeInsets.only(left: i == 0 ? 0 : 4),
            child: Text(
              '❤️',
              style: TextStyle(
                fontSize: iconSize,
                color: Colors.white.withValues(
                  alpha: i < filled ? 1 : 0.35,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
