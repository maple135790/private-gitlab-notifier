// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'server_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ServerResponse<T> _$ServerResponseFromJson<T>(
  Map<String, dynamic> json,
  T Function(Object? json) fromJsonT,
) =>
    ServerResponse<T>(
      (json['type'] as num).toInt(),
      fromJsonT(json['data']),
    );

Map<String, dynamic> _$ServerResponseToJson<T>(
  ServerResponse<T> instance,
  Object? Function(T value) toJsonT,
) =>
    <String, dynamic>{
      'type': instance.rawType,
      'data': toJsonT(instance.data),
    };
