import 'package:children_stories/app/theme/app_colors.dart';
import 'package:children_stories/app/theme/app_text_styles.dart';
import 'package:children_stories/core/services/audio_service.dart';
import 'package:children_stories/viewmodels/home_viewmodel.dart';
import 'package:children_stories/viewmodels/reader_viewmodel.dart';
import 'package:children_stories/viewmodels/subscription_viewmodel.dart';
import 'package:children_stories/viewmodels/theme_viewmodel.dart';
import 'package:children_stories/views/reader/widgets/audio_player_bar.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class ReaderScreen extends StatefulWidget {
  final String bookId;
  const ReaderScreen({super.key, required this.bookId});

  @override
  State<ReaderScreen> createState() => _ReaderScreenState();
}

class _ReaderScreenState extends State<ReaderScreen> {
  late final ReaderViewModel _vm;
  late final PageController _pageController;
  late final AudioService _audioService;
  bool _audioInitialized = false;

  @override
  void initState() {
    super.initState();
    _vm = ReaderViewModel();
    _pageController = PageController();
    _audioService = AudioService();
    _vm.addListener(_onVMChange);
    final langCode =
        context.read<HomeViewModel>().selectedLanguage?.code ?? 'en';
    _vm.loadReader(widget.bookId, langCode);
  }

  void _onVMChange() {
    // Load audio once book is loaded and user has premium
    if (!_audioInitialized && _vm.hasAudio && !_vm.isLoading) {
      final subVM = context.read<SubscriptionViewModel>();
      if (subVM.isPremium) {
        _audioInitialized = true;
        _audioService.init().then((_) {
          _audioService.loadUrl(_vm.audio!.audioUrl);
        });
      }
    }
  }

  @override
  void dispose() {
    _vm.removeListener(_onVMChange);
    _vm.dispose();
    _pageController.dispose();
    _audioService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _vm,
      child: Consumer<ReaderViewModel>(
        builder: (context, vm, _) {
          if (vm.isLoading) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          if (vm.pages.isEmpty) {
            return Scaffold(
              appBar: AppBar(),
              body: Center(
                child: Text(
                  vm.error ?? 'No pages found.',
                  style: AppTextStyles.bodyMedium,
                ),
              ),
            );
          }

          final subVM = context.watch<SubscriptionViewModel>();
          final showAudio = vm.hasAudio && subVM.isPremium;

          return Scaffold(
            body: SafeArea(
              child: Column(
                children: [
                  // Custom app bar
                  _buildTopBar(context, vm),
                  // Page content
                  Expanded(
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: vm.pages.length,
                      onPageChanged: vm.goToPage,
                      itemBuilder: (_, index) {
                        final page = vm.pages[index];
                        return SingleChildScrollView(
                          padding: const EdgeInsets.fromLTRB(28, 24, 28, 24),
                          child: Column(
                            children: [
                              // Page number indicator
                              Text(
                                'Page ${page.pageNumber}',
                                style: AppTextStyles.labelSmall.copyWith(
                                  color: AppColors.primary,
                                ),
                              ),
                              const SizedBox(height: 20),
                              Text(
                                page.textContent,
                                style: AppTextStyles.readerText.copyWith(
                                  fontSize: context.watch<ThemeViewModel>().storyTextSize,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  // Page dots
                  _buildPageDots(vm),
                  // Navigation arrows
                  _buildNavigation(vm),
                  // Audio player
                  if (showAudio) ...[
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                      child: AudioPlayerBar(audioService: _audioService),
                    ),
                  ],
                  const SizedBox(height: 8),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTopBar(BuildContext context, ReaderViewModel vm) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.close_rounded),
            onPressed: () => context.pop(),
            style: IconButton.styleFrom(
              backgroundColor: AppColors.surfaceVariant,
              shape: const CircleBorder(),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              vm.book?.title ?? '',
              style: AppTextStyles.titleMedium,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            '${vm.currentPageIndex + 1} / ${vm.totalPages}',
            style: AppTextStyles.labelMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildPageDots(ReaderViewModel vm) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(vm.totalPages, (index) {
          final isActive = index == vm.currentPageIndex;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: const EdgeInsets.symmetric(horizontal: 3),
            width: isActive ? 20 : 6,
            height: 6,
            decoration: BoxDecoration(
              color: isActive
                  ? AppColors.primary
                  : AppColors.primary.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(3),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildNavigation(ReaderViewModel vm) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _navButton(
            icon: Icons.arrow_back_ios_rounded,
            onTap: vm.isFirstPage
                ? null
                : () {
                    vm.previousPage();
                    _pageController.previousPage(
                      duration: const Duration(milliseconds: 350),
                      curve: Curves.easeInOut,
                    );
                  },
          ),
          if (vm.isLastPage)
            ElevatedButton.icon(
              onPressed: () => context.pop(),
              icon: const Icon(Icons.check_rounded, size: 18),
              label: const Text('Finish'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(120, 44),
                padding: const EdgeInsets.symmetric(horizontal: 24),
              ),
            ),
          _navButton(
            icon: Icons.arrow_forward_ios_rounded,
            onTap: vm.isLastPage
                ? null
                : () {
                    vm.nextPage();
                    _pageController.nextPage(
                      duration: const Duration(milliseconds: 350),
                      curve: Curves.easeInOut,
                    );
                  },
          ),
        ],
      ),
    );
  }

  Widget _navButton({required IconData icon, required VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: onTap != null ? AppColors.primary : AppColors.surfaceVariant,
          shape: BoxShape.circle,
          boxShadow: onTap != null
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Icon(
          icon,
          color: onTap != null ? Colors.white : AppColors.textHint,
          size: 20,
        ),
      ),
    );
  }
}
