import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:upbit_auto_trading/controller/common/common_controller.dart';
import 'package:upbit_auto_trading/model/common/ticker.dart';
import 'package:upbit_auto_trading/screen/dashboard/trade_view_screen.dart';

import '../../model/common/market.dart';

class MarketDataTable extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width - 16;

    final List<DataColumn> _dataTableColumns = [
      DataColumn(
        label: Container(
          alignment: Alignment.centerLeft,
          width: width * .3,
          child: Text('코인명'),
        ),
      ),
      DataColumn(
        label: Container(
          alignment: Alignment.centerRight,
          width: width * .3,
          child: Text('현재가'),
        ),
      ),
      DataColumn(
        label: Container(
          alignment: Alignment.centerRight,
          width: width * .2,
          child: Text('등락률'),
        ),
      ),
      DataColumn(
        label: Container(
          alignment: Alignment.centerRight,
          width: width * .2,
          child: Text('거래대금'),
        ),
      ),
    ];

    return SizedBox(
      width: width,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Obx(
          () => DataTable(
            showCheckboxColumn: false,
            sortColumnIndex: 2,
            sortAscending: true,
            dataRowMaxHeight: 60,
            columnSpacing: 0,
            horizontalMargin: 0,
            columns: _dataTableColumns,
            rows: CommonController.to.markets
                .map(
                  (d) => _dataTableRows(
                    d.marketCode,
                    d.marketKorean,
                    CommonController.to.markets.firstWhere(
                        (element) => element.marketCode == d.marketCode),
                  ),
                )
                .toList(),
          ),
        ),
      ),
    );
  }

  DataRow _dataTableRows(String marketCode, String marketKorean, Market t) {
    TextStyle customPriceColorStyle(double vol) {
      if (vol > 0) {
        return TextStyle(color: Colors.red);
      }

      if (vol < 0) {
        return TextStyle(color: Colors.blue);
      }
      return TextStyle(color: Colors.black);
    }

    DataCell marketColumn = DataCell(
      Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Hero(
            tag: 'test${marketKorean}',
            key: ObjectKey(marketKorean),
            child: Material(
              type: MaterialType.transparency,
              child: Text(
                marketKorean,
                style: TextStyle(fontSize: 15.0),
              ),
            ),
          ),
          Text(
            marketCode,
            style: TextStyle(fontSize: 11.0),
          )
        ],
      ),
    );

    DataCell tradePriceColumn = DataCell(
      Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            NumberFormat("###,###.#####", "ko_KR")
                .format(t.tradePrice)
                .toString(),
            style: customPriceColorStyle(t.changeRate!),
          ),
        ],
      ),
    );

    DataCell volumeColumn = DataCell(
      Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${NumberFormat.compact(
                  locale: 'ko',
                  explicitSign: true,
                ).format(t.changeRate).toString()}%',
                style: customPriceColorStyle(t.changeRate!),
              ),
              Text(
                NumberFormat("###,###.#####", "ko_KR")
                    .format(t.changePrice)
                    .toString(),
                style: customPriceColorStyle(t.changeRate!),
              ),
            ],
          ),
        ],
      ),
    );

    DataCell accTradeColumn = DataCell(
      Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            NumberFormat.compactLong(locale: 'ko', explicitSign: false)
                .format(t.changePrice24h),
          ),
        ],
      ),
    );

    return DataRow(
        cells: [marketColumn, tradePriceColumn, volumeColumn, accTradeColumn],
        onSelectChanged: (selected) {
          Get.to(
              TradeViewScreen(
                marketCode: marketCode,
                marketKorean: marketKorean,
              ),
              transition: Transition.rightToLeftWithFade);
        });
  }
}
