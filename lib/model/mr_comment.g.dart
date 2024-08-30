// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mr_comment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MRComment _$MRCommentFromJson(Map<String, dynamic> json) => MRComment(
      json['title'] as String,
      Note.fromJson(json['note'] as Map<String, dynamic>),
      json['webUrl'] as String,
    );

Map<String, dynamic> _$MRCommentToJson(MRComment instance) => <String, dynamic>{
      'title': instance.title,
      'note': instance.note,
      'webUrl': instance.webUrl,
    };
