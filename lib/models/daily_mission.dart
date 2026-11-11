enum MissionType { rollSix, captureToken, winMatch }

class DailyMission {
  final String id;
  final String title;
  final String description;
  final MissionType type;
  final int target;
  int currentProgress;
  final int rewardCoins;
  final int rewardXp;
  bool isClaimed;

  DailyMission({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.target,
    this.currentProgress = 0,
    required this.rewardCoins,
    required this.rewardXp,
    this.isClaimed = false,
  });

  bool get isCompleted => currentProgress >= target;

  double get progressPercentage => (currentProgress / target).clamp(0.0, 1.0);

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'type': type.index,
        'target': target,
        'currentProgress': currentProgress,
        'rewardCoins': rewardCoins,
        'rewardXp': rewardXp,
        'isClaimed': isClaimed,
      };

  factory DailyMission.fromJson(Map<String, dynamic> json) => DailyMission(
        id: json['id'] as String,
        title: json['title'] as String,
        description: json['description'] as String,
        type: MissionType.values[json['type'] as int],
        target: json['target'] as int,
        currentProgress: json['currentProgress'] as int? ?? 0,
        rewardCoins: json['rewardCoins'] as int,
        rewardXp: json['rewardXp'] as int,
        isClaimed: json['isClaimed'] as bool? ?? false,
      );
}
