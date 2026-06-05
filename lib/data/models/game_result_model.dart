import 'lifelines_model.dart';

class GameResultModel {
  final int team1Points;
  final int team2Points;
  final LifelinesModel lifelines;

  const GameResultModel({
    required this.team1Points,
    required this.team2Points,
    required this.lifelines,
  });
}