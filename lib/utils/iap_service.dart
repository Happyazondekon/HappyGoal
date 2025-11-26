// lib/utils/iap_service.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'ad_controller.dart';
import 'iap_products.dart';

class IAPService {
  static final IAPService instance = IAPService._();
  IAPService._();

  final InAppPurchase _iap = InAppPurchase.instance;
  late StreamSubscription<List<PurchaseDetails>> _subscription;

  // ⭐ NOUVEAU : Un Stream pour prévenir l'UI du succès
  final StreamController<String> _purchaseSuccessController = StreamController<String>.broadcast();
  Stream<String> get purchaseSuccessStream => _purchaseSuccessController.stream;

  List<ProductDetails> _products = [];
  List<ProductDetails> get products => _products;

  bool _isAvailable = false;
  bool get isAvailable => _isAvailable;

  Future<void> initialize() async {
    _isAvailable = await _iap.isAvailable();
    if (!_isAvailable) return;

    final purchaseUpdated = _iap.purchaseStream;
    _subscription = purchaseUpdated.listen(
      _onPurchaseUpdate,
      onDone: () => _subscription.cancel(),
      onError: (error) => debugPrint("❌ Erreur Stream IAP: $error"),
    );

    await _loadProducts();
  }

  Future<void> _loadProducts() async {
    const Set<String> ids = <String>{...IAPProducts.allProductIds};
    final ProductDetailsResponse response = await _iap.queryProductDetails(ids);
    _products = response.productDetails;
    _products.sort((a, b) => a.rawPrice.compareTo(b.rawPrice));
  }

  Future<void> buyProduct(ProductDetails product) async {
    final PurchaseParam purchaseParam = PurchaseParam(productDetails: product);
    if (IAPProducts.allProductIds.contains(product.id)) {
      await _iap.buyConsumable(purchaseParam: purchaseParam);
    }
  }

  void _onPurchaseUpdate(List<PurchaseDetails> purchaseDetailsList) {
    purchaseDetailsList.forEach((PurchaseDetails purchaseDetails) async {
      if (purchaseDetails.status == PurchaseStatus.purchased ||
          purchaseDetails.status == PurchaseStatus.restored) {

        final bool valid = await _verifyPurchase(purchaseDetails);
        if (valid) {
          _deliverProduct(purchaseDetails);
        }

        if (purchaseDetails.pendingCompletePurchase) {
          await _iap.completePurchase(purchaseDetails);
        }
      }
    });
  }

  Future<bool> _verifyPurchase(PurchaseDetails purchaseDetails) async {
    return true; // Validation locale pour l'instant
  }

  void _deliverProduct(PurchaseDetails purchaseDetails) {
    final String productId = purchaseDetails.productID;
    debugPrint("🎁 Livraison du produit : $productId");

    final int coinsToAdd = IAPProducts.getCoinsForProduct(productId);
    if (coinsToAdd > 0) {
      AdController.instance.addCoins(coinsToAdd);
      // ⭐ NOUVEAU : On prévient l'UI que c'est un succès !
      _purchaseSuccessController.add(productId);
    }
  }

  void dispose() {
    _subscription.cancel();
    _purchaseSuccessController.close(); // ⭐ Nettoyage
  }
}