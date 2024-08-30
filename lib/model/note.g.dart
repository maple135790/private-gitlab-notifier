// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'note.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Note _$NoteFromJson(Map<String, dynamic> json) => Note(
      (json['id'] as num).toInt(),
      json['body'] as String,
      User.fromJson(json['author'] as Map<String, dynamic>),
      json['updated_at'] as String,
      json['system'] as bool,
      (json['noteable_iid'] as num).toInt(),
    );

Map<String, dynamic> _$NoteToJson(Note instance) => <String, dynamic>{
      'id': instance.id,
      'body': instance.body,
      'author': instance.author,
      'updated_at': instance.rawUpdatedAt,
      'system': instance.isSystem,
      'noteable_iid': instance.noteableIid,
    };
