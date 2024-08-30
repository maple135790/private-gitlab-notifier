import 'dart:convert';

import 'package:private_gitlab_notifier/model/merge_request.dart';
import 'package:private_gitlab_notifier/model/note.dart';
import 'package:private_gitlab_notifier/model/user.dart';
import 'package:http/http.dart' as http;

class Repository {
  final http.Client client;
  final String token;
  final String domain;
  final int projectId;
  final String _apiBase;

  const Repository({
    required this.domain,
    required this.client,
    required this.token,
    required this.projectId,
  }) : _apiBase = 'https://$domain/api/v4';

  Future<http.Response> authGet(String path) async {
    final response = await client.get(
      Uri.parse('$_apiBase$path'),
      headers: {
        'PRIVATE-TOKEN': token,
      },
    );
    return response;
  }

  Future<User> getUser() async {
    final response = await authGet('/user');
    return User.fromJson(jsonDecode(response.body));
  }

  Future<List<MergeRequest>> _getMergeRequest({Uri? queryParameters}) async {
    final response =
        await authGet('/projects/$projectId/merge_requests$queryParameters');
    final rawMrs = jsonDecode(utf8.decode(response.bodyBytes));
    if (rawMrs is! List) throw Exception('Invalid data');
    final mrs = <MergeRequest>[];
    for (final rawMr in rawMrs) {
      if (rawMr is! Map<String, dynamic>) throw Exception('Invalid data');
      mrs.add(MergeRequest.fromJson(rawMr));
    }

    return mrs;
  }

  Future<List<MergeRequest>> getOpenMergeRequestsByAuthor(User author) async {
    final query = Uri(
      queryParameters: {
        'state': 'opened',
        'author_id': author.id.toString(),
      },
    );
    return _getMergeRequest(queryParameters: query);
  }

  Future<List<MergeRequest>> getOpenMergeRequestsByReviewer(
    User reviewer,
  ) async {
    final query = Uri(
      queryParameters: {
        'state': 'opened',
        'reviewer_id': reviewer.id.toString(),
      },
    );
    return _getMergeRequest(queryParameters: query);
  }

  Future<List<Note>> getMergeRequestNotes(int mergeRequestIid) async {
    final response = await authGet(
      '/projects/$projectId/merge_requests/$mergeRequestIid/notes?&order_by=updated_at',
    );

    final rawNotes = jsonDecode(utf8.decode(response.bodyBytes));
    if (rawNotes is! List) throw Exception('Invalid data');
    final notes = <Note>[];
    for (final rawNote in rawNotes) {
      if (rawNote is Map<String, dynamic>) {
        final note = Note.fromJson(rawNote);
        notes.add(note);
      }
    }
    return notes;
  }
}
