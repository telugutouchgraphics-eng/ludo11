enum GameMode {
  vsComputer,
  localPassAndPlay,
  onlineMultiplayer;

  String get title {
    switch (this) {
      case GameMode.vsComputer:
        return 'Vs Computer';
      case GameMode.localPassAndPlay:
        return 'Pass & Play';
      case GameMode.onlineMultiplayer:
        return 'Online Multiplayer';
    }
  }

  String get subtitle {
    switch (this) {
      case GameMode.vsComputer:
        return 'Play with smart AI Bots';
      case GameMode.localPassAndPlay:
        return 'Play with friends on 1 phone';
      case GameMode.onlineMultiplayer:
        return 'Play with global players';
    }
  }
}
