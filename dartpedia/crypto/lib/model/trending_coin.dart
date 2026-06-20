class TrendingCoin {
  final String id;
  final String name;
  final String symbol;

  TrendingCoin({
    required this.id,
    required this.name,
    required this.symbol,
  });

  factory TrendingCoin.fromJson(Map<String, dynamic> json) {
    final item = json['item'] as Map<String, dynamic>;
    return TrendingCoin(
      id: item['id'] as String,
      name: item['name'] as String,
      symbol: item['symbol'] as String,
    );
  }

  @override
  String toString() => 'TrendingCoin(id: $id, name: $name, symbol: $symbol)';
}
