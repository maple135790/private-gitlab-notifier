import 'package:private_gitlab_notifier/model/merge_request.dart';
import 'package:json_annotation/json_annotation.dart';

part 'multi_mr.g.dart';

@JsonSerializable()
class MultiMR {
  final String url;
  final List<int> iids;

  const MultiMR(this.url, this.iids);

  factory MultiMR.fromChanges(
    List<MergeRequest> changes,
  ) {
    final url = changes.first.webUrl.split('/').take(5).join('/');
    return MultiMR(
      url,
      changes.map((mr) => mr.iid).toList(),
    );
  }

  factory MultiMR.fromJson(Map<String, dynamic> json) =>
      _$MultiMRFromJson(json);

  Map<String, dynamic> toJson() => _$MultiMRToJson(this);
}
