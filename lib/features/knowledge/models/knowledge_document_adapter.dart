import 'package:hive/hive.dart';
import 'knowledge_document.dart';

/// Hive TypeAdapter for KnowledgeDocument
///
/// 手動編寫的 Adapter，避免 hive_generator 與 riverpod_lint 的衝突
class KnowledgeDocumentAdapter extends TypeAdapter<KnowledgeDocument> {
  @override
  final int typeId = 2; // 唯一的 typeId

  @override
  KnowledgeDocument read(BinaryReader reader) {
    final json = {
      'id': reader.readString(),
      'name': reader.readString(),
      'path': reader.readString(),
      'type': reader.readString(),
      'size': reader.readInt(),
      'status': reader.readString(),
      'addedAt': reader.readString(),
      'indexedAt': reader.read(),
      'errorMessage': reader.read(),
      'summary': reader.read(),
      'vectorCount': reader.read(),
    };
    return KnowledgeDocument.fromJson(json);
  }

  @override
  void write(BinaryWriter writer, KnowledgeDocument obj) {
    final json = obj.toJson();
    writer.writeString(json['id'] as String);
    writer.writeString(json['name'] as String);
    writer.writeString(json['path'] as String);
    writer.writeString(json['type'] as String);
    writer.writeInt(json['size'] as int);
    writer.writeString(json['status'] as String);
    writer.writeString(json['addedAt'] as String);
    writer.write(json['indexedAt']);
    writer.write(json['errorMessage']);
    writer.write(json['summary']);
    writer.write(json['vectorCount']);
  }
}
