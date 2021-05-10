import 'dart:async';

import 'package:flutter/services.dart';
import 'package:netmusic_flutter/music_item.dart';

class AudioPlayer {
  // 定义一个MethodChannel
  static final channel = const MethodChannel("netmusic.com/audio_player");

  // 单例
  factory AudioPlayer() => _getInstance();
  static AudioPlayer get instance => _getInstance();
  static AudioPlayer _instance;
  AudioPlayer._internal() {
    // 初始化
    channel.setMethodCallHandler(nativePlatformCallHandler);
  }

  static AudioPlayer _getInstance() {
    if (_instance == null) {
      _instance = new AudioPlayer._internal();
    }
    return _instance;
  }

  // 播放状态
  PlayerState _playerState = PlayerState.STOPPED;
  PlayerState get playerState => _playerState;

  // 时间
  int _totalPlayTime = 0;
  int _currentPlayTime = 0;
  int get totalPlayTime => _totalPlayTime;
  int get currentPlayTime => _currentPlayTime;
  String get totalPlayTimeStr => formatTime(_totalPlayTime);
  String get currentPlayTimeStr => formatTime(_currentPlayTime);

  // 歌曲
  MusicItem _item;
  set item(MusicItem item) {
    _item = item;
  }

  String get audioUrl {
    return _item != null
        ? "https://music.163.com/song/media/outer/url?id=${_item.id}.mp3"
        : "";
  }

  Future<int> togglePlay() async {
    if (_playerState == PlayerState.PLAYING) {
      return pause();
    } else {
      return play();
    }
  }

  /// 播放
  Future<int> play() async {
    if (_item == null) return 0;
    // 如果是停止状态
    if (_playerState == PlayerState.STOPPED ||
        _playerState == PlayerState.COMPLETED) {
      // 更新状态
      this.updatePlayerState(PlayerState.PLAYING);
      final result = await channel.invokeMethod("play", {'url': audioUrl});
      return result ?? 0;
    } else if (_playerState == PlayerState.PAUSED) {
      return resume();
    }
    return 0;
  }

  /// 继续播放
  Future<int> resume() async {
    // 更新状态
    this.updatePlayerState(PlayerState.PLAYING);
    final result = await channel.invokeMethod("resume", {'url': audioUrl});
    return result ?? 0;
  }

  /// 暂停
  Future<int> pause() async {
    // 更新状态
    this.updatePlayerState(PlayerState.PAUSED);
    final result = await channel.invokeMethod("pause", {'url': audioUrl});
    return result ?? 0;
  }

  /// 停止
  Future<int> stop() async {
    // 更新状态
    this.updatePlayerState(PlayerState.STOPPED);
    final result = await channel.invokeMethod("stop");
    return result ?? 0;
  }

  /// 播放
  Future<int> seek(int time) async {
    // 更新状态
    this.updatePlayerState(PlayerState.PLAYING);
    final result = await channel.invokeMethod("seek", {
      'position': time,
    });
    return result ?? 0;
  }

  /// Native主动调用的方法
  Future<void> nativePlatformCallHandler(MethodCall call) async {
    try {
      // 获取参数
      final callArgs = call.arguments as Map<dynamic, dynamic>;
      print('nativePlatformCallHandler call ${call.method} $callArgs');
      switch (call.method) {
        case 'onPosition':
          final time = callArgs['value'] as int;
          _currentPlayTime = time;
          _currentPlayTimeController.add(_currentPlayTime);
          break;
        case 'onComplete':
          this.updatePlayerState(PlayerState.COMPLETED);
          break;
        case 'onDuration':
          final time = callArgs['value'] as int;
          _totalPlayTime = time;
          _totalPlayTimeController.add(totalPlayTime);
          break;
        case 'onError':
          final error = callArgs['value'] as String;
          this.updatePlayerState(PlayerState.STOPPED);
          _errorController.add(error);
          break;
      }
    } catch (ex) {
      print('Unexpected error: $ex');
    }
  }

  // 播放状态
  final StreamController<PlayerState> _stateController =
      StreamController<PlayerState>.broadcast();
  Stream<PlayerState> get onPlayerStateChanged => _stateController.stream;

  // Video的时长和当前位置时间变化
  final StreamController<int> _totalPlayTimeController =
      StreamController<int>.broadcast();
  Stream<int> get onTotalTimeChanged => _totalPlayTimeController.stream;

  final StreamController<int> _currentPlayTimeController =
      StreamController<int>.broadcast();
  Stream<int> get onCurrentTimeChanged => _currentPlayTimeController.stream;

  // 发生错误
  final StreamController<String> _errorController = StreamController<String>();
  Stream<String> get onError => _errorController.stream;

  // 更新播放状态
  void updatePlayerState(PlayerState state, {bool stream = true}) {
    _playerState = state;
    if (stream) {
      _stateController.add(state);
    }
  }

  // 这里需要关闭流
  void dispose() {
    _stateController.close();
    _currentPlayTimeController.close();
    _totalPlayTimeController.close();
    _errorController.close();
  }

  // 格式化时间
  String formatTime(int time) {
    int min = (time ~/ 60);
    int sec = time % 60;
    String minStr = min < 10 ? "0$min" : "$min";
    String secStr = sec < 10 ? "0$sec" : "$sec";
    return "$minStr:$secStr";
  }
}

/// 播放状态
enum PlayerState {
  STOPPED,
  PLAYING,
  PAUSED,
  COMPLETED,
}
