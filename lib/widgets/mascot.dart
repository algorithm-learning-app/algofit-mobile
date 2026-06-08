import 'package:flutter/material.dart';

/// 마스코트 표정. 에셋은 `assets/images/mascot/mascot-<name>.png`.
enum MascotMood { neutral, happy, sad }

/// 알고핏 마스코트 이미지. [animate]가 true면 등장 시 탄력 있게 팝업한다
/// (정답·완료 등 피드백 순간의 delight 용).
class Mascot extends StatelessWidget {
  const Mascot(
    this.mood, {
    super.key,
    this.size = 96,
    this.animate = false,
  });

  final MascotMood mood;
  final double size;
  final bool animate;

  @override
  Widget build(BuildContext context) {
    final image = Image.asset(
      'assets/images/mascot/mascot-${mood.name}.png',
      width: size,
      height: size,
      fit: BoxFit.contain,
      // 표정이 바뀌면 새 위젯으로 인식돼 등장 애니메이션이 다시 재생된다.
      key: ValueKey(mood),
    );
    if (!animate) return image;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 440),
      curve: Curves.elasticOut,
      builder: (context, t, child) => Transform.scale(
        scale: t,
        child: Opacity(opacity: t.clamp(0.0, 1.0), child: child),
      ),
      child: image,
    );
  }
}
