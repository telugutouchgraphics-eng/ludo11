import 'package:shared_preferences/shared_preferences.dart';

class UserProfile {
  String name;
  String avatar;
  int coins;
  int xp;
  int level;
  int matchesPlayed;
  int matchesWon;
  int totalCaptures;
  String selectedThemeId;
  List<String> unlockedThemes;
  String selectedDiceSkinId;
  List<String> unlockedDiceSkins;
  String selectedTokenSkinId;
  List<String> unlockedTokenSkins;
  String selectedAvatarFrameId;
  List<String> unlockedAvatarFrameIds;
  bool soundEnabled;
  bool hapticEnabled;
  String? lastSpinDate;
  int loginStreak;
  String? lastLoginDate;

  UserProfile({
    this.name = 'Ludo Champion',
    this.avatar = 'crown',
    this.coins = 500, // Starter bonus virtual coins
    this.xp = 0,
    this.level = 1,
    this.matchesPlayed = 0,
    this.matchesWon = 0,
    this.totalCaptures = 0,
    this.selectedThemeId = 'classic_royal',
    List<String>? unlockedThemes,
    this.selectedDiceSkinId = 'classic_ivory',
    List<String>? unlockedDiceSkins,
    this.selectedTokenSkinId = 'classic_pawn',
    List<String>? unlockedTokenSkins,
    this.selectedAvatarFrameId = 'classic_wreath',
    List<String>? unlockedAvatarFrameIds,
    this.soundEnabled = true,
    this.hapticEnabled = true,
    this.lastSpinDate,
    this.loginStreak = 1,
    this.lastLoginDate,
  })  : unlockedThemes = unlockedThemes ?? ['classic_royal'],
        unlockedDiceSkins = unlockedDiceSkins ?? ['classic_ivory'],
        unlockedTokenSkins = unlockedTokenSkins ?? ['classic_pawn'],
        unlockedAvatarFrameIds = unlockedAvatarFrameIds ?? ['classic_wreath'];

  double get winRate =>
      matchesPlayed > 0 ? (matchesWon / matchesPlayed) * 100 : 0.0;

  String get _todayDateString {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  bool get canSpinToday {
    if (lastSpinDate == null) return true;
    return lastSpinDate != _todayDateString;
  }

  void claimSpinReward(int rewardCoins) {
    coins += rewardCoins;
    lastSpinDate = _todayDateString;
    save();
  }

  void updateDailyStreak() {
    final today = _todayDateString;
    if (lastLoginDate == today) return;

    if (lastLoginDate != null) {
      final lastDate = DateTime.tryParse(lastLoginDate!);
      if (lastDate != null) {
        final diff = DateTime.now().difference(lastDate).inDays;
        if (diff == 1) {
          loginStreak++;
        } else if (diff > 1) {
          loginStreak = 1;
        }
      }
    }
    lastLoginDate = today;
    save();
  }

  void addWin({int rewardCoins = 100, int rewardXp = 50}) {
    matchesPlayed++;
    matchesWon++;
    coins += rewardCoins;
    xp += rewardXp;
    _checkLevelUp();
    save();
  }

  void addLoss({int consolationCoins = 20, int consolationXp = 15}) {
    matchesPlayed++;
    coins += consolationCoins;
    xp += consolationXp;
    _checkLevelUp();
    save();
  }

  void recordCapture() {
    totalCaptures++;
    coins += 5; // Bonus coins for in-game feats
    save();
  }

  void _checkLevelUp() {
    int nextLevelXp = level * 100;
    if (xp >= nextLevelXp) {
      level++;
      coins += level * 50; // Level up reward
    }
  }

  static Future<UserProfile> load() async {
    final prefs = await SharedPreferences.getInstance();
    return UserProfile(
      name: prefs.getString('user_name') ?? 'Ludo Champion',
      avatar: prefs.getString('user_avatar') ?? 'crown',
      coins: prefs.getInt('user_coins') ?? 500,
      xp: prefs.getInt('user_xp') ?? 0,
      level: prefs.getInt('user_level') ?? 1,
      matchesPlayed: prefs.getInt('matches_played') ?? 0,
      matchesWon: prefs.getInt('matches_won') ?? 0,
      totalCaptures: prefs.getInt('total_captures') ?? 0,
      selectedThemeId: prefs.getString('selected_theme') ?? 'classic_royal',
      unlockedThemes:
          prefs.getStringList('unlocked_themes') ?? ['classic_royal'],
      selectedDiceSkinId:
          prefs.getString('selected_dice_skin') ?? 'classic_ivory',
      unlockedDiceSkins:
          prefs.getStringList('unlocked_dice_skins') ?? ['classic_ivory'],
      selectedTokenSkinId:
          prefs.getString('selected_token_skin') ?? 'classic_pawn',
      unlockedTokenSkins:
          prefs.getStringList('unlocked_token_skins') ?? ['classic_pawn'],
      selectedAvatarFrameId:
          prefs.getString('selected_avatar_frame') ?? 'classic_wreath',
      unlockedAvatarFrameIds:
          prefs.getStringList('unlocked_avatar_frames') ?? ['classic_wreath'],
      soundEnabled: prefs.getBool('sound_enabled') ?? true,
      hapticEnabled: prefs.getBool('haptic_enabled') ?? true,
      lastSpinDate: prefs.getString('last_spin_date'),
      loginStreak: prefs.getInt('login_streak') ?? 1,
      lastLoginDate: prefs.getString('last_login_date'),
    );
  }

  Future<void> save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_name', name);
    await prefs.setString('user_avatar', avatar);
    await prefs.setInt('user_coins', coins);
    await prefs.setInt('user_xp', xp);
    await prefs.setInt('user_level', level);
    await prefs.setInt('matches_played', matchesPlayed);
    await prefs.setInt('matches_won', matchesWon);
    await prefs.setInt('total_captures', totalCaptures);
    await prefs.setString('selected_theme', selectedThemeId);
    await prefs.setStringList('unlocked_themes', unlockedThemes);
    await prefs.setString('selected_dice_skin', selectedDiceSkinId);
    await prefs.setStringList('unlocked_dice_skins', unlockedDiceSkins);
    await prefs.setString('selected_token_skin', selectedTokenSkinId);
    await prefs.setStringList('unlocked_token_skins', unlockedTokenSkins);
    await prefs.setString('selected_avatar_frame', selectedAvatarFrameId);
    await prefs.setStringList('unlocked_avatar_frames', unlockedAvatarFrameIds);
    await prefs.setBool('sound_enabled', soundEnabled);
    await prefs.setBool('haptic_enabled', hapticEnabled);
    if (lastSpinDate != null) {
      await prefs.setString('last_spin_date', lastSpinDate!);
    }
    await prefs.setInt('login_streak', loginStreak);
    if (lastLoginDate != null) {
      await prefs.setString('last_login_date', lastLoginDate!);
    }
  }
}
