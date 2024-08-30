import 'package:private_gitlab_notifier/model/user.dart';
import 'package:json_annotation/json_annotation.dart';

part 'merge_request.g.dart';

@JsonSerializable()
class MergeRequest {
  final int iid;
  final String title;
  final User author;
  final List<User> reviewers;
  @JsonKey(name: 'web_url')
  final String webUrl;

  const MergeRequest({
    required this.iid,
    required this.title,
    required this.author,
    required this.reviewers,
    required this.webUrl,
  });

  factory MergeRequest.fromJson(Map<String, dynamic> json) =>
      _$MergeRequestFromJson(json);

  Map<String, dynamic> toJson() => _$MergeRequestToJson(this);
}
