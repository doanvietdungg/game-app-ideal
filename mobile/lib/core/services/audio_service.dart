class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  void playFeedSound() {
    // Non-blocking Audio FX sound playback for feeding
  }

  void playTickleSound() {
    // Non-blocking Audio FX sound playback for tickling
  }

  void playStarSound() {
    // Non-blocking Audio FX sound playback for star reward
  }

  void playFanfareSound() {
    // Non-blocking Audio FX sound playback for level up celebration
  }
}
