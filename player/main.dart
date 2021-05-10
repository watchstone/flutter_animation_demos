import 'dart:math';

import 'package:flutter/material.dart';
import 'package:netmusic_flutter/app_state.dart';
import 'package:netmusic_flutter/audio_player.dart';
import 'package:netmusic_flutter/music_list.dart';
import 'package:netmusic_flutter/music_play_mode.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(ChangeNotifierProvider(
    create: (ctx) => AppState(),
    child: MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: HomeContent(),
    );
  }
}

class HomeContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
            image: AssetImage("assets/images/cm2_fm_bg.jpg"),
            fit: BoxFit.cover),
      ),
      child: SafeArea(child: MusicPage()),
    );
  }
}

class MusicPage extends StatefulWidget {
  @override
  _MusicPageState createState() => _MusicPageState();
}

class _MusicPageState extends State<MusicPage> with TickerProviderStateMixin {
  AnimationController _needleController;
  Animation _needleCurve;
  Animation _needleRotateAnimation;

  AnimationController _discController;
  Animation _discRotateAnimation;

  @override
  void initState() {
    super.initState();
    // 指针的旋转
    _needleController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 250));
    _needleCurve =
        CurvedAnimation(parent: _needleController, curve: Curves.decelerate);
    _needleRotateAnimation =
        Tween(begin: -pi / 8.0, end: 0.0).animate(_needleCurve);
    // disc的旋转
    _discController = AnimationController(
        vsync: this, duration: Duration(milliseconds: 8000));
    _discRotateAnimation =
        Tween(begin: 0.0, end: pi * 2.0).animate(_discController);
    // 不断的转
    _discController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _discController.reset();
        _discController.forward();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      alignment: AlignmentDirectional.topCenter,
      children: [
        _buildTitle(context),
        _buildDisc(context),
        _buildNeedle(context),
        _buildBottomButtons(context),
        _buildMaskView(),
        _buildList(context),
      ],
    );
  }

  Widget _buildTitle(BuildContext context) {
    return Positioned(
      top: 20,
      height: 30,
      child: Consumer<AppState>(
        builder: (context, appstate, child) {
          return Text(
            appstate.currentMusicItem != null
                ? appstate.currentMusicItem.name
                : "",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w500,
              fontSize: 20,
            ),
          );
        },
      ),
    );
  }

  Widget _buildNeedle(BuildContext context) {
    MediaQueryData queryData = MediaQuery.of(context);
    return Positioned(
      child: AnimatedBuilder(
          animation: _needleRotateAnimation,
          builder: (ctx, widget) {
            return Transform.rotate(
              angle: _needleRotateAnimation.value,
              alignment: Alignment(-0.5, -(2.25 / 3.25)),
              child: Image.asset("assets/images/cm2_play_needle_play.png"),
            );
          }),
      top: 50,
      left: ((queryData.size.width - 60) / 2),
      width: 128,
      height: 196,
    );
  }

  Widget _buildDisc(BuildContext context) {
    MediaQueryData queryData = MediaQuery.of(context);
    final double width = (queryData.size.width - 64);
    return Positioned(
      top: 160,
      child: Container(
        width: width,
        height: width,
        foregroundDecoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/cm2_play_disc.png"),
          ),
        ),
        child: Padding(
            padding: EdgeInsets.all(50.0),
            child: AnimatedBuilder(
              animation: _discRotateAnimation,
              builder: (context, child) {
                return Transform.rotate(
                  angle: _discRotateAnimation.value,
                  child: ClipOval(
                    child:
                        Consumer<AppState>(builder: (context, appState, child) {
                      return appState.currentMusicItem != null
                          ? Image.network(appState.currentMusicItem.picUrl)
                          : Container();
                    }),
                  ),
                );
              },
            )),
      ),
    );
  }

  Widget _buildBottomButtons(BuildContext context) {
    MediaQueryData queryData = MediaQuery.of(context);
    final double width = queryData.size.width;
    return Positioned(
        bottom: 20,
        left: 0,
        width: width,
        child: Column(
          children: [
            Row(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: 30,
                ),
                StreamBuilder(
                  initialData: "00:00",
                  stream: AudioPlayer().onCurrentTimeChanged,
                  builder: (context, snapshot) {
                    if (!snapshot.hasData)
                      return Text(
                        "00:00",
                        style: TextStyle(color: Colors.white70),
                      );
                    print(snapshot.data);
                    return Text(
                      AudioPlayer().currentPlayTimeStr,
                      style: TextStyle(color: Colors.white70),
                    );
                  },
                ),
                SizedBox(
                  width: 5,
                ),
                Expanded(
                  child: SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: Colors.white,
                      inactiveTrackColor: Colors.white70,
                      trackShape: RoundedRectSliderTrackShape(),
                      trackHeight: 2.0,
                      thumbShape:
                          RoundSliderThumbShape(enabledThumbRadius: 4.0),
                      thumbColor: Colors.white,
                      overlayColor: Colors.red.withAlpha(32),
                      overlayShape: RoundSliderOverlayShape(overlayRadius: 4.0),
                      tickMarkShape: RoundSliderTickMarkShape(),
                    ),
                    child: StreamBuilder(
                      stream: AudioPlayer().onCurrentTimeChanged,
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return Slider(
                            min: 0.0,
                            max: 0.0,
                            value: 0.0,
                            onChanged: (value) {
                              print("onChange");
                            },
                          );
                        }
                        return Slider(
                          min: 0.0,
                          max: AudioPlayer().totalPlayTime.toDouble(),
                          value: AudioPlayer().currentPlayTime.toDouble(),
                          onChanged: (value) {
                            AudioPlayer().seek(value.toInt());
                            print("seek to ${value.toInt()}");
                          },
                        );
                      },
                    ),
                  ),
                ),
                SizedBox(
                  width: 5,
                ),
                StreamBuilder(
                  initialData: "00:00",
                  stream: AudioPlayer().onTotalTimeChanged,
                  builder: (context, snapshot) {
                    if (!snapshot.hasData)
                      return Text(
                        "00:00",
                        style: TextStyle(color: Colors.white70),
                      );
                    return Text(
                      AudioPlayer().totalPlayTimeStr,
                      style: TextStyle(color: Colors.white70),
                    );
                  },
                ),
                SizedBox(
                  width: 30,
                ),
              ],
            ),
            Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Consumer<AppState>(
                  builder: (context, appState, child) {
                    String iconName = "assets/images/cm2_icn_loop_prs.png";
                    if (appState.playMode == PlayerMode.one) {
                      iconName = "assets/images/cm2_icn_one_prs.png";
                    } else if (appState.playMode == PlayerMode.shuffle) {
                      iconName = "assets/images/cm2_icn_shuffle_prs.png";
                    }
                    return IconButton(
                      icon: Image.asset(iconName),
                      iconSize: 60,
                      onPressed: () {
                        appState.changePlayMode();
                      },
                    );
                  },
                ),
                Consumer<AppState>(
                  builder: (context, appState, child) {
                    return IconButton(
                      icon: child,
                      iconSize: 30,
                      onPressed: () {
                        appState.preItem();
                        resetPlayerAndBeginPlay();
                      },
                    );
                  },
                  child:
                      Image.asset("assets/images/cm2_vehicle_btn_prev_prs.png"),
                ),
                Consumer<AppState>(builder: (context, appState, child) {
                  return IconButton(
                    icon: Image.asset(
                        AudioPlayer().playerState == PlayerState.PLAYING
                            ? "assets/images/cm2_vehicle_btn_pause_prs.png"
                            : "assets/images/cm2_vehicle_btn_play_prs.png"),
                    iconSize: 100,
                    onPressed: () {
                      _needleController.stop();
                      if (AudioPlayer().playerState == PlayerState.PLAYING) {
                        _needleController.reverse();
                        _discController.stop();
                      } else {
                        _needleController.forward();
                        _discController.forward();
                      }
                      AudioPlayer().togglePlay();
                    },
                  );
                }),
                Consumer<AppState>(
                  builder: (context, appState, child) {
                    return IconButton(
                      icon: child,
                      iconSize: 30,
                      onPressed: () {
                        appState.nextItem();
                        resetPlayerAndBeginPlay();
                      },
                    );
                  },
                  child:
                      Image.asset("assets/images/cm2_vehicle_btn_next_prs.png"),
                ),
                Consumer<AppState>(
                  builder: (context, appState, child) {
                    return IconButton(
                      icon: child,
                      onPressed: () {
                        appState.isShowingList = true;
                      },
                      iconSize: 60,
                    );
                  },
                  child: Image.asset("assets/images/cm2_icn_list_prs.png"),
                )
              ],
            ),
          ],
        ));
  }

  Widget _buildMaskView() {
    return Consumer<AppState>(builder: (context, appState, child) {
      return IgnorePointer(
        ignoring: !appState.isShowingList, // 展示的时候就是false，不展示的时候就是true
        child: GestureDetector(
          onTap: () {
            appState.isShowingList = false;
          },
          child: AnimatedOpacity(
            opacity: appState.isShowingList ? 1 : 0, // 1 是能看见 0 看不见这个蒙层
            duration: Duration(milliseconds: 300),
            child: Container(
              color: Colors.black54,
            ),
          ),
        ),
      );
    });
  }

  Widget _buildList(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        return AnimatedPositioned(
          left: 20,
          bottom: appState.isShowingList ? 0 : -360,
          child: child,
          duration: Duration(milliseconds: 300),
          curve: Curves.fastOutSlowIn,
        );
      },
      child: MusicList(),
    );
  }

  // 重置播放
  void resetPlayerAndBeginPlay() {
    _discController.reset();
    _discController.forward();
  }
}
