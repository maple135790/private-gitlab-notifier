import 'package:private_gitlab_notifier/model/response_type.dart';
import 'package:json_annotation/json_annotation.dart';

part 'mixed_changes.g.dart';

@JsonSerializable()
class MixedChanges {
  final String url;
  @JsonKey(name: 'mr_count')
  final int mrCount;
  @JsonKey(name: 'comment_count')
  final int commentCount;

  const MixedChanges(
    this.url,
    this.mrCount,
    this.commentCount,
  );

  factory MixedChanges.fromChanges(
    MergeRequestDiff changes,
  ) {
    final url = changes.mrChanges.first.webUrl.split('/').take(5).join('/');
    final mrCount = changes.mrChanges.length;
    final commentCount = changes.commentChanges.values.fold<int>(
      0,
      (prev, notes) => prev + notes.length,
    );

    return MixedChanges(
      url,
      mrCount,
      commentCount,
    );
  }

  factory MixedChanges.fromJson(Map<String, dynamic> json) =>
      _$MixedChangesFromJson(json);

  Map<String, dynamic> toJson() => _$MixedChangesToJson(this);
}
