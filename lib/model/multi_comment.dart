import 'package:private_gitlab_notifier/model/merge_request.dart';
import 'package:private_gitlab_notifier/model/note.dart';
import 'package:json_annotation/json_annotation.dart';

part 'multi_comment.g.dart';

@JsonSerializable()
class MultiComment {
  final String url;
  final int count;

  const MultiComment(this.url, this.count);

  factory MultiComment.fromChanges(Map<MergeRequest, List<Note>> changes) {
    final mr = changes.entries.first.key;
    final count = changes.entries.first.value.length;

    return MultiComment(mr.webUrl, count);
  }

  factory MultiComment.fromJson(Map<String, dynamic> json) =>
      _$MultiCommentFromJson(json);

  Map<String, dynamic> toJson() => _$MultiCommentToJson(this);
}
