// lib/utils/iap_products.dart

class IAPProducts {
  // Consommables (Coins)
  static const String coinPackSmall = 'coin_pack_small';   // 25 coins
  static const String coinPackMedium = 'coin_pack_medium'; // 150 coins
  static const String coinPackLarge = 'coin_pack_large';   // 350 coins
  static const String coinPackGiant = 'coin_pack_giant';   // 800 coins

  // Abonnement (Optionnel pour l'instant)
  static const String monthlySubscription = 'premium_monthly';

  static const List<String> allProductIds = [
    coinPackSmall,
    coinPackMedium,
    coinPackLarge,
    coinPackGiant,
    // monthlySubscription, // Décommente si tu gères l'abonnement
  ];

  // Helper pour savoir combien de coins donner selon l'ID
  static int getCoinsForProduct(String productId) {
    switch (productId) {
      case coinPackSmall: return 25;
      case coinPackMedium: return 150;
      case coinPackLarge: return 350;
      case coinPackGiant: return 800;
      default: return 0;
    }
  }
}