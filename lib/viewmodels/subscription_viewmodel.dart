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
  DateTime? _expiresAt;

  bool get isPremium => _isPremium;
  bool get isLoading => _isLoading;
  List<AdaptyPaywallProduct> get products => _products;
  String? get error => _error;
  DateTime? get expiresAt => _expiresAt;

  Future<void> checkSubscriptionStatus() async {
    final currentUser = Supabase.instance.client.auth.currentUser;
    if (currentUser == null || currentUser.isAnonymous) {
      _isPremium = false;
      _expiresAt = null;
      notifyListeners();
      return;
    }

    try {
      // 1. Check Adapty status (local SDK state)
      bool localIsPremium = false;
      DateTime? localExpiresAt;
      try {
        final profile = await Adapty().getProfile();
        final accessLevel =
            profile.accessLevels[AppConstants.adaptyAccessLevelId];
        if (accessLevel != null) {
          localIsPremium = accessLevel.isActive;
          localExpiresAt = accessLevel.expiresAt;
        } else {
          for (final al in profile.accessLevels.values) {
            if (al.isActive) {
              localIsPremium = true;
              localExpiresAt = al.expiresAt;
            }
          }
        }
      } catch (e) {
        debugPrint('[SubscriptionVM] Adapty check error: $e');
      }

      // 2. Check database subscription (remote source of truth)
      bool dbIsPremium = false;
      DateTime? dbExpiresAt;
      try {
        final subscription = await SubscriptionRepository().getSubscription(
          currentUser.id,
        );
        dbIsPremium = subscription?.isActive ?? false;
        dbExpiresAt = subscription?.expiresAt;
      } catch (e) {
        debugPrint('[SubscriptionVM] Database subscription check error: $e');
      }

      _isPremium = localIsPremium || dbIsPremium;
      _expiresAt = localExpiresAt ?? dbExpiresAt;
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
        final accessLevel =
            result.profile.accessLevels[AppConstants.adaptyAccessLevelId];
        _isPremium =
            accessLevel?.isActive ??
            result.profile.accessLevels.values.any((al) => al.isActive);
        if (accessLevel != null && accessLevel.expiresAt != null) {
          _expiresAt = accessLevel.expiresAt;
        } else {
          DateTime? fallbackExpires;
          for (final al in result.profile.accessLevels.values) {
            if (al.isActive && al.expiresAt != null) {
              fallbackExpires = al.expiresAt;
              break;
            }
          }
          _expiresAt = fallbackExpires;
        }
      } else {
        _isPremium = false;
        _expiresAt = null;
      }
      _isLoading = false;
      notifyListeners();
      return _isPremium;
    } catch (e) {
      _error = 'Purchase failed. Please try again.';
      debugPrint('[SubscriptionVM] purchase error: $e');
      _isLoading = false;
      _expiresAt = null;
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
      final accessLevel =
          profile.accessLevels[AppConstants.adaptyAccessLevelId];
      _isPremium =
          accessLevel?.isActive ??
          profile.accessLevels.values.any((al) => al.isActive);
      if (accessLevel != null && accessLevel.expiresAt != null) {
        _expiresAt = accessLevel.expiresAt;
      } else {
        DateTime? fallbackExpires;
        for (final al in profile.accessLevels.values) {
          if (al.isActive && al.expiresAt != null) {
            fallbackExpires = al.expiresAt;
            break;
          }
        }
        _expiresAt = fallbackExpires;
      }
      _isLoading = false;
      notifyListeners();
      return _isPremium;
    } catch (e) {
      _error = 'Failed to restore purchases.';
      _isLoading = false;
      _expiresAt = null;
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
