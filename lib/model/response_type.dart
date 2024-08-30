import 'package:private_gitlab_notifier/model/merge_request.dart';
import 'package:private_gitlab_notifier/model/note.dart';

typedef MergeRequestDiff = ({
  List<MergeRequest> mrChanges,
  Map<MergeRequest, List<Note>> commentChanges,
});

enum ResponseType {
  nothingToNotify(0),
  mergeRequest(2),
  multipleMergeRequests(3),
  comment(4),
  multipleComments(5),
  mixed(6);

  final int value;
  const ResponseType(this.value);

  static ResponseType fromRawValue(int rawValue) {
    return switch (rawValue) {
      0 => nothingToNotify,
      2 => mergeRequest,
      3 => multipleMergeRequests,
      4 => comment,
      5 => multipleComments,
      6 => mixed,
      _ => throw Exception('Unknown ResponseType: $rawValue'),
    };
  }

  static ResponseType fromRawJson(Map<String, dynamic> json) {
    return fromRawValue(json['type'] as int);
  }

  static ResponseType fromChanges(MergeRequestDiff changes) {
    final mrChanges = changes.mrChanges;
    final commentChanges = changes.commentChanges.entries;

    final newMRs = mrChanges.length;
    int newComments = 0;

    for (final newCommentsInMr in commentChanges) {
      newComments += newCommentsInMr.value.length;
    }

    if (mrChanges.isEmpty && commentChanges.isEmpty) {
      return nothingToNotify;
    }

    if (newMRs > 1 && newComments >= 1) {
      return mixed;
    }

    if (newMRs == 1 && newComments == 1) {
      return mergeRequest;
    }

    if (newMRs > 1) {
      return multipleMergeRequests;
    }

    if (commentChanges.length == 1 && newComments == 1) {
      return comment;
    } else {
      return multipleComments;
    }
  }
}
