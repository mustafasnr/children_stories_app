import 'package:adapty_flutter/adapty_flutter.dart';
import 'package:children_stories/core/constants/app_constants.dart';
import 'package:children_stories/data/repositories/subscription_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class SubscriptionViewModel extends ChangeNotifier {
  bool _isPremium = false;
  bool _isLoading = false;
  List<AdaptyPaywallProduct> _products = [];
  String? _error;

  bool get isPremium => _isPremium;
  bool get isLoading => _isLoading;
  List<AdaptyPaywallProduct> get products => _products;
  String? get error => _error;

  Future<void> checkSubscriptionStatus() async {
    final currentUser = Supabase.instance.client.auth.currentUser;
    if (currentUser == null || currentUser.isAnonymous) {
      _isPremium = false;
      notifyListeners();
      return;
    }

    try {
      // 1. Check Adapty status (local SDK state)
      bool localIsPremium = false;
      try {
        final profile = await Adapty().getProfile();
        localIsPremium =
            profile.accessLevels[AppConstants.adaptyAccessLevelId]?.isActive ??
            profile.accessLevels.values.any((al) => al.isActive);
      } catch (e) {
        debugPrint('[SubscriptionVM] Adapty check error: $e');
      }

      // 2. Check database subscription (remote source of truth)
      bool dbIsPremium = false;
      try {
        final subscription = await SubscriptionRepository().getSubscription(currentUser.id);
        dbIsPremium = subscription?.isActive ?? false;
      } catch (e) {
        debugPrint('[SubscriptionVM] Database subscription check error: $e');
      }

      _isPremium = localIsPremium || dbIsPremium;
    } catch (e) {
      debugPrint('[SubscriptionVM] checkStatus error: $e');
    }
    notifyListeners();
  }

  Future<void> fetchPaywallProducts() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final paywall = await Adapty().getPaywall(
        placementId: AppConstants.adaptyPlacementId,
      );
      _products = await Adapty().getPaywallProducts(paywall: paywall);
    } catch (e) {
      _error = 'Unable to load plans. Please try again.';
      debugPrint('[SubscriptionVM] fetchProducts error: $e');
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> purchase(AdaptyPaywallProduct product) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final result = await Adapty().makePurchase(product: product);
      if (result is AdaptyPurchaseResultSuccess) {
        _isPremium =
            result
                .profile
                .accessLevels[AppConstants.adaptyAccessLevelId]
                ?.isActive ??
            result.profile.accessLevels.values.any((al) => al.isActive);
      } else {
        _isPremium = false;
      }
      _isLoading = false;
      notifyListeners();
      return _isPremium;
    } catch (e) {
      _error = 'Purchase failed. Please try again.';
      debugPrint('[SubscriptionVM] purchase error: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> restorePurchases() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final profile = await Adapty().restorePurchases();
      _isPremium =
          profile.accessLevels[AppConstants.adaptyAccessLevelId]?.isActive ??
          profile.accessLevels.values.any((al) => al.isActive);
      _isLoading = false;
      notifyListeners();
      return _isPremium;
    } catch (e) {
      _error = 'Failed to restore purchases.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  Future<void> openStoreSubscriptions() async {
    Uri url;
    if (kIsWeb) return;
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      url = Uri.parse('https://apps.apple.com/account/subscriptions');
    } else if (defaultTargetPlatform == TargetPlatform.android) {
      url = Uri.parse('https://play.google.com/store/account/subscriptions');
    } else {
      return;
    }

    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      debugPrint('[SubscriptionVM] openStoreSubscriptions error: $e');
    }
  }
}
