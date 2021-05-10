import 'dart:convert';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:netmusic_flutter/audio_player.dart';
import 'package:netmusic_flutter/music_item.dart';
import 'package:netmusic_flutter/music_play_mode.dart';

class AppState extends ChangeNotifier {
  AppState() {
    this.loadJson();
    AudioPlayer().onPlayerStateChanged.listen((event) {
      if (event == PlayerState.COMPLETED) {
        nextItem(onComplte: true);
      }
      this.notifyListeners();
    });
  }

  /// 加载本地数据
  void loadJson() async {
    String jsonString =
        await rootBundle.loadString("assets/json/music_data.json");
    List<MusicItem> list = (json.decode(jsonString) as List<dynamic>)
        .map((e) => MusicItem.fromJson(e))
        .toList();
    this.musicItems = list;
    this.setCurrentMusicItem(list[0]);
  }

  /// 下一首歌曲,然后自动播放
  void nextItem({bool onComplte = false}) {
    if (_playMode == PlayerMode.shuffle) {
      randomPlayItem();
    } else {
      if (_playMode == PlayerMode.one && onComplte) {
        this.setCurrentMusicItem(musicItems.elementAt(currentMusicItemIndex),
            forcePlay: true);
      } else {
        if (currentMusicItemIndex == musicItems.length - 1) {
          this.setCurrentMusicItem(musicItems.elementAt(0), forcePlay: true);
        } else {
          this.setCurrentMusicItem(
              musicItems.elementAt(currentMusicItemIndex + 1),
              forcePlay: true);
        }
      }
    }
    notifyListeners();
  }

  /// 上一首歌曲,然后自动播放
  void preItem() {
    if (_playMode == PlayerMode.shuffle) {
      randomPlayItem();
    } else {
      if (currentMusicItemIndex == 0) {
        this.setCurrentMusicItem(musicItems.elementAt(musicItems.length - 1),
            forcePlay: true);
      } else {
        this.setCurrentMusicItem(
            musicItems.elementAt(currentMusicItemIndex - 1),
            forcePlay: true);
      }
    }
    notifyListeners();
  }

  /// 随机一首歌曲,然后自动播放
  void randomPlayItem() {
    int nextNumber = Random().nextInt(_musicItems.length);
    if (currentMusicItemIndex == nextNumber) {
      if (nextNumber == musicItems.length - 1) {
        nextNumber = 0;
      } else {
        nextNumber++;
      }
    }
    this.setCurrentMusicItem(musicItems.elementAt(nextNumber), forcePlay: true);
  }

  /// 设置所有的歌曲内容
  List<MusicItem> _musicItems = [];
  List<MusicItem> get musicItems => _musicItems;
  set musicItems(List<MusicItem> newList) {
    _musicItems = newList;
    notifyListeners();
  }

  /// 设置当前的歌曲索引
  MusicItem _currentMusicItem;
  MusicItem get currentMusicItem => _currentMusicItem;
  int currentMusicItemIndex = 0;

  /// 设置当前的歌曲
  void setCurrentMusicItem(MusicItem newCurrentMusicItem,
      {bool forcePlay = false}) {
    // 设置数据
    _currentMusicItem = newCurrentMusicItem;
    currentMusicItemIndex = musicItems.indexOf(currentMusicItem);
    // 通知数据改变
    notifyListeners();
    // 播放器设置MusicItem
    AudioPlayer().item = _currentMusicItem;
    // 正在播放的就进行播放
    if (forcePlay) {
      AudioPlayer().updatePlayerState(PlayerState.STOPPED, stream: false);
      AudioPlayer().play();
    }
  }

  // 播放模式
  PlayerMode _playMode = PlayerMode.loop;
  PlayerMode get playMode => _playMode;
  void changePlayMode() {
    if (playMode == PlayerMode.loop) {
      _playMode = PlayerMode.one;
    } else if (playMode == PlayerMode.one) {
      _playMode = PlayerMode.shuffle;
    } else {
      _playMode = PlayerMode.loop;
    }
    notifyListeners();
  }

  // 正在展示列表
  bool _isShowingList = false;
  bool get isShowingList => _isShowingList;
  set isShowingList(bool showing) {
    _isShowingList = showing;
    notifyListeners();
  }
}
