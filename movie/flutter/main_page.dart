
class MainApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // 初始化响应式
    FBResponsiveUtil.initialize();

    return MaterialApp(
      title: "FBMovie首页模块",
      theme: FBTheme.normalTheme,
      routes: FBRouter.routes,
      initialRoute: FBRouter.homePageInitialRoute,
      navigatorObservers: [routeObserver],
      onGenerateRoute: FBRouter.generateRoute,
      debugShowCheckedModeBanner: false,
    );
  }
}

class FBMainPage extends StatefulWidget {

  @override
  _FBMainPageState createState() => _FBMainPageState();
}

class _FBMainPageState extends State<FBMainPage> with RouteAware {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(),
      body: FBHomePage(),
    );
  }

  AppBar buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      brightness: Brightness.light,
      leadingWidth: 154.rpx,
      shadowColor: Colors.transparent,
      leading: null,
      actions: buildActions(),
      title: null,
    );
  }

  List<Widget> buildActions() {
    return [
      GestureDetector(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 36.rpx),
          child: Icon(
            Icons.search,
            color: FBTheme.redColor,
            size: 46.rpx,
          ),
        ),
        onTap: searchTapped,
      )
    ];
  }

  void searchTapped() {
    Navigator.of(context).pushNamed(FBSearchPage.routerName);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context));
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  void didPopNext() {
    // 返回到当前页面
    TabBarController.showTab();
  }

  void didPushNext() {
    // 跳转到下一个页面
    TabBarController.hideTab();
  }
  
}
