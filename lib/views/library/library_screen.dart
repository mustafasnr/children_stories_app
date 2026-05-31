import 'package:children_stories/app/theme/app_text_styles.dart';
import 'package:children_stories/viewmodels/auth_viewmodel.dart';
import 'package:children_stories/viewmodels/home_viewmodel.dart';
import 'package:children_stories/viewmodels/library_viewmodel.dart';
import 'package:children_stories/views/explore/widgets/book_card.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  String? _lastUserId;
  String? _lastLangCode;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final authVM = context.watch<AuthViewModel>();
    final homeVM = context.watch<HomeViewModel>();

    if (!authVM.isAnonymous && authVM.currentUser?.id != null) {
      final userId = authVM.currentUser!.id;
      final langCode = homeVM.selectedLanguage?.code ?? 'en';

      if (userId != _lastUserId || langCode != _lastLangCode) {
        _lastUserId = userId;
        _lastLangCode = langCode;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            context.read<LibraryViewModel>().initialize(
                  userId: userId,
                  languageCode: langCode,
                );
          }
        });
      }
    } else {
      _lastUserId = null;
      _lastLangCode = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final authVM = context.watch<AuthViewModel>();

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        title: Text(
          'Library',
          style: AppTextStyles.headlineLarge.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: authVM.isAnonymous
          ? _buildGuestView(context)
          : Consumer<LibraryViewModel>(
              builder: (context, vm, _) {
                if (vm.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (vm.error != null) {
                  return _buildErrorView(vm);
                }
                if (vm.books.isEmpty) {
                  return RefreshIndicator(
                    color: Theme.of(context).colorScheme.primary,
                    onRefresh: vm.refresh,
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.7,
                          child: _buildEmptyView(context),
                        ),
                      ],
                    ),
                  );
                }
                return RefreshIndicator(
                  color: Theme.of(context).colorScheme.primary,
                  onRefresh: vm.refresh,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    itemCount: vm.books.length,
                    itemBuilder: (context, index) {
                      return BookCard(book: vm.books[index]);
                    },
                  ),
                );
              },
            ),
    );
  }

  Widget _buildGuestView(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.bookmarks_outlined,
                size: 44,
                color: colorScheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Sign in to save stories',
              style: AppTextStyles.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              'Keep track of your favorite stories and reading progress by creating an account.',
              style: AppTextStyles.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            FilledButton(
              onPressed: () => context.push('/login?upgrade=true'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
                  vertical: 14,
                ),
              ),
              child: Text(
                'Sign In / Sign Up',
                style: AppTextStyles.buttonLarge.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyView(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 48),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: colorScheme.secondaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.bookmark_border_rounded,
                size: 44,
                color: colorScheme.onSecondaryContainer,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Your library is empty',
              style: AppTextStyles.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              'Tap the bookmark icon on any story to save it here for quick access.',
              style: AppTextStyles.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorView(LibraryViewModel vm) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: colorScheme.errorContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.wifi_off_rounded,
                size: 42,
                color: colorScheme.onErrorContainer,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Oops! Something went wrong',
              style: AppTextStyles.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              vm.error ?? 'We couldn\'t load your library. Please try again.',
              style: AppTextStyles.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: vm.refresh,
              icon: const Icon(Icons.refresh_rounded, size: 20),
              label: const Text('Try Again'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
                  vertical: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
