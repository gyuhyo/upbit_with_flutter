import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart' as intl;
import 'package:upbit_auto_trading/component/dashboard/market_datatable.dart';
import 'package:upbit_auto_trading/constant/color.dart';
import 'package:upbit_auto_trading/controller/common/common_controller.dart';
import 'package:upbit_auto_trading/model/common/market.dart';
import 'package:upbit_auto_trading/screen/dashboard/trade_view_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool descending = true;
  String _searchCoin = '';
  Timer? _debounce;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _SearchField(onSearchCoinChanged: (val) => onSearchCoinChanged(val)),
        _DashboardTopHeader(
          descending: descending,
          onSortedBtnClick: onSortedBtnClick,
        ),
        _CoinListWidget(
          descending: descending,
          searchCoin: _searchCoin,
        ),
      ],
    );
  }

  void onSortedBtnClick() {
    setState(() {
      descending = !descending;
    });
  }

  void onSearchCoinChanged(String val) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 100), () {
      setState(() {
        _searchCoin = val;
      });
    });
  }
}

class _SearchField extends StatelessWidget {
  final ValueChanged onSearchCoinChanged;

  const _SearchField({
    required this.onSearchCoinChanged,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 36,
      color: PRIMARY_COLOR,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: TextField(
          decoration: InputDecoration(
            hintText: '코인명 검색',
            hintStyle: TextStyle(color: UNSELECT_COLOR),
            suffixStyle: TextStyle(
              color: Colors.white,
            ),
            border: InputBorder.none,
          ),
          style: TextStyle(color: Colors.white),
          cursorColor: Colors.white,
          onChanged: (val) => onSearchCoinChanged(val),
        ),
      ),
    );
  }
}

class _DashboardTopHeader extends StatelessWidget {
  final bool descending;
  final VoidCallback onSortedBtnClick;

  const _DashboardTopHeader({
    required this.descending,
    required this.onSortedBtnClick,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: PRIMARY_COLOR,
        border: Border(
          top: BorderSide(
            width: 1,
            color: Colors.white.withOpacity(0.1),
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.only(left: 16.0, right: 8.0),
        child: Row(
          children: [
            Text(
              '코인명',
              style: TextStyle(color: Colors.white),
            ),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    '현재가',
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
            SizedBox(width: 8),
            SizedBox(
                width: 80,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Directionality(
                      textDirection: TextDirection.rtl,
                      child: TextButton.icon(
                        onPressed: onSortedBtnClick,
                        label: Text(
                          '등락률',
                          style: TextStyle(color: Colors.white),
                        ),
                        icon: descending
                            ? Icon(Icons.keyboard_arrow_down, size: 16)
                            : Icon(Icons.keyboard_arrow_up, size: 16),
                      ),
                    ),
                  ],
                ))
          ],
        ),
      ),
    );
  }
}

class _CoinListWidget extends StatelessWidget {
  final bool descending;
  final String searchCoin;

  const _CoinListWidget({
    required this.descending,
    required this.searchCoin,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        color: Colors.white,
        child: StreamBuilder(
          stream: CommonController.to.markets.stream,
          builder: (ctx, snapshot) {
            if (!snapshot.hasData) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }

            List<Market> data = snapshot.data!;

            if (searchCoin != '')
              data = data
                  .where((e) => e.marketKorean.contains(searchCoin))
                  .toList();

            if (DateTime.now().second % 5 == 0) {
              data.sort((a, b) {
                int compare = b.changeRate!.compareTo(a.changeRate!);

                if (compare == 0) {
                  return compare = b.tradePrice!.compareTo(a.tradePrice!);
                }

                return compare;
              });
            }

            if (!descending) data = data!.reversed.toList();

            return ListView.separated(
              shrinkWrap: true,
              itemCount: data.length,
              itemBuilder: (context, index) {
                var _thisMarket = data[index];
                var _logoUrl =
                    'https://static.upbit.com/logos/${_thisMarket.marketCode.replaceAll('KRW-', '')}.png';

                return GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    print('------------------ RESULT -------------------');
                    if (FocusManager.instance.primaryFocus != null &&
                        !FocusManager.instance.primaryFocus!.children.isNotEmpty) {
                      FocusManager.instance.primaryFocus!.unfocus();
                    } else {
                      Get.to(
                        TradeViewScreen(
                          marketCode: _thisMarket.marketCode,
                          marketKorean: _thisMarket.marketKorean,
                        ),
                        transition: Transition.rightToLeftWithFade,
                      );
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Row(
                      children: [
                        Image.network(_logoUrl, width: 24, height: 24),
                        SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _thisMarket.marketKorean,
                              style: TextStyle(
                                color: _thisMarket.marketWarning == "CAUTION"
                                    ? Colors.deepOrange
                                    : Colors.black,
                              ),
                            ),
                            Text(_thisMarket.marketCode,
                                style: TextStyle(
                                  fontSize: 11.0,
                                  color: _thisMarket.marketWarning == "CAUTION"
                                      ? Colors.deepOrange
                                      : Colors.black,
                                )),
                          ],
                        ),
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    intl.NumberFormat("###,###.#####", "ko_KR")
                                        .format(_thisMarket.tradePrice)
                                        .toString(),
                                  ),
                                  Text(
                                    '${intl.NumberFormat("###,###", "ko_KR").format(_thisMarket.changePrice24h! / 1000000)}백만',
                                    style: TextStyle(fontSize: 11.0),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: 100,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Card(
                              elevation: 3,
                              color: _thisMarket.changeRate! > 0
                                  ? UP_COLOR
                                  : _thisMarket.changeRate! == 0
                                      ? BOHAP_COLOR
                                      : DOWN_COLOR,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      '${_thisMarket.changeRate! >= 0 ? '+' : ''}${intl.NumberFormat("###,##0.00", "ko_KR").format(_thisMarket.changeRate).toString()}%',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                );
              },
              separatorBuilder: (ctx, index) => Divider(
                height: 0,
                color: Colors.grey[300],
              ),
            );
          },
        ),
      ),
    );
  }
}
