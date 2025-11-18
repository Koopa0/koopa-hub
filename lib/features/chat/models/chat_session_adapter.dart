import 'package:hive/hive.dart';
import 'chat_session.dart';

/// Hive TypeAdapter for ChatSession
///
/// 手動編寫的 Adapter，避免 hive_generator 與 riverpod_lint 的衝突
class ChatSessionAdapter extends TypeAdapter<ChatSession> {
  @override
  final int typeId = 0; // 唯一的 typeId，確保不與其他 adapter 衝突

  @override
  ChatSession read(BinaryReader reader) {
    final json = {
      'id': reader.readString(),
      'title': reader.readString(),
      'messages': reader.read(),
      'selectedModel': reader.readString(),
      'createdAt': reader.readString(),
      'updatedAt': reader.readString(),
      'isPinned': reader.readBool(),
    };
    return ChatSession.fromJson(json);
  }

  @override
  void write(BinaryWriter writer, ChatSession obj) {
    final json = obj.toJson();
    writer.writeString(json['id'] as String);
    writer.writeString(json['title'] as String);
    writer.write(json['messages']);
    writer.writeString(json['selectedModel'] as String);
    writer.writeString(json['createdAt'] as String);
    writer.writeString(json['updatedAt'] as String);
    writer.writeBool(json['isPinned'] as bool);
  }
}
