import 'dart:async';
import 'dart:ui' show ImageFilter;
import 'package:flutter/services.dart';
import 'package:shimmer/shimmer.dart';
import 'package:children_stories/app/theme/app_colors.dart';
import 'package:children_stories/app/theme/app_text_styles.dart';
import 'package:children_stories/core/constants/app_icons.dart';
import 'package:children_stories/core/constants/supabase_constants.dart';
import 'package:children_stories/core/services/audio_service.dart';
import 'package:children_stories/data/models/book_page_model.dart';
import 'package:children_stories/l10n/app_localizations.dart';
import 'package:children_stories/viewmodels/home_viewmodel.dart';
import 'package:children_stories/viewmodels/reader_viewmodel.dart';
import 'package:children_stories/viewmodels/subscription_viewmodel.dart';
import 'package:children_stories/viewmodels/settings_viewmodel.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:just_audio/just_audio.dart';

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
  late final AudioPlayer _effectPlayer;
  bool _audioInitialized = false;
  StreamSubscription<Duration>? _positionSubscription;
  StreamSubscription<PlayerState>? _playerStateSubscription;
  bool _isHandlingAudioSync = false;

  // Mock audio state variables
  Timer? _mockTimer;
  bool _mockIsPlaying = false;
  double _mockPositionSeconds = 0.0;

  // Page indicator animation state
  int _lastPageIndex = -1;
  bool _showPageIndicator = false;
  Timer? _indicatorTimer;

  @override
  void initState() {
    super.initState();
    _vm = ReaderViewModel();
    _pageController = PageController();
    _audioService = AudioService();
    _effectPlayer = AudioPlayer();
    _effectPlayer.setVolume(0.4);
    _effectPlayer.setAsset('assets/audio/page_flip.mp3').catchError((e) {
      debugPrint('Error loading page flip sound: $e');
      return null;
    });
    _vm.addListener(_onVMChange);
    final langCode =
        context.read<HomeViewModel>().selectedLanguage?.code ?? 'en';
    _vm.loadReader(widget.bookId, langCode);
  }

  void _onVMChange() {
    // Load audio once book is loaded and user has access (free book or premium user)
    if (!_audioInitialized &&
        _vm.hasAudio &&
        !_vm.isLoading &&
        _vm.book != null) {
      final subVM = context.read<SubscriptionViewModel>();
      final canAccess = !_vm.book!.isPremium || subVM.isPremium;
      if (canAccess) {
        _audioInitialized = true;
        _audioService.init().then((_) async {
          await _audioService.loadUrl(_vm.audio!.audioUrl);
          _setupAudioSyncListener();
          await _audioService.play(); // Start playing automatically
        });
      }
    }

    if (!_vm.isLoading && _vm.pages.isNotEmpty) {
      if (_vm.currentPageIndex != _lastPageIndex) {
        final wasInitial = _lastPageIndex == -1;
        _lastPageIndex = _vm.currentPageIndex;
        _triggerPageIndicator();
        if (!wasInitial) {
          _playPageFlipSound();
        }
      }
    }
  }

  void _playPageFlipSound() {
    final settingsVM = context.read<SettingsViewModel>();
    if (!settingsVM.storySoundsEnabled) return;

    try {
      _effectPlayer.seek(Duration.zero);
      _effectPlayer.play();
    } catch (e) {
      debugPrint('Error playing page flip sound: $e');
    }
  }

  void _setupAudioSyncListener() {
    _positionSubscription = _audioService.positionStream.listen((pos) {
      setState(() {}); // Rebuild UI to update slider progress

      if (_isHandlingAudioSync) return;
      if (!_vm.hasAudio || _vm.pages.isEmpty) return;

      final targetIdx = _vm.getPageIndexForPosition(pos);
      if (targetIdx != _vm.currentPageIndex) {
        _isHandlingAudioSync = true;
        _vm.goToPage(targetIdx);
        _pageController
            .animateToPage(
              targetIdx,
              duration: const Duration(milliseconds: 350),
              curve: Curves.easeInOut,
            )
            .then((_) {
              _isHandlingAudioSync = false;
            });
      }
    });

    _playerStateSubscription = _audioService.playerStateStream.listen((state) {
      setState(() {}); // Rebuild play/pause buttons on state changes
    });
  }

  void _triggerPageIndicator() {
    _indicatorTimer?.cancel();
    setState(() {
      _showPageIndicator = true;
    });
    _indicatorTimer = Timer(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _showPageIndicator = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _vm.removeListener(_onVMChange);
    _vm.dispose();
    _pageController.dispose();
    _positionSubscription?.cancel();
    _playerStateSubscription?.cancel();
    _mockTimer?.cancel();
    _indicatorTimer?.cancel();
    _effectPlayer.dispose();
    _audioService.dispose();
    super.dispose();
  }

  // Unified helpers for audio playback (delegating to real audio or mock)
  bool get _useRealAudio {
    if (!_vm.hasAudio || _vm.book == null) return false;
    final subVM = context.read<SubscriptionViewModel>();
    return !_vm.book!.isPremium || subVM.isPremium;
  }

  double get _currentPositionSeconds {
    if (_useRealAudio) {
      return _audioService.position.inMilliseconds / 1000.0;
    } else {
      return _mockPositionSeconds;
    }
  }

  double get _totalDurationSeconds {
    if (_useRealAudio) {
      final dur = _audioService.duration;
      return (dur != null && dur.inSeconds > 0)
          ? dur.inMilliseconds / 1000.0
          : (_vm.pages.length * 15.0);
    } else {
      return _mockDurationSeconds;
    }
  }

  double get _mockDurationSeconds =>
      _vm.pages.length * 15.0; // 15 seconds per page mock

  bool get _isPlaying {
    if (_useRealAudio) {
      return _audioService.isPlaying;
    } else {
      return _mockIsPlaying;
    }
  }

  void _togglePlay() {
    if (_useRealAudio) {
      if (_audioService.isPlaying) {
        _audioService.pause();
      } else {
        _audioService.play();
      }
    } else {
      setState(() {
        _mockIsPlaying = !_mockIsPlaying;
        if (_mockIsPlaying) {
          _startMockTimer();
        } else {
          _mockTimer?.cancel();
        }
      });
    }
  }

  void _startMockTimer() {
    _mockTimer?.cancel();
    _mockTimer = Timer.periodic(const Duration(milliseconds: 200), (timer) {
      if (!_mockIsPlaying) {
        timer.cancel();
        return;
      }
      setState(() {
        _mockPositionSeconds += 0.2;
        if (_mockPositionSeconds >= _mockDurationSeconds) {
          _mockPositionSeconds = _mockDurationSeconds;
          _mockIsPlaying = false;
          timer.cancel();
        }

        // Synchronize page based on mock timer progress (15 seconds per page)
        final targetIdx = (_mockPositionSeconds / 15.0).floor().clamp(
          0,
          _vm.pages.length - 1,
        );
        if (targetIdx != _vm.currentPageIndex) {
          _isHandlingAudioSync = true;
          _vm.goToPage(targetIdx);
          _pageController
              .animateToPage(
                targetIdx,
                duration: const Duration(milliseconds: 350),
                curve: Curves.easeInOut,
              )
              .then((_) {
                _isHandlingAudioSync = false;
              });
        }
      });
    });
  }

  void _seekTo(double seconds) {
    if (_useRealAudio) {
      _audioService.seek(Duration(milliseconds: (seconds * 1000).toInt()));
    } else {
      setState(() {
        _mockPositionSeconds = seconds.clamp(0.0, _mockDurationSeconds);
        final targetIdx = (_mockPositionSeconds / 15.0).floor().clamp(
          0,
          _vm.pages.length - 1,
        );
        if (targetIdx != _vm.currentPageIndex) {
          _isHandlingAudioSync = true;
          _vm.goToPage(targetIdx);
          _pageController
              .animateToPage(
                targetIdx,
                duration: const Duration(milliseconds: 350),
                curve: Curves.easeInOut,
              )
              .then((_) {
                _isHandlingAudioSync = false;
              });
        }
      });
    }
  }

  void _next() {
    if (_vm.isLastPage) return;
    final nextIdx = _vm.currentPageIndex + 1;
    _navigateToPage(nextIdx);
  }

  void _previous() {
    if (_vm.isFirstPage) return;
    final prevIdx = _vm.currentPageIndex - 1;
    _navigateToPage(prevIdx);
  }

  void _skipToStart() {
    _navigateToPage(0);
  }

  void _skipToEnd() {
    _navigateToPage(_vm.pages.length - 1);
  }

  void _navigateToPage(int index) {
    if (index < 0 || index >= _vm.pages.length) return;

    _isHandlingAudioSync = true;
    _vm.goToPage(index);
    _pageController
        .animateToPage(
          index,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeInOut,
        )
        .then((_) {
          _isHandlingAudioSync = false;
        });

    if (_useRealAudio) {
      final seekTarget = Duration(
        milliseconds: (_vm.getPageSeekSeconds(index) * 1000).toInt(),
      );
      _audioService.seek(seekTarget);
    } else {
      setState(() {
        _mockPositionSeconds = index * 15.0;
      });
    }
  }

  void _showTextSizeDialog(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Consumer<SettingsViewModel>(
          builder: (context, settingsVM, _) {
            return Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(28),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 20,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 36,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.textHint.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Icon(
                        Icons.format_size_rounded,
                        color: AppColors.primary,
                        size: 22,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        localizations.reader_font_size_title,
                        style: AppTextStyles.titleMedium.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Text(
                        'A',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      Expanded(
                        child: SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            activeTrackColor: AppColors.primary,
                            inactiveTrackColor: AppColors.surfaceVariant,
                            thumbColor: AppColors.primary,
                            overlayColor: AppColors.primary.withValues(
                              alpha: 0.12,
                            ),
                            trackHeight: 4,
                            activeTickMarkColor: Colors.transparent,
                            inactiveTickMarkColor: Colors.transparent,
                          ),
                          child: Slider(
                            value: settingsVM.storyTextSizeStep,
                            min: 1.0,
                            max: 10.0,
                            divisions: 9,
                            onChanged: (val) {
                              settingsVM.setStoryTextSizeStep(val);
                            },
                          ),
                        ),
                      ),
                      Text(
                        'A',
                        style: TextStyle(
                          fontSize: 24,
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Center(
                    child: Text(
                      localizations.reader_font_size_preview(
                        settingsVM.storyTextSize.toInt(),
                      ),
                      style: AppTextStyles.labelMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<SettingsViewModel>().isDarkMode;
    final localizations = AppLocalizations.of(context)!;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
      ),
      child: ChangeNotifierProvider.value(
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
                body: SafeArea(
                  bottom: false,
                  child: Column(
                    children: [
                      _buildTopBar(context, vm),
                      Expanded(
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 40),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SvgPicture.asset(
                                  'assets/icons/books.svg',
                                  width: 160,
                                  height: 160,
                                ),
                                const SizedBox(height: 32),
                                Text(
                                  localizations.reader_no_pages_title,
                                  style: AppTextStyles.headlineMedium.copyWith(
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.textPrimary,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  vm.error ??
                                      localizations.reader_no_pages_description,
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    color: AppColors.textSecondary,
                                    height: 1.5,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 36),
                                FilledButton.icon(
                                  onPressed: () => context.pop(),
                                  icon: const Icon(
                                    Icons.arrow_back_rounded,
                                    size: 20,
                                  ),
                                  label: Text(localizations.reader_go_back),
                                  style: FilledButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 28,
                                      vertical: 14,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    elevation: 0,
                                  ),
                                ),
                                const SizedBox(height: 60),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            return Scaffold(
              body: SafeArea(
                bottom: false,
                child: Column(
                  children: [
                    // Custom top app bar
                    _buildTopBar(context, vm),
                    // Page content
                    Expanded(
                      child: Stack(
                        alignment: Alignment.topCenter,
                        children: [
                          PageView.builder(
                            controller: _pageController,
                            itemCount: vm.pages.length,
                            onPageChanged: (index) {
                              if (_isHandlingAudioSync) return;
                              vm.goToPage(index);
                              if (_useRealAudio) {
                                final seekTarget = Duration(
                                  milliseconds:
                                      (vm.getPageSeekSeconds(index) * 1000)
                                          .toInt(),
                                );
                                _audioService.seek(seekTarget);
                              } else {
                                setState(() {
                                  _mockPositionSeconds = index * 15.0;
                                });
                              }
                            },
                            itemBuilder: (_, index) {
                              final page = vm.pages[index];
                              return _buildPageContent(vm, page);
                            },
                          ),
                          Positioned(
                            top: 16,
                            child: IgnorePointer(
                              child: AnimatedOpacity(
                                opacity: _showPageIndicator ? 1.0 : 0.0,
                                duration: const Duration(milliseconds: 300),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? AppColors.surface.withValues(
                                            alpha: 0.9,
                                          )
                                        : Colors.white.withValues(alpha: 0.9),
                                    borderRadius: BorderRadius.circular(100),
                                    border: Border.all(
                                      color: isDark
                                          ? Colors.white.withValues(alpha: 0.12)
                                          : AppColors.textHint.withValues(
                                              alpha: 0.15,
                                            ),
                                      width: 1,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(
                                          alpha: isDark ? 0.2 : 0.05,
                                        ),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Text(
                                    '${vm.currentPageIndex + 1} / ${vm.totalPages}',
                                    style: AppTextStyles.labelSmall.copyWith(
                                      color: AppColors.textPrimary,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 12,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              bottomNavigationBar: _buildAudiobookController(),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context, ReaderViewModel vm) {
    final settingsVM = context.watch<SettingsViewModel>();
    final localizations = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.85),
        border: Border(
          bottom: BorderSide(
            color: AppColors.textHint.withValues(alpha: 0.08),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            tooltip: localizations.reader_go_back,
            icon: const Icon(Icons.close_rounded),
            onPressed: () => context.pop(),
            style: IconButton.styleFrom(
              backgroundColor: AppColors.surfaceVariant.withValues(alpha: 0.4),
              foregroundColor: AppColors.textPrimary,
              shape: const CircleBorder(),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              vm.book?.title ?? '',
              style: AppTextStyles.titleMedium.copyWith(
                fontWeight: FontWeight.bold,
                letterSpacing: -0.3,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(
            tooltip: localizations.settings_dark_mode,
            icon: Icon(
              settingsVM.isDarkMode
                  ? Icons.light_mode_rounded
                  : Icons.dark_mode_rounded,
            ),
            onPressed: () {
              settingsVM.toggleTheme();
            },
            style: IconButton.styleFrom(
              backgroundColor: AppColors.surfaceVariant.withValues(alpha: 0.4),
              foregroundColor: AppColors.textPrimary,
              shape: const CircleBorder(),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            tooltip: localizations.settings_story_sounds,
            icon: Icon(
              settingsVM.storySoundsEnabled
                  ? Icons.volume_up_rounded
                  : Icons.volume_off_rounded,
            ),
            onPressed: () {
              settingsVM.setStorySoundsEnabled(!settingsVM.storySoundsEnabled);
            },
            style: IconButton.styleFrom(
              backgroundColor: AppColors.surfaceVariant.withValues(alpha: 0.4),
              foregroundColor: AppColors.textPrimary,
              shape: const CircleBorder(),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            tooltip: localizations.settings_text_size,
            icon: const Icon(Icons.format_size_rounded),
            onPressed: () => _showTextSizeDialog(context),
            style: IconButton.styleFrom(
              backgroundColor: AppColors.surfaceVariant.withValues(alpha: 0.4),
              foregroundColor: AppColors.textPrimary,
              shape: const CircleBorder(),
            ),
          ),
        ],
      ),
    );
  }

  String _getIllustrationUrl(String? rawUrlOrPath) {
    if (rawUrlOrPath == null || rawUrlOrPath.isEmpty) return '';

    String path = rawUrlOrPath;
    if (path.startsWith('http://') || path.startsWith('https://')) {
      if (path.contains('/storage/v1/object/')) {
        return path;
      }
      final uri = Uri.tryParse(path);
      if (uri != null) {
        path = '${uri.host}${uri.path}';
      } else {
        path = path.replaceFirst(RegExp(r'https?://'), '');
      }
    }

    return '${SupabaseConstants.url}/storage/v1/object/public/${SupabaseConstants.illustrationsBucket}/$path';
  }

  Widget _buildPageContent(ReaderViewModel vm, BookPage page) {
    final isDark = context.watch<SettingsViewModel>().isDarkMode;
    final imgUrl = _getIllustrationUrl(page.imageUrl);

    return Stack(
      children: [
        // Background Blurred Image (to fill the screen without solid margins)
        if (imgUrl.isNotEmpty) ...[
          Positioned.fill(
            child: CachedNetworkImage(imageUrl: imgUrl, fit: BoxFit.cover),
          ),
          Positioned.fill(
            child: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
                child: Container(color: Colors.black.withValues(alpha: 0.3)),
              ),
            ),
          ),

          // Main Illustration (Fully visible, not cropped, not distorted)
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.only(
                top: 16,
                bottom:
                    110, // Leaving space for the bottom glassmorphic text box
                left: 16,
                right: 16,
              ),
              child: CachedNetworkImage(
                imageUrl: imgUrl,
                fit: BoxFit.contain,
                placeholder: (_, _) => _buildImagePlaceholder(isDark),
                errorWidget: (_, _, _) => _buildImageError(isDark),
              ),
            ),
          ),
        ] else
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(gradient: AppColors.primaryGradient),
              child: Center(
                child: Icon(
                  Icons.auto_stories_rounded,
                  size: 64,
                  color: Colors.white.withValues(alpha: 0.3),
                ),
              ),
            ),
          ),

        // Text Overlay Container at the bottom
        Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              bottom: 24, // Padding from bottom control bar
              top:
                  MediaQuery.of(context).size.height *
                  0.1, // Don't cover top app bar area if text is long
            ),
            child: Container(
              constraints: BoxConstraints(
                maxWidth: 600,
                maxHeight:
                    MediaQuery.of(context).size.height *
                    0.32, // Max 32% of screen height
              ),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.black.withValues(alpha: 0.7)
                    : Colors.white.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.12)
                      : Colors.white.withValues(alpha: 0.4),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.08),
                    blurRadius: 18,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                    child: Text(
                      page.textContent,
                      style: AppTextStyles.readerText.copyWith(
                        fontSize: context
                            .watch<SettingsViewModel>()
                            .storyTextSize,
                        height: 1.6,
                        letterSpacing: 0.1,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : const Color(0xFF1D1A26),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImagePlaceholder(bool isDark) {
    final baseColor = isDark
        ? const Color(0xFF2D2A3E)
        : const Color(0xFFF0EBF8);
    final highlightColor = isDark
        ? const Color(0xFF37334C)
        : const Color(0xFFF9F6FC);

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: Container(
        color: isDark ? const Color(0xFF2D2A3E) : const Color(0xFFF0EBF8),
        child: Center(
          child: Icon(
            Icons.auto_stories_outlined,
            size: 64,
            color: isDark
                ? Colors.white.withValues(alpha: 0.1)
                : Colors.black.withValues(alpha: 0.05),
          ),
        ),
      ),
    );
  }

  Widget _buildImageError(bool isDark) {
    return Container(
      color: isDark ? const Color(0xFF2D2A3E) : const Color(0xFFF0EBF8),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.broken_image_rounded,
              size: 48,
              color: isDark
                  ? Colors.white.withValues(alpha: 0.2)
                  : Colors.black.withValues(alpha: 0.1),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAudiobookController() {
    final pos = _currentPositionSeconds;
    final dur = _totalDurationSeconds;
    final playing = _isPlaying;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hasAudio = _vm.hasAudio;

    return Container(
      decoration: BoxDecoration(color: AppColors.surface),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (hasAudio) ...[
              // Full-width Spotify-style seek slider at y=0 (top edge)
              SliderTheme(
                data: SliderThemeData(
                  trackHeight: 2.0,
                  trackShape: FullWidthTrackShape(),
                  thumbShape: const RoundSliderThumbShape(
                    enabledThumbRadius: 8,
                  ),
                  thumbColor: AppColors.primary,
                  activeTrackColor: AppColors.primary,
                  inactiveTrackColor: AppColors.textHint.withValues(
                    alpha: isDark ? 0.15 : 0.1,
                  ),
                  overlayShape: SliderComponentShape.noOverlay,
                ),
                child: SizedBox(
                  height: 12,
                  child: Slider(
                    value: pos.clamp(0.0, dur > 0 ? dur : 1.0),
                    max: dur > 0 ? dur : 1.0,
                    onChanged: _seekTo,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              // Time Labels
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _formatDuration(
                        Duration(milliseconds: (pos * 1000).toInt()),
                      ),
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      _formatDuration(
                        Duration(milliseconds: (dur * 1000).toInt()),
                      ),
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
            ] else
              const SizedBox(height: 12),
            // Podcast/Audiobook Control Row using Phosphor icons via AppIcons
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Skip to Start (En Baş)
                  _controlBtn(icon: AppIcons.skipBack, onTap: _skipToStart),
                  // Previous Page
                  _controlBtn(
                    icon: AppIcons.arrowLeft,
                    onTap: _vm.isFirstPage ? null : _previous,
                  ),
                  // Play / Pause
                  _controlBtn(
                    icon: playing ? AppIcons.pause : AppIcons.play,
                    onTap: hasAudio ? _togglePlay : null,
                    size: 26,
                    isPrimary: true,
                  ),
                  // Next Page
                  _controlBtn(
                    icon: AppIcons.arrowRight,
                    onTap: _vm.isLastPage ? null : _next,
                  ),
                  // Skip to End (En Son)
                  _controlBtn(icon: AppIcons.skipForward, onTap: _skipToEnd),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _controlBtn({
    required IconData icon,
    required VoidCallback? onTap,
    double size = 18,
    bool isPrimary = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.all(isPrimary ? 14 : 10),
        decoration: BoxDecoration(
          color: isPrimary
              ? (onTap != null
                    ? AppColors.primary
                    : AppColors.textHint.withValues(alpha: 0.2))
              : onTap != null
              ? AppColors.primary.withValues(alpha: 0.08)
              : AppColors.surfaceVariant.withValues(alpha: 0.2),
          shape: BoxShape.circle,
          boxShadow: isPrimary && onTap != null
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.35),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Icon(
          icon,
          size: size,
          color: isPrimary
              ? (onTap != null ? Colors.white : AppColors.textHint)
              : onTap != null
              ? AppColors.primary
              : AppColors.textHint,
        ),
      ),
    );
  }

  String _formatDuration(Duration d) {
    final m = d.inMinutes;
    final s = d.inSeconds % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }
}

// Custom full-width track shape that places the seek line exactly at y=0 (no padding)
class FullWidthTrackShape extends RectangularSliderTrackShape {
  @override
  Rect getPreferredRect({
    required RenderBox parentBox,
    Offset offset = Offset.zero,
    required SliderThemeData sliderTheme,
    bool isEnabled = false,
    bool isDiscrete = false,
  }) {
    final double trackHeight = sliderTheme.trackHeight ?? 2.0;
    final double trackLeft = offset.dx;
    final double trackTop =
        offset.dy; // Align with y=0 of the Slider bounding box
    final double trackWidth = parentBox.size.width;
    return Rect.fromLTWH(trackLeft, trackTop, trackWidth, trackHeight);
  }
}
