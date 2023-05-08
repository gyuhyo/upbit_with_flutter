class Ticker{
  late String marketCode;
  late double? prevClosingPrice = 0;
  late double? tradePrice = 0;
  late double? changeRate = 0;
  late double? changePrice = 0;
  late double? changePrice24h = 0;

  Ticker({
    required this.marketCode,
    this.prevClosingPrice,
    this.tradePrice,
    this.changeRate,
    this.changePrice,
    this.changePrice24h
  });

  Ticker.fromJson(Map<String, dynamic> json) {
    marketCode = json['market'];
  }
}