import 'dart:convert';
import 'package:http/http.dart' as http;

class CoinGeckoClient {
  static const _baseUrl = 'https://api.coingecko.com/api/v3';

  Future<Map<String, dynamic>> getTrendingData() async {
    final url = Uri.parse('$_baseUrl/search/trending');
    final response = await http.get(url);

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to fetch trending data: ${response.statusCode}',
      );
    }

    return jsonDecode(response.body) as Map<String, dynamic>;
  }
}
