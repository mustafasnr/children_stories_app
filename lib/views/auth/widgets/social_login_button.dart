import 'package:children_stories/app/theme/app_colors.dart';
import 'package:flutter/material.dart';

class SocialLoginButton extends StatelessWidget {
  final String label;
  final String emoji;
  final Color bgColor;
  final Color labelColor;
  final VoidCallback? onTap;
  final bool isLoading;

  const SocialLoginButton({
    super.key,
    required this.label,
    required this.emoji,
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
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
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
