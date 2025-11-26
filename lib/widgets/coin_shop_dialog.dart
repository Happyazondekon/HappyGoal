// lib/widgets/coin_shop_dialog.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import '../utils/iap_service.dart';
import '../utils/ad_controller.dart';
import '../utils/iap_products.dart';
import '../utils/audio_manager.dart'; // Pour le son de succès

class CoinShopDialog extends StatefulWidget {
  const CoinShopDialog({Key? key}) : super(key: key);

  @override
  State<CoinShopDialog> createState() => _CoinShopDialogState();
}

class _CoinShopDialogState extends State<CoinShopDialog> {
  // ⭐ Pour écouter le succès
  StreamSubscription? _successSubscription;

  @override
  void initState() {
    super.initState();
    // ⭐ On écoute le stream de succès dès l'ouverture de la boutique
    _successSubscription = IAPService.instance.purchaseSuccessStream.listen((productId) {
      if (mounted) {
        // On ferme le loader s'il y en avait un (optionnel) et on affiche le succès
        _showSuccessDialog(productId);
      }
    });
  }

  @override
  void dispose() {
    _successSubscription?.cancel(); // ⭐ Très important d'annuler
    super.dispose();
  }

  // ⭐ La magnifique dialogue de succès
  void _showSuccessDialog(String productId) {
    // Jouer un son de victoire si possible
    AudioManager.playSound('whistle'); // Ou un son de "caisse enregistreuse" si tu as

    int coins = IAPProducts.getCoinsForProduct(productId);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: TweenAnimationBuilder(
          duration: const Duration(milliseconds: 500),
          tween: Tween<double>(begin: 0.5, end: 1.0),
          curve: Curves.elasticOut,
          builder: (context, double value, child) {
            return Transform.scale(
              scale: value,
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(color: const Color(0xFFFFD700), width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Icône animée ou statique
                    const CircleAvatar(
                      radius: 35,
                      backgroundColor: Color(0xFF4CAF50),
                      child: Icon(Icons.check, color: Colors.white, size: 40),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      "Paiement Réussi !",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "+$coins Coins ajoutés",
                      style: const TextStyle(
                        fontSize: 18,
                        color: Color(0xFF1B5E20),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    const Text(
                      "Merci pour votre soutien !",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 25),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop(); // Ferme le dialogue succès
                          Navigator.of(context).pop(); // Ferme la boutique (optionnel, si tu veux revenir au jeu)
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4CAF50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text("SUPER !", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final products = IAPService.instance.products;

    return AlertDialog(
      backgroundColor: const Color(0xFF0F3622), // Vert foncé Noël
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        children: const [
          Icon(Icons.storefront, color: Color(0xFFFFD700), size: 30),
          SizedBox(width: 10),
          Text('Boutique de Noël', style: TextStyle(color: Colors.white)),
        ],
      ),
      content: Container(
        width: double.maxFinite,
        constraints: const BoxConstraints(maxHeight: 400),
        child: products.isEmpty
            ? const SizedBox(
          height: 100,
          child: Center(
            child: Text(
              "Connexion au magasin du Père Noël...\n(Chargement...)",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white70),
            ),
          ),
        )
            : ListView.builder(
          shrinkWrap: true,
          itemCount: products.length,
          itemBuilder: (context, index) {
            final product = products[index];
            return _buildProductItem(product);
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Fermer', style: TextStyle(color: Colors.white70)),
        ),
      ],
    );
  }

  Widget _buildProductItem(ProductDetails product) {
    int coins = IAPProducts.getCoinsForProduct(product.id);

    String? bonusText;
    Color bonusColor = Colors.redAccent;

    if (product.id == IAPProducts.coinPackMedium) { bonusText = "+10% BONUS"; bonusColor = Colors.blue; }
    if (product.id == IAPProducts.coinPackLarge) { bonusText = "+17% PROMO"; bonusColor = Colors.orange; }
    if (product.id == IAPProducts.coinPackGiant) { bonusText = "MEILLEURE OFFRE"; bonusColor = const Color(0xFFFFD700); }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          // Image/Icone Coin
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFFFD700).withOpacity(0.2),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFFFD700), width: 1),
            ),
            child: const Icon(Icons.monetization_on, color: Color(0xFFFFD700), size: 24),
          ),
          const SizedBox(width: 15),

          // Détails
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "$coins Coins",
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16
                  ),
                ),
                if (bonusText != null)
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                        color: bonusColor,
                        borderRadius: BorderRadius.circular(4)
                    ),
                    child: Text(
                      bonusText,
                      style: TextStyle(
                          color: bonusColor == const Color(0xFFFFD700) ? Colors.black : Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Bouton Achat
          ElevatedButton(
            onPressed: () {
              IAPService.instance.buyProduct(product);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4CAF50),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              elevation: 4,
            ),
            child: Text(
              product.price,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}