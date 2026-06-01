import 'package:children_stories/app/theme/app_colors.dart';
import 'package:children_stories/app/theme/app_text_styles.dart';
import 'package:children_stories/viewmodels/auth_viewmodel.dart';
import 'package:children_stories/viewmodels/profile_viewmodel.dart';
import 'package:children_stories/viewmodels/subscription_viewmodel.dart';
import 'package:children_stories/views/settings/widgets/anon_upgrade_card.dart';
import 'package:children_stories/views/settings/widgets/subscription_section.dart';
import 'package:children_stories/views/settings/widgets/settings_section.dart';
import 'package:children_stories/views/settings/widgets/text_size_card.dart';
import 'package:children_stories/views/settings/widgets/user_header.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late final ProfileViewModel _vm;
  String _appVersion = '1.0.0';

  @override
  void initState() {
    super.initState();
    _vm = ProfileViewModel();
    final userId = context.read<AuthViewModel>().currentUser?.id;
    if (userId != null) _vm.loadProfile(userId);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SubscriptionViewModel>().checkSubscriptionStatus();
    });
    _initPackageInfo();
  }

  Future<void> _initPackageInfo() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      if (mounted) {
        setState(() {
          _appVersion = packageInfo.version;
        });
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _vm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _vm,
      child: Consumer<ProfileViewModel>(
        builder: (context, vm, _) {
          final authVM = context.read<AuthViewModel>();
          final subVM = context.watch<SubscriptionViewModel>();
          final isPremium = subVM.isPremium;
          final isAnonymous = authVM.isAnonymous;
          final user = authVM.currentUser;
          final profile = vm.profile;
          final avatarUrl =
              profile?.avatarUrl ??
              user?.userMetadata?['avatar_url'] as String? ??
              user?.userMetadata?['picture'] as String?;
          final name =
              profile?.displayName ??
              user?.userMetadata?['full_name'] as String? ??
              user?.userMetadata?['name'] as String? ??
              'Reader';

          return Scaffold(
            appBar: AppBar(
              elevation: 0,
              scrolledUnderElevation: 0,
              centerTitle: true,
              automaticallyImplyLeading: false,
              title: Text(
                'Settings',
                style: AppTextStyles.headlineLarge.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            body: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                children: [
                  if (isAnonymous) ...[
                    const AnonUpgradeCard(),
                  ] else ...[
                    UserHeader(
                      avatarUrl: avatarUrl,
                      name: name,
                      email: user?.email,
                      initials: profile?.initials,
                      isPremium: isPremium,
                    ),
                  ],
                  const SizedBox(height: 24),

                  // Subscription status section
                  const SubscriptionSection(),

                  Divider(
                    color: AppColors.textHint.withValues(alpha: 0.15),
                    thickness: 1.2,
                    height: 36,
                  ),

                  // Settings list
                  const SettingsSection(),
                  const SizedBox(height: 24),

                  // Text Size setting card
                  const TextSizeCard(),

                  const SizedBox(height: 48),
                  Text.rich(
                    TextSpan(
                      text: 'Children Stories ',
                      children: [
                        TextSpan(
                          text: 'v$_appVersion',
                          style: const TextStyle(fontWeight: FontWeight.w900),
                        ),
                      ],
                    ),
                    style: AppTextStyles.labelMedium,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
