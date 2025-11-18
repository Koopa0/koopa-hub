import 'package:hive/hive.dart';
import 'message.dart';

/// Hive TypeAdapter for Message
///
/// 手動編寫的 Adapter，避免 hive_generator 與 riverpod_lint 的衝突
class MessageAdapter extends TypeAdapter<Message> {
  @override
  final int typeId = 1; // 唯一的 typeId

  @override
  Message read(BinaryReader reader) {
    final json = {
      'id': reader.readString(),
      'content': reader.readString(),
      'type': reader.readString(),
      'timestamp': reader.readString(),
      'citations': reader.read(),
      'isStreaming': reader.readBool(),
    };
    return Message.fromJson(json);
  }

  @override
  void write(BinaryWriter writer, Message obj) {
    final json = obj.toJson();
    writer.writeString(json['id'] as String);
    writer.writeString(json['content'] as String);
    writer.writeString(json['type'] as String);
    writer.writeString(json['timestamp'] as String);
    writer.write(json['citations']);
    writer.writeBool(json['isStreaming'] as bool);
  }
}
