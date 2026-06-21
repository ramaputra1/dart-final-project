import 'dart:async';

import 'package:command_runner/command_runner.dart';

import '../api/coingecko_client.dart';
import '../service/crypto_service.dart';

class CoinIdCommand extends Command {
  @override
  String get name => 'coinId';

  @override
  String get description =>
      'Shows detail for a coin by its trending list number.';

  @override
  bool get requiresArgument => true;

  @override
  FutureOr<Object?> run(ArgResults args) async {
    final rawArg = args.commandArg;
    if (rawArg == null || rawArg.isEmpty) {
      return 'Usage: coinId <number>\nExample: coinId 1';
    }

    final number = int.tryParse(rawArg);
    if (number == null || number < 1) {
      return 'Please provide a valid positive number.\nUsage: coinId <number>';
    }

    final client = CoinGeckoClient();
    final service = CryptoService(client);

    final trending = await service.getTrendingCoins();
    if (number > trending.length) {
      return 'Only ${trending.length} coins in trending. Pick a number between 1 and ${trending.length}.';
    }

    final selected = trending[number - 1];
    final coin = await service.getCoinDetail(selected.id);

    final buffer = StringBuffer()
      ..writeln('Trending #$number → ${coin.name} (${coin.symbol.toUpperCase()})')
      ..writeln('=' * 40)
      ..writeln('Rank:          #${coin.rank}')
      ..writeln('Price:         \$${coin.price.toStringAsFixed(2)}')
      ..writeln('24h Change:    ${coin.change24h.toStringAsFixed(2)}%')
      ..writeln('Market Cap:    \$${_formatNumber(coin.marketCap)}')
      ..writeln('Volume 24h:    \$${_formatNumber(coin.volume24h)}')
      ..writeln('ATH:           \$${coin.ath.toStringAsFixed(2)}')
      ..writeln('ATL:           \$${coin.atl.toStringAsFixed(2)}')
      ..writeln('Website:       ${coin.website}')
      ..writeln()
      ..writeln(coin.description.isEmpty
          ? 'No description available.'
          : coin.description);

    return buffer.toString().trimRight();
  }

  String _formatNumber(double value) {
    if (value >= 1e12) return '${(value / 1e12).toStringAsFixed(2)}T';
    if (value >= 1e9) return '${(value / 1e9).toStringAsFixed(2)}B';
    if (value >= 1e6) return '${(value / 1e6).toStringAsFixed(2)}M';
    return value.toStringAsFixed(2);
  }
}
