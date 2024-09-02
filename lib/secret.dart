import 'dart:io';

import 'package:private_gitlab_notifier/common/cli_util.dart';
import 'package:path/path.dart' as p;

class SettingsEnv {
  static const _defaultFetchIntervalInMilliSecond = 5000;
  final File _envFile;

  const SettingsEnv._(this._envFile);

  factory SettingsEnv.init() {
    final envPath = p.join(scriptDirPath, '.env');
    final env = File(envPath);

    return SettingsEnv._(env);
  }

  String get domain {
    return _getSetting<String>(
      'domain',
      parser: (value) => value,
    );
  }

  String get accessToken {
    return _getSetting<String>(
      'access_token',
      parser: (value) => value,
    );
  }

  int get fetchIntervalInMilliSecond {
    return _getSetting<int>(
      'fetch_interval',
      parser: (value) => int.parse(value),
      defaultValue: _defaultFetchIntervalInMilliSecond,
    );
  }

  int get projectId {
    return _getSetting<int>(
      'project_id',
      parser: (value) => int.parse(value),
    );
  }

  T _getSetting<T>(
    String targetKey, {
    required T Function(String rawValue) parser,
    T? defaultValue,
  }) {
    final hasDefaultValue = defaultValue != null;
    late final List<String> contents;
    try {
      contents = _envFile.readAsLinesSync();
    } on FileSystemException catch (e) {
      throw SettingValueExcception.envError(e.message);
    }

    for (final content in contents) {
      final key = content.split('=').first;
      final value = content.split('=').last;
      final isTargetKey = key == targetKey;
      final reachedEnd = contents.last == content;

      if (!isTargetKey) {
        if (reachedEnd) {
          throw SettingValueExcception('$targetKey not found');
        }
        continue;
      }
      late final T setting;
      try {
        setting = parser(value);
      } on FormatException {
        if (!hasDefaultValue) {
          throw SettingValueExcception('Invalid $targetKey');
        }
        print('Invalid $targetKey, using default value');
        return defaultValue;
      }
      return setting;
    }

    if (!hasDefaultValue) {
      throw SettingValueExcception('Invalid $targetKey');
    }
    print('Invalid $targetKey, using default value');
    return defaultValue;
  }
}

class SettingValueExcception implements Exception {
  final String message;

  const SettingValueExcception(this.message);

  factory SettingValueExcception.envError(String message) {
    return SettingValueExcception(".env file error: $message");
  }

  @override
  String toString() {
    return message;
  }
}
