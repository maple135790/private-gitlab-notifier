import 'package:private_gitlab_notifier/model/merge_request.dart';
import 'package:private_gitlab_notifier/model/note.dart';
import 'package:json_annotation/json_annotation.dart';

part 'mr_comment.g.dart';

@JsonSerializable()
class MRComment {
  final String title;
  final Note note;
  final String webUrl;

  const MRComment(this.title, this.note, this.webUrl);

  factory MRComment.fromChanges(Map<MergeRequest, List<Note>> changes) {
    final title = changes.entries.first.key.title;
    final note = changes.entries.first.value.first;
    final webUrl = changes.entries.first.key.webUrl;

    return MRComment(title, note, webUrl);
  }

  factory MRComment.fromJson(Map<String, dynamic> json) =>
      _$MRCommentFromJson(json);

  Map<String, dynamic> toJson() => _$MRCommentToJson(this);
}

class RechargeChannel {
  final String id;
  final String sortId;

  const RechargeChannel(this.id, this.sortId);

  static RechargeChannel fromJson(Map<String, dynamic> json) {
    return RechargeChannel(json['id'], json['sort']);
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'sort': sortId};
  }
}
