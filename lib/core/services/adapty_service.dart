import 'package:adapty_flutter/adapty_flutter.dart';
import 'package:children_stories/core/constants/app_constants.dart';
import 'package:children_stories/viewmodels/subscription_viewmodel.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AdaptyService {
  static Future<void> initialize() async {
    try {
      final configuration =
          AdaptyConfiguration(apiKey: AppConstants.adaptyPublicKey)
            ..withLogLevel(
              kDebugMode ? AdaptyLogLevel.verbose : AdaptyLogLevel.error,
            )
            ..withGoogleAdvertisingIdCollectionDisabled(true);
      await Adapty().activate(configuration: configuration);
    } catch (e) {
      debugPrint('[Adapty] initialize error: $e');
    }
  }

  static Future<void> identify(String userId) async {
    try {
      await Adapty().identify(userId);
    } catch (e) {
      debugPrint('[Adapty] identify error: $e');
    }
  }

  static Future<void> logout() async {
    try {
      await Adapty().logout();
    } catch (e) {
      debugPrint('[Adapty] logout error: $e');
    }
  }

  static Future<bool> checkPremiumStatus() async {
    try {
      final profile = await Adapty().getProfile();
      return profile.accessLevels[AppConstants.adaptyAccessLevelId]?.isActive ??
          profile.accessLevels.values.any((al) => al.isActive);
    } catch (e) {
      debugPrint('[Adapty] checkPremiumStatus error: $e');
      return false;
    }
  }

  static Future<void> showPaywall(BuildContext context) async {
    try {
      final paywall = await Adapty().getPaywall(
        placementId: AppConstants.adaptyPlacementId,
      );

      if (!context.mounted) return;

      final view = await AdaptyUI().createPaywallView(paywall: paywall);

      if (!context.mounted) return;

      // Register the event observer
      AdaptyUI().setPaywallsEventsObserver(_PaywallObserver(context));

      await view.present();
    } catch (e) {
      debugPrint('[Adapty] showPaywall error: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to load paywall: $e')));
      }
    }
  }
}

class _PaywallObserver implements AdaptyUIPaywallsEventsObserver {
  final BuildContext context;
  _PaywallObserver(this.context);

  @override
  void paywallViewDidPerformAction(
    AdaptyUIPaywallView view,
    AdaptyUIAction action,
  ) {
    if (action is CloseAction || action is AndroidSystemBackAction) {
      view.dismiss();
    }
  }

  @override
  void paywallViewDidFinishPurchase(
    AdaptyUIPaywallView view,
    AdaptyPaywallProduct product,
    AdaptyPurchaseResult purchaseResult,
  ) {
    if (purchaseResult is AdaptyPurchaseResultSuccess) {
      if (context.mounted) {
        try {
          context.read<SubscriptionViewModel>().checkSubscriptionStatus();
        } catch (e) {
          debugPrint('[AdaptyObserver] update status error: $e');
        }
      }
      view.dismiss();
    }
  }

  @override
  void paywallViewDidAppear(AdaptyUIPaywallView view) {}

  @override
  void paywallViewDidDisappear(AdaptyUIPaywallView view) {}

  @override
  void paywallViewDidSelectProduct(
    AdaptyUIPaywallView view,
    String productId,
  ) {}

  @override
  void paywallViewDidStartPurchase(
    AdaptyUIPaywallView view,
    AdaptyPaywallProduct product,
  ) {}

  @override
  void paywallViewDidFailPurchase(
    AdaptyUIPaywallView view,
    AdaptyPaywallProduct product,
    AdaptyError error,
  ) {}

  @override
  void paywallViewDidStartRestore(AdaptyUIPaywallView view) {}

  @override
  void paywallViewDidFinishRestore(
    AdaptyUIPaywallView view,
    AdaptyProfile profile,
  ) {
    if (context.mounted) {
      try {
        context.read<SubscriptionViewModel>().checkSubscriptionStatus();
      } catch (e) {
        debugPrint('[AdaptyObserver] update status error: $e');
      }
    }
  }

  @override
  void paywallViewDidFailRestore(AdaptyUIPaywallView view, AdaptyError error) {}

  @override
  void paywallViewDidFailLoadingProducts(
    AdaptyUIPaywallView view,
    AdaptyError error,
  ) {}

  @override
  void paywallViewDidFailRendering(
    AdaptyUIPaywallView view,
    AdaptyError error,
  ) {}

  @override
  void paywallViewDidFinishWebPaymentNavigation(
    AdaptyUIPaywallView view,
    AdaptyPaywallProduct? product,
    AdaptyError? error,
  ) {}
}
