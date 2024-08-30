import 'dart:io';

class DashboardService {
  final Process _process;
  bool _isRunning = true;

  DashboardService._(this._process);

  int get _pid => _process.pid;

  static Future<DashboardService> start() async {
    final dashboardPort = await _findAvailablePort();

    final process = await Process.start(
      'dhttpd',
      [
        '--port',
        dashboardPort.toString(),
        '--path',
        'web',
      ],
      runInShell: true,
    );
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
    if (Platform.isMacOS) {
      final result = Process.runSync('kill', ['-0', '$_pid']);
      return result.exitCode == 0;
    } else if (Platform.isWindows) {
      final result =
          Process.runSync('tasklist', ['/nh', '/fi', 'PID eq $_pid']);
      return result.stdout.toString().contains(_pid.toString());
    }
    throw UnsupportedError('Unsupported platform');
  }

  void stop() {
    if (!_isRunning) return;

    _process.kill();
    _isRunning = false;
  }
}
