import 'dart:io';

import 'package:private_gitlab_notifier/common/exit_code.dart';
import 'package:path/path.dart' as p;

enum SupportedPlatform {
  windows,
  macos;
}

SupportedPlatform get currentPlatform {
  if (Platform.isWindows) return SupportedPlatform.windows;
  if (Platform.isMacOS) return SupportedPlatform.macos;

  exitWith(ExitReason.unsupportedPlatform);
  throw UnsupportedError('This platform is not supported');
}

String get scriptDirPath {
  late final String path;

  switch (currentPlatform) {
    case SupportedPlatform.windows:
      path = p.windows.dirname(Platform.script.toFilePath());
    case SupportedPlatform.macos:
      path = p.dirname(Platform.script.toFilePath());
  }
  return path;
}

void exitWith(ExitReason exitCode, {String? message}) {
  print('');
  print('Program exited! reason: ${exitCode.reason}');
  if (message != null) print(message);
  print('Press Enter to exit');
  stdin.readLineSync();
  exit(exitCode.code);
}

bool checkPid(int pid, String instanceName) {
  late final bool isRunning;

  switch (currentPlatform) {
    case SupportedPlatform.windows:
      final cmdCommand =
          'tasklist /nh /fo CSV | findstr /I "$pid" > nul && echo 1 || echo 0';
      final result =
          Process.runSync('cmd', ['/c', cmdCommand], runInShell: true);
      isRunning = int.parse(result.stdout.trim()) == 1;
    case SupportedPlatform.macos:
      final result = Process.runSync('kill', ['-0', '$pid']);
      isRunning = result.exitCode == 0;
  }

  if (!isRunning) {
    print('($instanceName) Process with pid $pid is not running');
    return false;
  }
  return true;
}
