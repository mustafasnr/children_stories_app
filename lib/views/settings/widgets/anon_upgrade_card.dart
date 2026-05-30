import 'dart:async';

import 'package:children_stories/app/theme/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AnonUpgradeCard extends StatefulWidget {
  const AnonUpgradeCard({super.key});

  @override
  State<AnonUpgradeCard> createState() => _AnonUpgradeCardState();
}

class _AnonUpgradeCardState extends State<AnonUpgradeCard> {
  late final PageController _pageController;
  Timer? _timer;
  int _currentPage = 300;
  final int _totalSlides = 3;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentPage);
    _timer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (mounted && _pageController.hasClients) {
        if (!_isWidgetOffstage()) {
          _currentPage++;
          _pageController.animateToPage(
            _currentPage,
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeInOutCubic,
          );
        }
      }
    });
  }

  bool _isWidgetOffstage() {
    if (!mounted) return true;
    bool offstageDetected = false;
    context.visitAncestorElements((element) {
      final widget = element.widget;
      if (widget is Offstage && widget.offstage) {
        offstageDetected = true;
        return false; // stop traversal
      }
      return true; // continue traversal
    });
    return offstageDetected;
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final slides = [
      const _CarouselSlideData(
        emoji: '📚',
        title: 'Create Your Library',
        description:
            'Save your favorite stories and access them anytime, anywhere.',
      ),
      const _CarouselSlideData(
        emoji: '🎧',
        title: 'Audio Narrations',
        description: 'Listen to high-quality voiceovers and narrations.',
      ),
      const _CarouselSlideData(
        emoji: '✨',
        title: 'Sync Across Devices',
        description: 'Never lose your reading progress or saved stats.',
      ),
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: colorScheme.primary.withValues(alpha: 0.15),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: 220,
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (page) {
                setState(() {
                  _currentPage = page;
                });
              },
              itemBuilder: (context, index) {
                final slide = slides[index % _totalSlides];
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          slide.emoji,
                          style: const TextStyle(fontSize: 36),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      slide.title,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.titleLarge.copyWith(
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        slide.description,
                        textAlign: TextAlign.center,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(_totalSlides, (index) {
              final isActive = (_currentPage % _totalSlides) == index;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                height: 8,
                width: isActive ? 24 : 8,
                decoration: BoxDecoration(
                  color: isActive
                      ? colorScheme.primary
                      : colorScheme.onSurface.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(4),
                ),
              );
            }),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => context.push('/login?upgrade=true'),
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.primary,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: const Text(
              'Sign In / Register',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}

class _CarouselSlideData {
  final String emoji;
  final String title;
  final String description;

  const _CarouselSlideData({
    required this.emoji,
    required this.title,
    required this.description,
  });
}
