import 'package:flutter/foundation.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:sunsafe_checkin/core/constants/app_constants.dart';

/// RevenueCat wrapper for premium feature gating.
class RevenueCatService {
  RevenueCatService._();

  static bool _configured = false;

  static Future<void> initialize({required String apiKey}) async {
    if (_configured) return;

    await Purchases.setLogLevel(kDebugMode ? LogLevel.debug : LogLevel.info);
    await Purchases.configure(PurchasesConfiguration(apiKey));
    _configured = true;
  }

  static Future<bool> isPremiumActive() async {
    final info = await Purchases.getCustomerInfo();
    return info.entitlements.active
        .containsKey(AppConstants.revenueCatEntitlementPremium);
  }

  static Future<Offerings?> getOfferings() async {
    try {
      return await Purchases.getOfferings();
    } catch (e) {
      debugPrint('RevenueCatService.getOfferings error: $e');
      return null;
    }
  }

  static Future<CustomerInfo> purchasePackage(Package package) async {
    return Purchases.purchasePackage(package);
  }

  static Future<CustomerInfo> restorePurchases() async {
    return Purchases.restorePurchases();
  }
}
