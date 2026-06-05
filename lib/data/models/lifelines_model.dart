class LifelinesModel {
  final bool team1CallUsed;
  final bool team1RevealUsed;
  final bool team1ExtendUsed;
  final bool team1AltUsed;
  final bool team2CallUsed;
  final bool team2RevealUsed;
  final bool team2ExtendUsed;
  final bool team2AltUsed;

  const LifelinesModel({
    this.team1CallUsed = false,
    this.team1RevealUsed = false,
    this.team1ExtendUsed = false,
    this.team1AltUsed = false,
    this.team2CallUsed = false,
    this.team2RevealUsed = false,
    this.team2ExtendUsed = false,
    this.team2AltUsed = false,
  });

  LifelinesModel copyWith({
    bool? team1CallUsed,
    bool? team1RevealUsed,
    bool? team1ExtendUsed,
    bool? team1AltUsed,
    bool? team2CallUsed,
    bool? team2RevealUsed,
    bool? team2ExtendUsed,
    bool? team2AltUsed,
  }) {
    return LifelinesModel(
      team1CallUsed: team1CallUsed ?? this.team1CallUsed,
      team1RevealUsed: team1RevealUsed ?? this.team1RevealUsed,
      team1ExtendUsed: team1ExtendUsed ?? this.team1ExtendUsed,
      team1AltUsed: team1AltUsed ?? this.team1AltUsed,
      team2CallUsed: team2CallUsed ?? this.team2CallUsed,
      team2RevealUsed: team2RevealUsed ?? this.team2RevealUsed,
      team2ExtendUsed: team2ExtendUsed ?? this.team2ExtendUsed,
      team2AltUsed: team2AltUsed ?? this.team2AltUsed,
    );
  }

  Map<String, dynamic> toMap() => {
    'team1CallUsed': team1CallUsed,
    'team1RevealUsed': team1RevealUsed,
    'team1ExtendUsed': team1ExtendUsed,
    'team1AltUsed': team1AltUsed,
    'team2CallUsed': team2CallUsed,
    'team2RevealUsed': team2RevealUsed,
    'team2ExtendUsed': team2ExtendUsed,
    'team2AltUsed': team2AltUsed,
  };

  factory LifelinesModel.fromMap(Map<String, dynamic> map) => LifelinesModel(
    team1CallUsed: map['team1CallUsed'] ?? false,
    team1RevealUsed: map['team1RevealUsed'] ?? false,
    team1ExtendUsed: map['team1ExtendUsed'] ?? false,
    team1AltUsed: map['team1AltUsed'] ?? false,
    team2CallUsed: map['team2CallUsed'] ?? false,
    team2RevealUsed: map['team2RevealUsed'] ?? false,
    team2ExtendUsed: map['team2ExtendUsed'] ?? false,
    team2AltUsed: map['team2AltUsed'] ?? false,
  );
}