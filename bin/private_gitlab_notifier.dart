import 'package:private_gitlab_notifier/common/cli_util.dart';
import 'package:private_gitlab_notifier/common/exit_code.dart';
import 'package:private_gitlab_notifier/dashboard_service.dart';
import 'package:private_gitlab_notifier/merge_request_watcher.dart';
import 'package:private_gitlab_notifier/model/mixed_changes.dart';
import 'package:private_gitlab_notifier/model/mr_comment.dart';
import 'package:private_gitlab_notifier/model/multi_mr.dart';
import 'package:private_gitlab_notifier/model/multi_comment.dart';
import 'package:private_gitlab_notifier/model/response_type.dart';
import 'package:private_gitlab_notifier/repository.dart';
import 'package:private_gitlab_notifier/secret.dart';
import 'package:private_gitlab_notifier/web_socket_server.dart';
import 'package:http/http.dart' as http;

void main(List<String> arguments) async {
  final env = SettingsEnv.init();
  late final String accessToken;
  late final String gitlabDomain;
  late final int fetchIntervalInMilliSecond;
  late final int projectId;
  try {
    gitlabDomain = env.domain;
    accessToken = env.accessToken;
    projectId = env.projectId;
    fetchIntervalInMilliSecond = env.fetchIntervalInMilliSecond;
  } on SettingValueExcception catch (e) {
    exitWith(
      ExitReason.settingValueError,
      message: e.message,
    );
  }
  final client = http.Client();
  final repo = Repository(
    client: client,
    token: accessToken,
    projectId: projectId,
    domain: gitlabDomain,
  );
  final glNotifier = await MergeRequestWatcher.create(
    repo,
    client,
  );

  late final DashboardService dashboardService;
  try {
    dashboardService = await DashboardService.start();
  } on DashboardServiceException catch (e) {
    exitWith(
      ExitReason.dashboardNotStarted,
      message: e.message,
    );
  }
  final wsServer = await WebSocketServer.start();

  do {
    if (WebSocketServer.clients.isEmpty) {
      print('No client connected');
      await Future.delayed(Duration(milliseconds: fetchIntervalInMilliSecond));
      continue;
    }

    final changes = await glNotifier.watchChanges();

    final responseType = ResponseType.fromChanges(changes);
    final mrChanges = changes.mrChanges;
    final commentChanges = changes.commentChanges;

    switch (responseType) {
      case ResponseType.nothingToNotify:
        print('Nothing to notify');
        break;
      case ResponseType.mergeRequest:
        wsServer.boardcastMR(mrChanges.first);
        print('1 MR found');
        break;
      case ResponseType.multipleMergeRequests:
        wsServer.boardcastMRs(MultiMR.fromChanges(mrChanges));
        print('${mrChanges.length} MRs found');
        break;
      case ResponseType.comment:
        wsServer.boardcastComment(MRComment.fromChanges(commentChanges));
        print('1 comment found');
        break;
      case ResponseType.multipleComments:
        wsServer.boardcastComments(MultiComment.fromChanges(commentChanges));
        print('${commentChanges.entries.first.value.length} comments found');
        break;
      case ResponseType.mixed:
        wsServer.boardcastMixed(MixedChanges.fromChanges(changes));
        print(
          '${mrChanges.length} MRs and ${commentChanges.entries.first.value.length} comments found',
        );
        break;
    }
    await Future.delayed(Duration(milliseconds: fetchIntervalInMilliSecond));
  } while (dashboardService.isRunning());

  exitWith(ExitReason.success);
}
