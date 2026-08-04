import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/vibra_colors.dart';
import '../../core/theme/vibra_text_styles.dart';
import 'vibra_neon_avatar.dart';

class VibraMatchComparison extends StatelessWidget {
  final String myImageUrl;
  final String theirImageUrl;
  final String theirDisplayName;
  final double score;

  const VibraMatchComparison({
    super.key,
    required this.myImageUrl,
    required this.theirImageUrl,
    required this.theirDisplayName,
    required this.score,
  });

  @override
  Widget build(BuildContext context) {
    final matchColor = VibraColors.getMatchColor(score);

    return SizedBox(
      height: 100,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            left: 40,
            right: 40,
            child:
                Container(
                      height: 2,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            VibraColors.accent.withValues(alpha: 0.5),
                            matchColor.withValues(alpha: 0.5),
                          ],
                        ),
                      ),
                    )
                    .animate(
                      onPlay: (controller) => controller.repeat(reverse: true),
                    )
                    .fadeIn(duration: 1.seconds)
                    .then()
                    .fadeOut(duration: 1.seconds),
          ),

          Positioned(
            left: 0,
            child: VibraNeonAvatar(
              imageUrl: myImageUrl,
              radius: 48,
              score: 1.0,
              displayName: 'Tu',
            ),
          ),

          Positioned(
            right: 0,
            child: VibraNeonAvatar(
              imageUrl: theirImageUrl,
              radius: 48,
              score: score,
              displayName: theirDisplayName,
            ),
          ),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            decoration: BoxDecoration(
              color: VibraColors.surfaceVariant,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: VibraColors.glassBorder),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Text(
              'VS',
              style: VibraTextStyles.labelLarge.copyWith(
                color: VibraColors.textSecondary,
                fontWeight: FontWeight.w900,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
