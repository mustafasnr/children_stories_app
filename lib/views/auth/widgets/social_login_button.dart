import 'package:children_stories/app/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SocialLoginButton extends StatelessWidget {
  final String label;
  final String emoji;
  final String? svgPath;
  final Color bgColor;
  final Color labelColor;
  final VoidCallback? onTap;
  final bool isLoading;

  const SocialLoginButton({
    super.key,
    required this.label,
    required this.emoji,
    this.svgPath,
    required this.bgColor,
    required this.labelColor,
    this.onTap,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: bgColor,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          height: 54,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min, // Sadece içeriği kadar yer kaplasın
            children: isLoading
                ? [
                    SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: labelColor == Colors.white
                            ? Colors.white
                            : AppColors.primary,
                      ),
                    ),
                  ]
                : [
                    if (svgPath != null)
                      SvgPicture.asset(
                        svgPath!,
                        width: 22,
                        height: 22,
                      )
                    else
                      Text(emoji, style: const TextStyle(fontSize: 22)),
                    const SizedBox(width: 12),
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: labelColor,
                      ),
                    ),
                  ],
          ),
        ),
      ),
    );
  }
}
