import 'package:private_gitlab_notifier/model/user.dart';
import 'package:json_annotation/json_annotation.dart';

part 'note.g.dart';

@JsonSerializable()
class Note {
  final int id;
  final String body;
  final User author;
  @JsonKey(name: 'updated_at')
  final String rawUpdatedAt;
  @JsonKey(name: 'system')
  final bool isSystem;
  @JsonKey(name: 'noteable_iid')
  final int noteableIid;

  const Note(
    this.id,
    this.body,
    this.author,
    this.rawUpdatedAt,
    this.isSystem,
    this.noteableIid,
  );

  DateTime get updatedAt => DateTime.parse(rawUpdatedAt);

  static bool isNewer(Note a, Note b) => a.updatedAt.isAfter(b.updatedAt);

  factory Note.fromJson(Map<String, dynamic> json) => _$NoteFromJson(json);

  Map<String, dynamic> toJson() => _$NoteToJson(this);

  @override
  bool operator ==(Object other) {
    if (other is! Note) return false;

    return (id == other.id) && (noteableIid == other.noteableIid);
  }

  @override
  int get hashCode => id.hashCode;
}
