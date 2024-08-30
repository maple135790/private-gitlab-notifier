// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mixed_changes.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MixedChanges _$MixedChangesFromJson(Map<String, dynamic> json) => MixedChanges(
      json['url'] as String,
      (json['mr_count'] as num).toInt(),
      (json['comment_count'] as num).toInt(),
    );

Map<String, dynamic> _$MixedChangesToJson(MixedChanges instance) =>
    <String, dynamic>{
      'url': instance.url,
      'mr_count': instance.mrCount,
      'comment_count': instance.commentCount,
    };
