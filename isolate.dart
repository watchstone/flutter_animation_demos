import 'dart:isolate';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {
  AnimationController _controller;
  Animation _animation;
  Animation _sizeAnim;

  Isolate isolate;
  ReceivePort mainIsolaiteReceivePort;
  SendPort otherIsolateSendPort;

  @override
  void initState() {
    super.initState();
    // 1.创建AnimationController
    _controller =
        AnimationController(vsync: this, duration: Duration(seconds: 2));
    // 2.设置Curve的值
    _animation = CurvedAnimation(
        parent: _controller, curve: Curves.linear, reverseCurve: Curves.linear);
    _sizeAnim = Tween(begin: 100.0, end: 200.0).animate(_animation);

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _controller.reverse();
      } else if (status == AnimationStatus.dismissed) {
        _controller.forward();
      }
    });

    _controller.forward();
  }

  // 新建(复用)Isolate
  void spawnNewIsolate() async {
    if (mainIsolaiteReceivePort == null) {
      mainIsolaiteReceivePort = ReceivePort();
    }
    try {
      if (isolate == null) {
        isolate = await Isolate.spawn(
            calculatorByIsolate, mainIsolaiteReceivePort.sendPort);
        mainIsolaiteReceivePort.listen((dynamic message) {
          if (message is SendPort) {
            otherIsolateSendPort = message;
            otherIsolateSendPort.send(1);
            print("双向通讯建立成功，主isolate传递初始参数1");
          } else {
            print("新建的isolate计算得到的结果$message");
          }
        });
      } else {
        if (otherIsolateSendPort != null) {
          otherIsolateSendPort.send(1);
          print("双向通讯复用，主isolate传递初始参数1");
        }
      }
    } catch (e) {}
  }

  static void calculatorByIsolate(SendPort sendPort) {
    ReceivePort receivePort = new ReceivePort();
    sendPort.send(receivePort.sendPort);

    receivePort.listen((val) {
      print("从主isolate传递过来的初始参数是$val");
      int total = val;
      for (var i = 0; i < 1000000000; i++) {
        total += i;
      }
      sendPort.send(total);
    });
  }

  static Future<int> bigCompute(int initalNumber) async {
    int total = initalNumber;
    for (var i = 0; i < 1000000000; i++) {
      total += i;
    }
    return total;
  }

  void calculator() async {
    int result = await bigCompute(0);
    print(result);
  }

  void calculatorByComputeFunction() async {
    int result = await compute(bigCompute, 0);
    print(result);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            AnimatedBuilder(
              animation: _sizeAnim,
              builder: (context, child) {
                return Icon(
                  Icons.favorite,
                  color: Colors.red,
                  size: _sizeAnim.value,
                );
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: spawnNewIsolate,
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    mainIsolaiteReceivePort.close();
    isolate.kill();
    super.dispose();
  }
}
