import 'package:flutter/foundation.dart';

/// Service for handling in-app purchases
class PurchaseService {
  PurchaseService._();
  static final PurchaseService _instance = PurchaseService._();
  static PurchaseService get instance => _instance;

  // Product IDs
  static const String cameraSinglePrefix = 'camera_';
  static const String allProBundle = 'all_pro_cameras';

  // Price map (in production, fetch from App Store / Play Store)
  final Map<String, String> _prices = {
    'camera_kodak_portra_400': '\$2.99',
    'camera_kodak_ektar_100': '\$2.99',
    'camera_cinestill_800t': '\$3.99',
    'camera_fuji_pro_400h': '\$3.99',
    'camera_kodak_colorplus_200': '\$1.99',
    'camera_kodak_ultramax_400': '\$1.99',
    'camera_fuji_c200': '\$1.99',
    'camera_fuji_velvia_50': '\$4.99',
    'camera_fuji_provia_100f': '\$4.99',
    'camera_lomo_800': '\$2.99',
    'camera_agfa_vista_200': '\$2.49',
    'camera_kodak_vision3_500t': '\$3.99',
    'camera_kodak_trix_400': '\$2.49',
    'camera_kodak_tmax_400': '\$2.49',
    'camera_ilford_delta_3200': '\$3.99',
    'camera_fomapan_400': '\$1.99',
    'camera_rollei_retro_400s': '\$2.99',
    'camera_lomo_redscale': '\$2.99',
    'camera_lomo_purple': '\$3.49',
    'camera_aerochrome': '\$4.99',
    'camera_xpro_slide': '\$2.99',
    'camera_expired_film': '\$1.99',
    'camera_polaroid_600': '\$2.99',
    'camera_polaroid_sx70': '\$3.49',
    'camera_fuji_instax': '\$2.49',
    'camera_holga_plastic': '\$1.99',
    'camera_diana_f_plus': '\$1.99',
    'all_pro_cameras': '\$19.99',
  };

  /// Initialize the purchase service
  Future<void> initialize() async {
    // In production, initialize in_app_purchase package here
    debugPrint('PurchaseService initialized');
  }

  /// Get price for a camera
  String? getPriceForCamera(String cameraId) {
    return _prices['$cameraSinglePrefix$cameraId'];
  }

  /// Get price for the PRO bundle
  String get proBundlePrice => _prices[allProBundle] ?? '\$19.99';

  /// Purchase a single camera
  Future<bool> purchaseCamera(String cameraId) async {
    // In production, use in_app_purchase package
    debugPrint('Purchasing camera: $cameraId');
    
    // Simulate purchase
    await Future.delayed(const Duration(seconds: 2));
    
    // Return success (in production, check actual purchase result)
    return true;
  }

  /// Purchase all PRO cameras bundle
  Future<bool> purchaseProBundle() async {
    debugPrint('Purchasing PRO bundle');
    
    // Simulate purchase
    await Future.delayed(const Duration(seconds: 2));
    
    return true;
  }

  /// Restore previous purchases
  Future<List<String>> restorePurchases() async {
    debugPrint('Restoring purchases');
    
    // Simulate restore
    await Future.delayed(const Duration(seconds: 2));
    
    // Return list of previously purchased camera IDs
    // In production, query the store for purchased items
    return [];
  }

  /// Check if a camera is purchased
  Future<bool> isCameraPurchased(String cameraId) async {
    // In production, check against stored purchases
    return false;
  }
}
