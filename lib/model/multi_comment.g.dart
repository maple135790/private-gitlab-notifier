// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'multi_comment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MultiComment _$MultiCommentFromJson(Map<String, dynamic> json) => MultiComment(
      json['url'] as String,
      (json['count'] as num).toInt(),
    );

Map<String, dynamic> _$MultiCommentToJson(MultiComment instance) =>
    <String, dynamic>{
      'url': instance.url,
      'count': instance.count,
    };
