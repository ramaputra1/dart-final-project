class CoinDetail {
  final String name;
  final String symbol;
  final int rank;
  final double price;
  final double change24h;
  final double marketCap;
  final double volume24h;
  final double ath;
  final double atl;
  final String description;
  final String website;

  CoinDetail({
    required this.name,
    required this.symbol,
    required this.rank,
    required this.price,
    required this.change24h,
    required this.marketCap,
    required this.volume24h,
    required this.ath,
    required this.atl,
    required this.description,
    required this.website,
  });

  factory CoinDetail.fromJson(Map<String, dynamic> json) {
    final market = json['market_data'] as Map<String, dynamic>;
    final links = json['links'] as Map<String, dynamic>;
    final homepages = links['homepage'] as List<dynamic>;

    return CoinDetail(
      name: json['name'] as String,
      symbol: json['symbol'] as String,
      rank: json['market_cap_rank'] as int,
      price: (market['current_price']['usd'] as num).toDouble(),
      change24h:
          (market['price_change_percentage_24h'] as num?)?.toDouble() ?? 0.0,
      marketCap: (market['market_cap']['usd'] as num).toDouble(),
      volume24h: (market['total_volume']['usd'] as num).toDouble(),
      ath: (market['ath']['usd'] as num).toDouble(),
      atl: (market['atl']['usd'] as num).toDouble(),
      description:
          (json['description'] as Map<String, dynamic>)['en'] as String,
      website: homepages.firstWhere((e) => e != '', orElse: () => '') as String,
    );
  }

  @override
  String toString() => 'CoinDetail(name: $name, symbol: $symbol, rank: $rank)';
}
