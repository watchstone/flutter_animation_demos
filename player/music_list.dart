import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app_state.dart';
import 'music_play_mode.dart';

class MusicList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    MediaQueryData queryData = MediaQuery.of(context);
    final double width = queryData.size.width;
    return Container(
      width: width - 40,
      height: 360,
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20), color: Colors.white),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: [
          _buildTitle(),
          _buildList(),
        ],
      ),
    );
  }

  Widget _buildTitle() {
    return Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(children: [
              TextSpan(
                text: "当前播放",
                style: TextStyle(fontSize: 26, color: Colors.black),
              ),
              TextSpan(
                text: "(9)",
                style: TextStyle(fontSize: 20, color: Colors.black45),
              ),
            ]),
          ),
          Consumer<AppState>(
            builder: (context, appState, child) {
              String iconName = "assets/images/cm2_play_btn_loop_prs.png";
              String modeName = "列表循环";
              if (appState.playMode == PlayerMode.one) {
                iconName = "assets/images/cm2_play_btn_one_prs.png";
                modeName = "单曲循环";
              } else if (appState.playMode == PlayerMode.shuffle) {
                iconName = "assets/images/cm2_play_btn_shuffle_prs.png";
                modeName = "随机播放";
              }
              return ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                      primary: Colors.transparent,
                      shadowColor: Colors.transparent,
                      padding: EdgeInsets.zero),
                  onPressed: () {
                    appState.changePlayMode();
                  },
                  icon: Image.asset(
                    iconName,
                    width: 20,
                    height: 20,
                  ),
                  label: Text(modeName,
                      style: TextStyle(color: Colors.black87, fontSize: 18)));
            },
          )
        ]);
  }

  Widget _buildList() {
    return Expanded(
      child: Consumer<AppState>(
        builder: (ctx, appState, child) {
          return ListView.builder(
            itemCount: appState.musicItems.length,
            itemBuilder: (context, index) {
              Color firstColor = Colors.black;
              Color secondColor = Colors.black45;
              if (appState.currentMusicItem == appState.musicItems[index]) {
                firstColor = Colors.red;
                secondColor = Colors.red[400];
              }
              return GestureDetector(
                onTap: () {
                  appState.setCurrentMusicItem(appState.musicItems[index], forcePlay: true);
                },
                child: Container(
                  height: 50,
                  alignment: Alignment.centerLeft,
                  child: RichText(
                      text: TextSpan(children: [
                    TextSpan(
                      text: appState.musicItems[index].name,
                      style: TextStyle(fontSize: 20, color: firstColor),
                    ),
                    TextSpan(
                      text: " - ${appState.musicItems[index].singer}",
                      style: TextStyle(fontSize: 20, color: secondColor),
                    ),
                  ])),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
