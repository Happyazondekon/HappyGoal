class Player {
  final String name;
  final int skill; // 1-10, affects shot accuracy or save chance
  final String imageAsset;
  final String countryCode; // Pour associer le joueur à son pays/équipe

  Player({
    required this.name,
    required this.skill,
    required this.imageAsset,
    required this.countryCode,
  });

  // Méthode de fabrique pour créer un joueur à partir de données
  factory Player.fromData(Map<String, dynamic> data) {
    return Player(
      name: data['name'],
      skill: data['skill'],
      imageAsset: data['imageAsset'],
      countryCode: data['countryCode'],
    );
  }

  // Pour la sérialisation
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'skill': skill,
      'imageAsset': imageAsset,
      'countryCode': countryCode,
    };
  }
}

class Goalkeeper extends Player {
  // Poids spécifiques pour les attributs de gardien
  final int reflexes; // 1-10, vitesse de réaction
  final int positioning; // 1-10, positionnement dans les buts

  Goalkeeper({
    required String name,
    required int skill,
    required String imageAsset,
    required String countryCode,
    this.reflexes = 5,
    this.positioning = 5,
  }) : super(
    name: name,
    skill: skill,
    imageAsset: imageAsset,
    countryCode: countryCode,
  );

  // Returns a value between 0-2 representing the direction the goalkeeper will dive
  int predictDirection(int shooterSkill) {
    // Intelligence artificielle améliorée qui prend en compte les reflexes et le positionnement
    final random = DateTime.now().millisecondsSinceEpoch % 100;

    // Plus les reflexes sont élevés, plus le gardien a de chances de deviner correctement
    // Le skill du tireur diminue cette chance
    final chanceToGuessCorrectly = (reflexes * 5) - (shooterSkill * 2) + (positioning * 3);

    // Si le random est inférieur à la chance, le gardien devine correctement
    // Nous choisissons intentionnellement un nombre aléatoire pour la direction (0, 1, 2)
    if (random < chanceToGuessCorrectly) {
      // Le gardien essaie de deviner intelligemment
      // (Cette logique pourrait être améliorée avec des statistiques de tirs précédents)
      return random % 3;
    } else {
      // Le gardien plonge dans une direction aléatoire
      return (random % 3);
    }
  }

  // Méthode de fabrique pour créer des gardiens célèbres
  static List<Goalkeeper> getFamousGoalkeepers() {
    return [
      Goalkeeper(
        name: "Manuel Neuer",
        skill: 9,
        reflexes: 8,
        positioning: 9,
        imageAsset: "assets/images/players/neuer.png",
        countryCode: "DE",
      ),
      Goalkeeper(
        name: "Hugo Lloris",
        skill: 8,
        reflexes: 9,
        positioning: 7,
        imageAsset: "assets/images/players/lloris.png",
        countryCode: "FR",
      ),
      Goalkeeper(
        name: "Alisson Becker",
        skill: 9,
        reflexes: 8,
        positioning: 8,
        imageAsset: "assets/images/players/alisson.png",
        countryCode: "BR",
      ),
      // Ajoutez d'autres gardiens selon les équipes disponibles
    ];
  }
}

class Shooter extends Player {
  // Poids spécifiques pour les attributs d'attaquant
  final int accuracy; // 1-10, précision des tirs
  final int power; // 1-10, puissance des tirs

  Shooter({
    required String name,
    required int skill,
    required String imageAsset,
    required String countryCode,
    this.accuracy = 5,
    this.power = 5,
  }) : super(
    name: name,
    skill: skill,
    imageAsset: imageAsset,
    countryCode: countryCode,
  );

  // Calcule les chances de marquer en fonction des attributs
  double calculateScoringChance(Goalkeeper goalkeeper, int direction) {
    // Base sur la précision de l'attaquant contre les reflexes du gardien
    double baseChance = 50.0 + (accuracy * 3) - (goalkeeper.reflexes * 2);

    // Ajustement en fonction de la puissance et du positionnement
    baseChance += (power * 2) - (goalkeeper.positioning * 1.5);

    // Facteur aléatoire pour éviter les résultats trop prévisibles
    final random = DateTime.now().millisecondsSinceEpoch % 10;
    baseChance += random - 5; // -5 à +4

    // Limite entre 10% et 90% pour toujours garder un peu de suspense
    return baseChance.clamp(10.0, 90.0);
  }

  // Méthode de fabrique pour créer des attaquants célèbres
  static List<Shooter> getFamousShooters() {
    return [
      Shooter(
        name: "Kylian Mbappé",
        skill: 9,
        accuracy: 8,
        power: 8,
        imageAsset: "assets/images/players/striker.png",
        countryCode: "FR",
      ),
      Shooter(
        name: "Steve Mounié",
        skill: 9,
        accuracy: 9,
        power: 7,
        imageAsset: "assets/images/players/striker.png",
        countryCode: "BE",
      ),
      Shooter(
        name: "Toni Kroos",
        skill: 8,
        accuracy: 9,
        power: 7,
        imageAsset: "assets/images/players/striker.png",
        countryCode: "DE",
      ),
      // Ajoutez d'autres attaquants selon les équipes disponibles
    ];
  }
}