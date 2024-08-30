// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'multi_mr.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MultiMR _$MultiMRFromJson(Map<String, dynamic> json) => MultiMR(
      json['url'] as String,
      (json['iids'] as List<dynamic>).map((e) => (e as num).toInt()).toList(),
    );

Map<String, dynamic> _$MultiMRToJson(MultiMR instance) => <String, dynamic>{
      'url': instance.url,
      'iids': instance.iids,
    };
