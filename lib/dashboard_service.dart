import 'dart:io';

import 'package:private_gitlab_notifier/common/cli_util.dart';
import 'package:path/path.dart' as p;

class DashboardService {
  final Process _process;
  bool _isRunning = true;

  DashboardService._(this._process);

  int get _pid => _process.pid;

  static Future<DashboardService> start() async {
    final dashboardPort = await _findAvailablePort();
    final dashboardPath = p.join(scriptDirPath, 'web');

    final process = await Process.start(
      'dhttpd',
      [
        '--port',
        dashboardPort.toString(),
        '--path',
        dashboardPath,
      ],
      runInShell: true,
    );

    final isServiceRunning = checkPid(process.pid, 'Dashboard');

    if (!isServiceRunning) {
      throw DashboardServiceException('Failed to start dashboard');
    }

    print('Dashboard is running at http://localhost:$dashboardPort');
    return DashboardService._(process);
  }

  static Future<int> _findAvailablePort() async {
    final server = await HttpServer.bind('localhost', 0);
    final port = server.port;
    server.close();
    return port;
  }

  bool isRunning() {
    return checkPid(_pid, 'Dashboard');
  }

  void stop() {
    if (!_isRunning) return;

    _process.kill();
    _isRunning = false;
  }
}

class DashboardServiceException implements Exception {
  final String message;

  DashboardServiceException(this.message);

  @override
  String toString() => message;
}
