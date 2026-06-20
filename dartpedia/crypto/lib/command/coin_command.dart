import 'dart:async';

import 'package:command_runner/command_runner.dart';

import '../api/coingecko_client.dart';
import '../service/crypto_service.dart';

class CoinCommand extends Command {
  @override
  String get name => 'coin';

  @override
  String get description => 'Shows detailed information for a specific coin.';

  @override
  bool get requiresArgument => true;

  @override
  FutureOr<Object?> run(ArgResults args) async {
    final coinId = args.commandArg;
    if (coinId == null || coinId.isEmpty) {
      return 'Usage: coin <coin-id>\nExample: coin bitcoin';
    }

    final service = CryptoService(CoinGeckoClient());
    final coin = await service.getCoinDetail(coinId);

    final buffer = StringBuffer()
      ..writeln('${coin.name} (${coin.symbol.toUpperCase()})')
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
