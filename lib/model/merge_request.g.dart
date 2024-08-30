// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'merge_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MergeRequest _$MergeRequestFromJson(Map<String, dynamic> json) => MergeRequest(
      iid: (json['iid'] as num).toInt(),
      title: json['title'] as String,
      author: User.fromJson(json['author'] as Map<String, dynamic>),
      reviewers: (json['reviewers'] as List<dynamic>)
          .map((e) => User.fromJson(e as Map<String, dynamic>))
          .toList(),
      webUrl: json['web_url'] as String,
    );

Map<String, dynamic> _$MergeRequestToJson(MergeRequest instance) =>
    <String, dynamic>{
      'iid': instance.iid,
      'title': instance.title,
      'author': instance.author,
      'reviewers': instance.reviewers,
      'web_url': instance.webUrl,
    };
