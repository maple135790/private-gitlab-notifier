import 'dart:io';

import 'package:private_gitlab_notifier/common/exit_code.dart';

void exitWith(ExitReason exitCode) {
  print('');
  print('Program exited! reason: ${exitCode.reason}');
  print('Press Enter to exit');
  stdin.readLineSync();
  exit(exitCode.code);
}

bool checkPid(int pid, String instanceName) {
  if (!Platform.isMacOS && !Platform.isWindows) {
    exitWith(ExitReason.unsupportedPlatform);
  }
  late final bool isRunning;
  if (Platform.isMacOS) {
    final result = Process.runSync('kill', ['-0', '$pid']);
    isRunning = result.exitCode == 0;
  }
  if (Platform.isWindows) {
    final cmdCommand =
        'tasklist /nh /fo CSV | findstr /I "$pid" > nul && echo 1 || echo 0';
    final result = Process.runSync('cmd', ['/c', cmdCommand], runInShell: true);
    isRunning = int.parse(result.stdout.trim()) == 1;
  }

  if (!isRunning) {
    print('($instanceName) Process with pid $pid is not running');
    return false;
  }
  return true;
}
