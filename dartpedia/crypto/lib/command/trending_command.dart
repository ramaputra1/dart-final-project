import 'dart:async';

import 'package:command_runner/command_runner.dart';

import '../api/coingecko_client.dart';
import '../service/crypto_service.dart';

class TrendingCommand extends Command {
  @override
  String get name => 'trending';

  @override
  String get description => 'Shows the current trending coins on CoinGecko.';

  @override
  FutureOr<Object?> run(ArgResults args) async {
    final service = CryptoService(CoinGeckoClient());
    final coins = await service.getTrendingCoins();

    final buffer = StringBuffer()
      ..writeln('Trending Coins')
      ..writeln('--------------');

    for (var i = 0; i < coins.length; i++) {
      buffer.writeln('${i + 1}. ${coins[i].name}');
    }

    return buffer.toString().trimRight();
  }
}
