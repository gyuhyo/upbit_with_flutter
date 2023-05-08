import 'dart:convert';

import 'package:bottom_bar_page_transition/bottom_bar_page_transition.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:upbit_auto_trading/constant/color.dart';
import 'package:upbit_auto_trading/controller/common/common_controller.dart';
import 'package:upbit_auto_trading/model/common/market.dart';
import 'package:upbit_auto_trading/model/common/ticker.dart';
import 'package:upbit_auto_trading/screen/dashboard/dashboard_screen.dart';
import 'package:http/http.dart' as http;
import 'package:upbit_auto_trading/screen/users/api_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Upbit Auto Trading',
      theme: ThemeData(primaryColor: Colors.green[300], fontFamily: 'Arial'),
      home: _LoadingScreen(),
    );
  }
}

class _LoadingScreen extends StatelessWidget {
  const _LoadingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<CommonController>()) {
      Get.put(CommonController());

      void onLoadMarkets() async {
        final url =
            Uri.parse('https://api.upbit.com/v1/market/all?isDetails=true');
        final response = await http.get(url);

        final decodeJson = json.decode(response.body);

        List<Market> loadMarket =
            List<Market>.from(decodeJson.map((data) => Market.fromJson(data)))
                .where((x) => x.marketCode.contains('KRW'))
                .toList();

        List<Ticker> loadTicker =
            List<Ticker>.from(decodeJson.map((data) => Ticker.fromJson(data)))
                .where((x) => x.marketCode.contains('KRW'))
                .toList();

        CommonController.to.onAddMarket(loadMarket);
        CommonController.to.onWsConnect();

        Get.off(() => _RootScreen());
      }

      onLoadMarkets();
    }

    return Scaffold(
      backgroundColor: PRIMARY_COLOR,
      body: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                '세탁소 자동매매',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 27.0,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 16.0),
              CircularProgressIndicator(color: Colors.grey),
            ],
          ),
        ],
      ),
    );
  }
}

class _RootScreen extends StatefulWidget {
  const _RootScreen({Key? key}) : super(key: key);

  @override
  State<_RootScreen> createState() => _RootScreenState();
}

class _RootScreenState extends State<_RootScreen> {
  int currentTappedMenu = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: _CustomAppBar(),
        body: _Content(currentTappedMenu: currentTappedMenu),
        bottomNavigationBar: _BottomNavigation(
          onTab: onMenuTapped,
          currentTappedMenu: currentTappedMenu,
        ));
  }

  void onMenuTapped(int value) {
    setState(() {
      this.currentTappedMenu = value;
    });
  }

  AppBar _CustomAppBar() {
    return AppBar(
      systemOverlayStyle: SystemUiOverlayStyle(statusBarColor: PRIMARY_COLOR),
      title: Text('세탁소 자동매매'),
      backgroundColor: PRIMARY_COLOR,
      elevation: 0,
      centerTitle: true,
      actions: [
        IconButton(
          onPressed: () {
            Get.to(
              ApiScreen(),
              transition: Transition.downToUp,
            );
          },
          icon: Icon(Icons.account_circle),
        ),
      ],
    );
  }
}

class _Content extends StatelessWidget {
  final int currentTappedMenu;
  const _Content({
    required this.currentTappedMenu,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<Widget> _widgets = [
      DashboardScreen(),
      Text('TEST 2'),
      Text('TEST 3'),
      Text('TEST 3'),
    ];

    return AnimatedSwitcher(
      duration: Duration(milliseconds: 500),
      transitionBuilder: (child, animation) => ScaleTransition(
        scale: animation,
        child: child,
      ),
      child: IndexedStack(
        index: currentTappedMenu,
        children: _widgets,
      ),
    );

    // return BottomBarPageTransition(
    //   builder: (_, index) => _widgets[index],
    //   currentIndex: currentTappedMenu,
    //   totalLength: 4,
    //   transitionDuration: Duration(milliseconds: 100),
    //   transitionCurve: Curves.fastOutSlowIn,
    //   transitionType: TransitionType.slide,
    // );
  }
}

class _BottomNavigation extends StatelessWidget {
  final ValueChanged<int> onTab;
  final int currentTappedMenu;
  const _BottomNavigation({
    required this.onTab,
    required this.currentTappedMenu,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentTappedMenu,
      onTap: onTab,
      items: [
        BottomNavigationBarItem(icon: Icon(Icons.view_list), label: '대시보드'),
        BottomNavigationBarItem(icon: Icon(Icons.swap_horiz), label: '자동매매'),
        BottomNavigationBarItem(icon: Icon(Icons.wallet), label: '내 잔고'),
        BottomNavigationBarItem(icon: Icon(Icons.settings), label: '설정'),
      ],
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Colors.white,
      unselectedItemColor: UNSELECT_COLOR,
      showUnselectedLabels: true,
      showSelectedLabels: true,
      elevation: 8.0,
      backgroundColor: PRIMARY_COLOR,
    );
  }
}
