import 'package:command_runner/command_runner.dart';
import 'package:crypto_pkg/crypto.dart';

const version = '0.0.1';

void main(List<String> arguments) {
  var commandRunner = CommandRunner(
    onError: (Object error) {
      if (error is Error) {
        throw error;
      }
      if (error is Exception) {
        print(error);
      }
    },
  )
    ..addCommand(HelpCommand())
    ..addCommand(TrendingCommand());
  commandRunner.run(arguments);
}
