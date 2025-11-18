/// Artifact types supported by the system
enum ArtifactType {
  code,
  markdown,
  html,
  mermaid,
  json,
}

/// Artifact data model
/// Represents AI-generated content that can be displayed separately
class Artifact {
  final String id;
  final String title;
  final ArtifactType type;
  final String content;
  final String? language; // For code artifacts (dart, python, javascript, etc.)
  final DateTime createdAt;
  final DateTime? updatedAt;

  const Artifact({
    required this.id,
    required this.title,
    required this.type,
    required this.content,
    this.language,
    required this.createdAt,
    this.updatedAt,
  });

  Artifact copyWith({
    String? id,
    String? title,
    ArtifactType? type,
    String? content,
    String? language,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Artifact(
      id: id ?? this.id,
      title: title ?? this.title,
      type: type ?? this.type,
      content: content ?? this.content,
      language: language ?? this.language,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Get file extension for this artifact type
  String get fileExtension {
    return switch (type) {
      ArtifactType.code => language != null ? '.$language' : '.txt',
      ArtifactType.markdown => '.md',
      ArtifactType.html => '.html',
      ArtifactType.mermaid => '.mmd',
      ArtifactType.json => '.json',
    };
  }

  /// Get display name for artifact type
  String get typeDisplayName {
    return switch (type) {
      ArtifactType.code => language ?? 'Code',
      ArtifactType.markdown => 'Markdown',
      ArtifactType.html => 'HTML',
      ArtifactType.mermaid => 'Diagram',
      ArtifactType.json => 'JSON',
    };
  }

  /// Create from map (for API responses)
  factory Artifact.fromMap(Map<String, dynamic> map) {
    return Artifact(
      id: map['id'] as String,
      title: map['title'] as String,
      type: ArtifactType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => ArtifactType.markdown,
      ),
      content: map['content'] as String,
      language: map['language'] as String?,
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: map['updatedAt'] != null
          ? DateTime.parse(map['updatedAt'] as String)
          : null,
    );
  }

  /// Convert to map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'type': type.name,
      'content': content,
      'language': language,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}
