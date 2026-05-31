import 'package:children_stories/core/constants/app_icons.dart';
import 'package:flutter/material.dart';

class ToastService {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static void showSuccess(String message, {VoidCallback? onTap}) {
    _showToast(
      message: message,
      backgroundColor: const Color(0xFFE6F4EA),
      borderColor: const Color(0xFFCEEAD6),
      textColor: const Color(0xFF137333),
      icon: AppIcons.toastSuccess,
      onTap: onTap,
    );
  }

  static void showError(String message, {VoidCallback? onTap}) {
    _showToast(
      message: message,
      backgroundColor: const Color(0xFFFCE8E6),
      borderColor: const Color(0xFFFAD2CF),
      textColor: const Color(0xFFC5221F),
      icon: AppIcons.toastError,
      onTap: onTap,
    );
  }

  static void showInfo(String message, {VoidCallback? onTap}) {
    _showToast(
      message: message,
      backgroundColor: const Color(0xFFE8F0FE),
      borderColor: const Color(0xFFD2E3FC),
      textColor: const Color(0xFF1967D2),
      icon: AppIcons.toastInfo,
      onTap: onTap,
    );
  }

  static void _showToast({
    required String message,
    required Color backgroundColor,
    required Color borderColor,
    required Color textColor,
    required IconData icon,
    VoidCallback? onTap,
  }) {
    final overlay = navigatorKey.currentState?.overlay;
    if (overlay == null) return;

    late OverlayEntry overlayEntry;
    bool isRemoved = false;

    void dismiss() {
      if (!isRemoved) {
        isRemoved = true;
        overlayEntry.remove();
      }
    }

    overlayEntry = OverlayEntry(
      builder: (context) {
        final screenWidth = MediaQuery.of(context).size.width;
        final toastWidth = screenWidth * 0.75;

        return Positioned(
          top: MediaQuery.of(context).padding.top + 20,
          left: 0,
          right: 0,
          child: Align(
            alignment: Alignment.topCenter,
            child: SizedBox(
              width: toastWidth,
              child: Material(
                color: Colors.transparent,
                child: GestureDetector(
                  onTap: () {
                    dismiss();
                    if (onTap != null) {
                      onTap();
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: backgroundColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: borderColor, width: 1.5),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Icon(icon, color: textColor, size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            message,
                            style: TextStyle(
                              color: textColor,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              height: 1.3,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );

    overlay.insert(overlayEntry);

    Future.delayed(const Duration(seconds: 3), () {
      dismiss();
    });
  }
}
