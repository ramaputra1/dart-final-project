import '../api/coingecko_client.dart';
import '../model/trending_coin.dart';

class CryptoService {
  final CoinGeckoClient _client;

  CryptoService(this._client);

  Future<List<TrendingCoin>> getTrendingCoins() async {
    final data = await _client.getTrendingData();
    final coins = data['coins'] as List<dynamic>;
    return coins
        .map((c) => TrendingCoin.fromJson(c as Map<String, dynamic>))
        .toList();
  }
}
