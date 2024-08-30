import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:private_gitlab_notifier/model/merge_request.dart';
import 'package:private_gitlab_notifier/model/mixed_changes.dart';
import 'package:private_gitlab_notifier/model/mr_comment.dart';
import 'package:private_gitlab_notifier/model/multi_mr.dart';
import 'package:private_gitlab_notifier/model/multi_comment.dart';
import 'package:private_gitlab_notifier/model/response_type.dart';
import 'package:private_gitlab_notifier/model/server_response.dart';
import 'package:shelf_web_socket/shelf_web_socket.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;

typedef ClientInfo = ({String id, WebSocketChannel channel});

class WebSocketServer {
  final HttpServer server;

  WebSocketServer._(this.server);

  HttpConnectionsInfo get connectionInfo => server.connectionsInfo();

  static List<ClientInfo> clients = [];

  static void _handleInitialMessage(
    String message,
    WebSocketChannel channel,
  ) {
    final clientId = message.split("#").last;
    clients.add((id: clientId, channel: channel));
    print('client connected: $clientId');
  }

  static void _handleDisconnection(
    String message,
    WebSocketChannel channel,
  ) {
    final clientId = message.split("#").last;
    channel.sink.close();
    clients.removeWhere((info) => info.id == clientId);
    print('client disconnected: $clientId');
  }

  static Future<WebSocketServer> start() async {
    final handler = webSocketHandler(
      (webSocket) {
        if (webSocket is! WebSocketChannel) return;
        webSocket.stream.listen(
          (message) {
            print('Received message: $message');
            if (message is! String) return;
            if (message.startsWith("established!#")) {
              _handleInitialMessage(message, webSocket);
              return;
            }
            if (message.startsWith("disconnected!#")) {
              _handleDisconnection(message, webSocket);
              return;
            }
          },
          onDone: () {
            print('WebSocket is closed');
          },
          onError: (error) {
            print('Error: $error');
          },
        );
      },
    );

    final server = await shelf_io.serve(handler, 'localhost', 0);
    final serverUrl = 'ws://${server.address.host}:${server.port}';
    print('Serving ws at $serverUrl');

    return WebSocketServer._(server);
  }

  void _boardcast(String message) {
    for (final client in clients) {
      client.channel.sink.add(message);
    }
  }

  void boardcastMR(MergeRequest mr) {
    final jsonResponse = ServerResponse<MergeRequest>(
      ResponseType.mergeRequest.value,
      mr,
    ).toJson((mr) => mr.toJson());

    _boardcast(jsonEncode(jsonResponse));
  }

  void boardcastMRs(MultiMR multiMr) {
    final jsonResponse = ServerResponse<MultiMR>(
      ResponseType.multipleMergeRequests.value,
      multiMr,
    ).toJson((multiMr) => multiMr.toJson());

    _boardcast(jsonEncode(jsonResponse));
  }

  void boardcastComment(MRComment comment) {
    final jsonResponse = ServerResponse<MRComment>(
      ResponseType.comment.value,
      comment,
    ).toJson((comment) => comment.toJson());

    _boardcast(jsonEncode(jsonResponse));
  }

  void boardcastComments(MultiComment multiNote) {
    final jsonResponse = ServerResponse<MultiComment>(
      ResponseType.multipleComments.value,
      multiNote,
    ).toJson((note) => note.toJson());

    _boardcast(jsonEncode(jsonResponse));
  }

  void boardcastMixed(MixedChanges changes) {
    final jsonResponse = ServerResponse<MixedChanges>(
      ResponseType.mixed.value,
      changes,
    ).toJson((note) => note.toJson());

    _boardcast(jsonEncode(jsonResponse));
  }
}
