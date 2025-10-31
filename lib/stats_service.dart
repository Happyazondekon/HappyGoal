// stats_service.dart
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/game_state.dart'; // Adaptez le chemin

class StatsService {
  static final StatsService _instance = StatsService._();
  factory StatsService() => _instance;
  StatsService._();

  static const String _statsKey = 'tournament_stats';

  Future<TournamentStats> loadTournamentStats() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final statsJson = prefs.getString(_statsKey);

      if (statsJson != null) {
        final Map<String, dynamic> statsMap = Map<String, dynamic>.from(json.decode(statsJson));
        final stats = TournamentStats.fromJson(statsMap);
        print('📊 Statistiques chargées: ${stats.tournamentsPlayed} tournois joués');
        return stats;
      } else {
        print('📊 Aucune statistique trouvée, création nouvelles stats');
        return TournamentStats();
      }
    } catch (e) {
      print('❌ Erreur lors du chargement des statistiques: $e');
      return TournamentStats();
    }
  }

  Future<void> saveTournamentStats(TournamentStats stats) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final statsJson = json.encode(stats.toJson());
      await prefs.setString(_statsKey, statsJson);
      print('💾 Statistiques sauvegardées: ${stats.tournamentsPlayed} tournois, ${stats.tournamentsWon} gagnés');
    } catch (e) {
      print('❌ Erreur lors de la sauvegarde des statistiques: $e');
    }
  }
}