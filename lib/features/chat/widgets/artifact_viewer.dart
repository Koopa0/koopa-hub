import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_highlighter/flutter_highlighter.dart';
import 'package:flutter_highlighter/themes/github.dart';
import 'package:flutter_highlighter/themes/github-dark-dimmed.dart';
import '../models/artifact.dart';

/// Widget to display and interact with AI-generated artifacts
/// Inspired by Claude's Artifacts feature
class ArtifactViewer extends StatefulWidget {
  const ArtifactViewer({
    super.key,
    required this.artifact,
    this.onClose,
    this.onEdit,
  });

  final Artifact artifact;
  final VoidCallback? onClose;
  final ValueChanged<String>? onEdit;

  @override
  State<ArtifactViewer> createState() => _ArtifactViewerState();
}

class _ArtifactViewerState extends State<ArtifactViewer> {
  late TextEditingController _editController;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _editController = TextEditingController(text: widget.artifact.content);
  }

  @override
  void dispose() {
    _editController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border.all(
          color: theme.colorScheme.outlineVariant,
          width: 1,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          _buildHeader(theme),

          const Divider(height: 1),

          // Content
          Expanded(
            child: _buildContent(theme, isDark),
          ),

          // Footer with actions
          _buildFooter(theme),
        ],
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Type icon
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _getTypeIcon(widget.artifact.type),
              size: 20,
              color: theme.colorScheme.onPrimaryContainer,
            ),
          ),
          const SizedBox(width: 12),

          // Title and type
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.artifact.title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  widget.artifact.typeDisplayName,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),

          // Edit button (if onEdit provided)
          if (widget.onEdit != null) ...[
            IconButton(
              icon: Icon(
                _isEditing ? Icons.visibility : Icons.edit,
                size: 20,
              ),
              onPressed: () {
                setState(() {
                  _isEditing = !_isEditing;
                  if (_isEditing) {
                    _editController.text = widget.artifact.content;
                  }
                });
              },
              tooltip: _isEditing ? 'Preview' : 'Edit',
            ),
          ],

          // Close button
          if (widget.onClose != null)
            IconButton(
              icon: const Icon(Icons.close, size: 20),
              onPressed: widget.onClose,
              tooltip: 'Close',
            ),
        ],
      ),
    );
  }

  Widget _buildContent(ThemeData theme, bool isDark) {
    if (_isEditing) {
      return _buildEditor(theme);
    }

    return switch (widget.artifact.type) {
      ArtifactType.code => _buildCodeView(theme, isDark),
      ArtifactType.markdown => _buildMarkdownView(theme),
      ArtifactType.html => _buildHtmlPreview(theme),
      ArtifactType.json => _buildJsonView(theme, isDark),
      ArtifactType.mermaid => _buildMermaidView(theme),
    };
  }

  Widget _buildEditor(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: theme.colorScheme.surfaceContainerLowest,
      child: TextField(
        controller: _editController,
        maxLines: null,
        expands: true,
        style: const TextStyle(
          fontFamily: 'monospace',
          fontSize: 14,
        ),
        decoration: const InputDecoration(
          border: InputBorder.none,
          hintText: 'Edit content...',
        ),
      ),
    );
  }

  Widget _buildCodeView(ThemeData theme, bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: HighlightView(
        widget.artifact.content,
        language: widget.artifact.language ?? 'dart',
        theme: isDark ? githubDarkDimmedTheme : githubTheme,
        padding: const EdgeInsets.all(16),
        textStyle: const TextStyle(
          fontFamily: 'monospace',
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _buildMarkdownView(ThemeData theme) {
    return Markdown(
      data: widget.artifact.content,
      selectable: true,
      padding: const EdgeInsets.all(16),
      styleSheet: MarkdownStyleSheet.fromTheme(theme),
    );
  }

  Widget _buildHtmlPreview(ThemeData theme) {
    // For now, just show the raw HTML
    // In production, you might want to use webview_flutter
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.orange.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, size: 16, color: Colors.orange.shade700),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'HTML Preview requires webview (not implemented in this demo)',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.orange.shade900,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SelectableText(
            widget.artifact.content,
            style: const TextStyle(
              fontFamily: 'monospace',
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJsonView(ThemeData theme, bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: HighlightView(
        widget.artifact.content,
        language: 'json',
        theme: isDark ? githubDarkDimmedTheme : githubTheme,
        padding: const EdgeInsets.all(16),
        textStyle: const TextStyle(
          fontFamily: 'monospace',
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _buildMermaidView(ThemeData theme) {
    // Mermaid rendering requires external package
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, size: 16, color: Colors.blue.shade700),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Mermaid diagram rendering not implemented in this demo',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.blue.shade900,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SelectableText(
            widget.artifact.content,
            style: const TextStyle(
              fontFamily: 'monospace',
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLowest,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
      ),
      child: Row(
        children: [
          // Copy button
          TextButton.icon(
            onPressed: () => _copyToClipboard(),
            icon: const Icon(Icons.copy, size: 16),
            label: const Text('Copy'),
          ),

          const SizedBox(width: 8),

          // Save button (if editing)
          if (_isEditing && widget.onEdit != null)
            TextButton.icon(
              onPressed: () {
                widget.onEdit!(_editController.text);
                setState(() {
                  _isEditing = false;
                });
              },
              icon: const Icon(Icons.save, size: 16),
              label: const Text('Save'),
            ),

          const Spacer(),

          // File info
          Text(
            '${widget.artifact.content.length} chars',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getTypeIcon(ArtifactType type) {
    return switch (type) {
      ArtifactType.code => Icons.code,
      ArtifactType.markdown => Icons.description,
      ArtifactType.html => Icons.web,
      ArtifactType.json => Icons.data_object,
      ArtifactType.mermaid => Icons.account_tree,
    };
  }

  Future<void> _copyToClipboard() async {
    await Clipboard.setData(
      ClipboardData(text: widget.artifact.content),
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Copied to clipboard'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }
}

/// Compact artifact card for inline display
class ArtifactCard extends StatelessWidget {
  const ArtifactCard({
    super.key,
    required this.artifact,
    this.onTap,
  });

  final Artifact artifact;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: theme.colorScheme.primaryContainer.withOpacity(0.3),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: theme.colorScheme.primary.withOpacity(0.3),
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            // Icon
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                _getTypeIcon(artifact.type),
                size: 20,
                color: theme.colorScheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(width: 12),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.auto_awesome,
                        size: 14,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Artifact',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    artifact.title,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    artifact.typeDisplayName,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),

            // Arrow
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }

  IconData _getTypeIcon(ArtifactType type) {
    return switch (type) {
      ArtifactType.code => Icons.code,
      ArtifactType.markdown => Icons.description,
      ArtifactType.html => Icons.web,
      ArtifactType.json => Icons.data_object,
      ArtifactType.mermaid => Icons.account_tree,
    };
  }
}
