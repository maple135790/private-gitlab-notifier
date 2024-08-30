enum ExitReason {
  success(0, 'success'),
  unsupportedPlatform(-1, 'This program only works on MacOS and Windows'),
  settingValueError(-2, 'Setting value error'),
  dashboardNotStarted(-3, 'Failed to start dashboard');

  final int code;
  final String reason;
  const ExitReason(this.code, this.reason);
}
