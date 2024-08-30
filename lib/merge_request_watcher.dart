import 'dart:async';

import 'package:private_gitlab_notifier/model/merge_request.dart';
import 'package:private_gitlab_notifier/model/note.dart';
import 'package:private_gitlab_notifier/model/response_type.dart';
import 'package:private_gitlab_notifier/repository.dart';
import 'package:http/http.dart' as http;

class MergeRequestWatcher {
  final Repository repo;
  final http.Client client;

  final List<int> _watchedMRiids = [];
  final Map<int, List<Note>> _watchedMRComment = {};

  MergeRequestWatcher._(this.repo, this.client);

  static Future<MergeRequestWatcher> create(
    Repository repo,
    http.Client client,
  ) async {
    final notifier = MergeRequestWatcher._(repo, client);
    await notifier._initFetch();
    return notifier;
  }

  Future<List<MergeRequest>> _getRelatedMRs() async {
    final user = await repo.getUser();
    final authorOpenMRs = await repo.getOpenMergeRequestsByAuthor(user);
    final reviewerOpenMRs = await repo.getOpenMergeRequestsByReviewer(user);

    final related = authorOpenMRs.toSet().union(reviewerOpenMRs.toSet());

    return related.toList();
  }

  Future<List<Note>> _getRelatedMRComments(MergeRequest mr) async {
    final notes = await repo.getMergeRequestNotes(mr.iid);
    return notes;
  }

  Future<void> _initFetch() async {
    final mrs = await _getRelatedMRs();
    for (final mr in mrs) {
      final notes = await _getRelatedMRComments(mr);
      _watchedMRComment.addAll({mr.iid: notes});
    }
    _watchedMRiids.addAll(mrs.map((mr) => mr.iid));
  }

  List<MergeRequest> getMRDiff(List<MergeRequest> mrs) {
    final mrDiff = List<MergeRequest>.from(mrs);
    mrDiff.removeWhere((mr) => _watchedMRiids.contains(mr.iid));
    _watchedMRiids.addAll(mrs.map((mr) => mr.iid));

    return mrDiff;
  }

  Future<Map<MergeRequest, List<Note>>> watchComment(
    List<MergeRequest> mrs,
  ) async {
    final mrCommentMap = <MergeRequest, List<Note>>{};
    final mrIdLUT = <int, MergeRequest>{};

    for (final mr in mrs) {
      mrIdLUT.addAll({mr.iid: mr});
    }

    final fetchCommentTasks = await Future.wait(
      List.generate(mrs.length, (index) => _getRelatedMRComments(mrs[index])),
    );

    for (final comments in fetchCommentTasks) {
      final mrIid = comments.first.noteableIid;
      final mr = mrIdLUT[mrIid]!;
      mrCommentMap.addAll({mr: comments});
    }

    return mrCommentMap;
  }

  Map<MergeRequest, List<Note>> getCommentDiff(
    Map<MergeRequest, List<Note>> commentMap,
  ) {
    final commentDiff = <MergeRequest, List<Note>>{};
    for (final commentEntry in commentMap.entries) {
      final mr = commentEntry.key;
      final comments = commentEntry.value;
      if (!_watchedMRComment.containsKey(mr.iid)) {
        commentDiff.addAll({mr: comments});
        _watchedMRComment.addAll({mr.iid: comments});
      } else {
        final watchedComments = List.from(_watchedMRComment[mr.iid]!);
        final newComments =
            comments.toSet().difference(watchedComments.toSet());
        if (newComments.isNotEmpty) {
          commentDiff.addAll({mr: newComments.toList()});
          _watchedMRComment[mr.iid]!.addAll(newComments);
        }
      }
    }
    return commentDiff;
  }

  Future<MergeRequestDiff> watchChanges() async {
    print('watching...');
    final mrs = await _getRelatedMRs();

    final mrDiff = getMRDiff(mrs);
    final commentMap = await watchComment(mrs);

    final commentDiff = getCommentDiff(commentMap);

    return (
      mrChanges: mrDiff,
      commentChanges: commentDiff,
    );
  }
}
