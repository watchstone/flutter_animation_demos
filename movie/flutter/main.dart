
import 'package:flutter_movie_player/ui/pages/channel/channel_page.dart';
import 'package:flutter_movie_player/ui/pages/home/main_page.dart';
import 'package:flutter_movie_player/ui/pages/mine/mine_page.dart';
import 'package:flutter/material.dart';

@pragma('vm:entry-point')
void main() => runApp(MainApp());

@pragma('vm:entry-point')
void channel() => runApp(ChannelApp());

@pragma('vm:entry-point')
void mine() => runApp(MineApp());
