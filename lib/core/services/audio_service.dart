import 'package:audio_session/audio_session.dart';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';

class AudioService {
  final AudioPlayer _player = AudioPlayer();
  bool _initialized = false;

  Stream<PlayerState> get playerStateStream => _player.playerStateStream;
  Stream<Duration> get positionStream => _player.positionStream;
  Stream<Duration?> get durationStream => _player.durationStream;

  bool get isPlaying => _player.playing;
  Duration get position => _player.position;
  Duration? get duration => _player.duration;

  Future<void> init() async {
    if (_initialized) return;
    try {
      final session = await AudioSession.instance;
      await session.configure(const AudioSessionConfiguration.speech());
      _initialized = true;
    } catch (e) {
      debugPrint('[Audio] init error: $e');
    }
  }

  Future<void> loadUrl(String url) async {
    try {
      await _player.setUrl(url);
    } catch (e) {
      debugPrint('[Audio] loadUrl error: $e');
    }
  }

  Future<void> play() async {
    try {
      await _player.play();
    } catch (e) {
      debugPrint('[Audio] play error: $e');
    }
  }

  Future<void> pause() async {
    try {
      await _player.pause();
    } catch (e) {
      debugPrint('[Audio] pause error: $e');
    }
  }

  Future<void> stop() async {
    try {
      await _player.stop();
      await _player.seek(Duration.zero);
    } catch (e) {
      debugPrint('[Audio] stop error: $e');
    }
  }

  Future<void> seek(Duration position) async {
    try {
      await _player.seek(position);
    } catch (e) {
      debugPrint('[Audio] seek error: $e');
    }
  }

  Future<void> rewind([int seconds = 10]) async {
    final target = position - Duration(seconds: seconds);
    await seek(target < Duration.zero ? Duration.zero : target);
  }

  Future<void> fastForward([int seconds = 10]) async {
    final dur = duration ?? Duration.zero;
    final target = position + Duration(seconds: seconds);
    await seek(target > dur ? dur : target);
  }

  void dispose() {
    _player.dispose();
  }
}
