import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:get/get.dart';
import 'package:upbit_auto_trading/model/common/market.dart';
import 'package:upbit_auto_trading/model/common/ticker.dart';
import 'package:web_socket_channel/io.dart';

class CommonController extends GetxController {
  StreamController<String> streamController = new StreamController.broadcast(sync: true);

  IOWebSocketChannel ws =
      IOWebSocketChannel.connect('wss://api.upbit.com/websocket/v1');
  static CommonController get to => Get.find<CommonController>();
  List<Map<String, dynamic>> tempStorage = [];

  RxList<Market> _markets = <Market>[].obs;
  RxList<Market> get markets => _markets;

  @override
  void onInit() async {
    interval(
      markets,
      (_) {
        onWsEmit();
        _markets.refresh();
      },
      time: Duration(milliseconds: 300),
    );

    super.onInit();
  }

  @override
  void dispose() {
    ws.sink.close();

    super.dispose();
  }

  Future<bool> onAddMarket(
      List<Market> loadMarket) async {
    _markets.addAll(loadMarket);
    _markets.refresh();

    return await true;
  }

  void onWsConnect() {
    String codes = markets.map((x) => '"${x.marketCode}"').toList().toString();
    ws.sink.add(
        '[{"ticket":"asdasdasdasdasd"},{"type":"ticker","codes":${codes}}]');
    //ws.sink.add("[{'ticket': 'zxcasdqwecvbsdf', 'type': 'ticker', 'codes': ['KRW-BTC']}]");

    ws.stream.listen(
      (message) {
        if (message != null) {
          var s = String.fromCharCodes(message);
          Map<String, dynamic> data = json.decode(s);
          if (data['type'] == 'ticker') {
            int key = tempStorage
                .indexWhere((element) => element.containsValue(data['code']));
            if (key < 0) {
              tempStorage.add(<String, dynamic>{'key': data['code'], 'val': data});
            } else {
              tempStorage[key]['key'] = data['code'];
              tempStorage[key]['val'] = data;
            }
          }
        }
      },
    );
  }

  void onWsEmit() {
    for (Map<String, dynamic> tmp in tempStorage){
      var m = markets.firstWhere((element) => element.marketCode == tmp['key']);
      var val = tmp['val'];

      m.tradePrice = val['trade_price'];
      m.prevClosingPrice = val['prev_closing_price'];
      m.changePrice = val['signed_change_price'];
      m.changeRate = (double.parse(val['signed_change_rate'].toString()) * 100)
          .toPrecision(2);
      m.changePrice24h = val['acc_trade_price_24h'];
    }
    tempStorage.clear();
  }
}
