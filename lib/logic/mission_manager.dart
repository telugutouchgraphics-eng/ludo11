import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/daily_mission.dart';
import '../models/user_profile.dart';

class MissionManager {
  static final MissionManager instance = MissionManager._internal();
  MissionManager._internal();

  List<DailyMission> missions = [];

  String get _todayDateString {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  int get unclaimedCount =>
      missions.where((m) => m.isCompleted && !m.isClaimed).length;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final lastDate = prefs.getString('missions_date');
    final today = _todayDateString;

    if (lastDate != today) {
      _generateNewDailyMissions();
      await _save(prefs, today);
    } else {
      final jsonList = prefs.getStringList('missions_data');
      if (jsonList != null && jsonList.isNotEmpty) {
        missions = jsonList
            .map((item) => DailyMission.fromJson(jsonDecode(item)))
            .toList();
      } else {
        _generateNewDailyMissions();
        await _save(prefs, today);
      }
    }
  }

  void _generateNewDailyMissions() {
    missions = [
      DailyMission(
        id: 'six_master',
        title: 'Six Master',
        description: 'Roll the number 6 three times',
        type: MissionType.rollSix,
        target: 3,
        rewardCoins: 80,
        rewardXp: 40,
      ),
      DailyMission(
        id: 'token_hunter',
        title: 'Token Hunter',
        description: 'Capture 2 opponent tokens',
        type: MissionType.captureToken,
        target: 2,
        rewardCoins: 120,
        rewardXp: 60,
      ),
      DailyMission(
        id: 'arena_champion',
        title: 'Arena Champion',
        description: 'Win 1 match in any game mode',
        type: MissionType.winMatch,
        target: 1,
        rewardCoins: 150,
        rewardXp: 80,
      ),
    ];
  }

  void trackSixRoll() {
    _advanceMission(MissionType.rollSix);
  }

  void trackTokenCapture() {
    _advanceMission(MissionType.captureToken);
  }

  void trackMatchWin() {
    _advanceMission(MissionType.winMatch);
  }

  void _advanceMission(MissionType type) {
    for (var m in missions) {
      if (m.type == type && !m.isCompleted) {
        m.currentProgress++;
        _persistChanges();
        break;
      }
    }
  }

  bool claimReward(DailyMission mission, UserProfile profile) {
    if (mission.isCompleted && !mission.isClaimed) {
      mission.isClaimed = true;
      profile.coins += mission.rewardCoins;
      profile.xp += mission.rewardXp;
      profile.save();
      _persistChanges();
      return true;
    }
    return false;
  }

  Future<void> _persistChanges() async {
    final prefs = await SharedPreferences.getInstance();
    await _save(prefs, _todayDateString);
  }

  Future<void> _save(SharedPreferences prefs, String date) async {
    await prefs.setString('missions_date', date);
    final jsonList =
        missions.map((m) => jsonEncode(m.toJson())).toList();
    await prefs.setStringList('missions_data', jsonList);
  }
}
