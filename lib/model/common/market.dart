class Market {
  late String marketCode;
  late String marketKorean;
  late String marketWarning;
  late double? prevClosingPrice = 0;
  late double? tradePrice = 0;
  late double? changeRate = 0;
  late double? changePrice = 0;
  late double? changePrice24h = 0;

  Market({
    required this.marketCode,
    required this.marketKorean,
    required this.marketWarning,
    this.prevClosingPrice,
    this.tradePrice,
    this.changeRate,
    this.changePrice,
    this.changePrice24h
  });

  Market.fromJson(Map<String, dynamic> json) {
    marketCode = json['market'];
    marketKorean = json['korean_name'];
    marketWarning = json['market_warning'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();

    data['marketCode'] = this.marketCode;
    data['marketKorean'] = this.marketKorean;
    data['marketWarning'] = this.marketWarning;

    return data;
  }
}
