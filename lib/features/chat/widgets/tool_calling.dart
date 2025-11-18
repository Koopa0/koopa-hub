import 'package:flutter/material.dart';
import 'dart:convert';

/// Tool call data model
class ToolCall {
  final String toolName;
  final String? description;
  final Map<String, dynamic>? input;
  final dynamic output;
  final ToolCallStatus status;
  final DateTime timestamp;
  final String? errorMessage;

  const ToolCall({
    required this.toolName,
    this.description,
    this.input,
    this.output,
    required this.status,
    required this.timestamp,
    this.errorMessage,
  });

  ToolCall copyWith({
    String? toolName,
    String? description,
    Map<String, dynamic>? input,
    dynamic output,
    ToolCallStatus? status,
    DateTime? timestamp,
    String? errorMessage,
  }) {
    return ToolCall(
      toolName: toolName ?? this.toolName,
      description: description ?? this.description,
      input: input ?? this.input,
      output: output ?? this.output,
      status: status ?? this.status,
      timestamp: timestamp ?? this.timestamp,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

enum ToolCallStatus {
  pending,
  running,
  completed,
  failed,
}

/// Widget to display tool calling process
/// Inspired by Claude and ChatGPT's function calling UI
class ToolCallingWidget extends StatefulWidget {
  const ToolCallingWidget({
    super.key,
    required this.toolCall,
    this.isExpanded = false,
  });

  final ToolCall toolCall;
  final bool isExpanded;

  @override
  State<ToolCallingWidget> createState() => _ToolCallingWidgetState();
}

class _ToolCallingWidgetState extends State<ToolCallingWidget> {
  late bool _isExpanded;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.isExpanded;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: _getBackgroundColor(theme),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _getBorderColor(theme),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          InkWell(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  // Tool icon
                  _buildToolIcon(theme),
                  const SizedBox(width: 10),

                  // Tool name and description
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              _getToolDisplayName(widget.toolCall.toolName),
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: _getTextColor(theme),
                              ),
                            ),
                            const SizedBox(width: 6),
                            _buildStatusBadge(theme),
                          ],
                        ),
                        if (widget.toolCall.description != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            widget.toolCall.description!,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  // Expand/collapse icon
                  Icon(
                    _isExpanded ? Icons.expand_less : Icons.expand_more,
                    size: 20,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ],
              ),
            ),
          ),

          // Expanded content
          if (_isExpanded) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Input parameters
                  if (widget.toolCall.input != null &&
                      widget.toolCall.input!.isNotEmpty) ...[
                    _buildSection(
                      theme,
                      'Input',
                      _formatJson(widget.toolCall.input!),
                    ),
                    const SizedBox(height: 12),
                  ],

                  // Output/Result
                  if (widget.toolCall.status == ToolCallStatus.completed &&
                      widget.toolCall.output != null) ...[
                    _buildSection(
                      theme,
                      'Output',
                      _formatOutput(widget.toolCall.output),
                    ),
                  ],

                  // Error message
                  if (widget.toolCall.status == ToolCallStatus.failed &&
                      widget.toolCall.errorMessage != null) ...[
                    _buildSection(
                      theme,
                      'Error',
                      widget.toolCall.errorMessage!,
                      isError: true,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildToolIcon(ThemeData theme) {
    final icon = _getToolIcon(widget.toolCall.toolName);

    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: _getIconBackgroundColor(theme),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        icon,
        size: 18,
        color: _getIconColor(theme),
      ),
    );
  }

  Widget _buildStatusBadge(ThemeData theme) {
    return switch (widget.toolCall.status) {
      ToolCallStatus.pending => Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            'Pending',
            style: theme.textTheme.labelSmall?.copyWith(
              fontSize: 10,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ToolCallStatus.running => Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 10,
              height: 10,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              'Running',
              style: theme.textTheme.labelSmall?.copyWith(
                fontSize: 10,
                color: theme.colorScheme.primary,
              ),
            ),
          ],
        ),
      ToolCallStatus.completed => Icon(
          Icons.check_circle,
          size: 14,
          color: Colors.green.shade600,
        ),
      ToolCallStatus.failed => Icon(
          Icons.error,
          size: 14,
          color: Colors.red.shade600,
        ),
    };
  }

  Widget _buildSection(
    ThemeData theme,
    String title,
    String content, {
    bool isError = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.labelSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: isError
                ? Colors.red.shade600
                : theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: isError
                ? Colors.red.shade50.withOpacity(0.5)
                : theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isError
                  ? Colors.red.shade200
                  : theme.colorScheme.outlineVariant,
              width: 1,
            ),
          ),
          child: Text(
            content,
            style: theme.textTheme.bodySmall?.copyWith(
              fontFamily: 'monospace',
              color: isError
                  ? Colors.red.shade900
                  : theme.colorScheme.onSurface,
            ),
          ),
        ),
      ],
    );
  }

  String _getToolDisplayName(String toolName) {
    return switch (toolName) {
      'web_search' => '🔍 Web Search',
      'calculator' => '🧮 Calculator',
      'knowledge_base' => '📚 Knowledge Base',
      'code_interpreter' => '💻 Code Interpreter',
      'image_generation' => '🎨 Image Generation',
      'file_reader' => '📄 File Reader',
      _ => '🔧 $toolName',
    };
  }

  IconData _getToolIcon(String toolName) {
    return switch (toolName) {
      'web_search' => Icons.search,
      'calculator' => Icons.calculate,
      'knowledge_base' => Icons.library_books,
      'code_interpreter' => Icons.code,
      'image_generation' => Icons.image,
      'file_reader' => Icons.description,
      _ => Icons.build,
    };
  }

  Color _getBackgroundColor(ThemeData theme) {
    return switch (widget.toolCall.status) {
      ToolCallStatus.failed =>
        Colors.red.shade50.withOpacity(0.3),
      ToolCallStatus.completed =>
        Colors.green.shade50.withOpacity(0.2),
      _ => theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
    };
  }

  Color _getBorderColor(ThemeData theme) {
    return switch (widget.toolCall.status) {
      ToolCallStatus.failed => Colors.red.shade200,
      ToolCallStatus.completed => Colors.green.shade200,
      ToolCallStatus.running => theme.colorScheme.primary.withOpacity(0.5),
      _ => theme.colorScheme.outlineVariant.withOpacity(0.5),
    };
  }

  Color _getTextColor(ThemeData theme) {
    return switch (widget.toolCall.status) {
      ToolCallStatus.running => theme.colorScheme.primary,
      ToolCallStatus.failed => Colors.red.shade700,
      _ => theme.colorScheme.onSurface,
    };
  }

  Color _getIconBackgroundColor(ThemeData theme) {
    return switch (widget.toolCall.status) {
      ToolCallStatus.completed =>
        Colors.green.shade100.withOpacity(0.5),
      ToolCallStatus.failed => Colors.red.shade100.withOpacity(0.5),
      ToolCallStatus.running =>
        theme.colorScheme.primaryContainer.withOpacity(0.5),
      _ => theme.colorScheme.surfaceContainerHighest,
    };
  }

  Color _getIconColor(ThemeData theme) {
    return switch (widget.toolCall.status) {
      ToolCallStatus.completed => Colors.green.shade700,
      ToolCallStatus.failed => Colors.red.shade700,
      ToolCallStatus.running => theme.colorScheme.primary,
      _ => theme.colorScheme.onSurfaceVariant,
    };
  }

  String _formatJson(Map<String, dynamic> json) {
    try {
      const encoder = JsonEncoder.withIndent('  ');
      return encoder.convert(json);
    } catch (e) {
      return json.toString();
    }
  }

  String _formatOutput(dynamic output) {
    if (output is Map || output is List) {
      try {
        const encoder = JsonEncoder.withIndent('  ');
        return encoder.convert(output);
      } catch (e) {
        return output.toString();
      }
    }
    return output.toString();
  }
}

/// Widget to display multiple tool calls
class ToolCallsList extends StatelessWidget {
  const ToolCallsList({
    super.key,
    required this.toolCalls,
  });

  final List<ToolCall> toolCalls;

  @override
  Widget build(BuildContext context) {
    if (toolCalls.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: toolCalls
          .map((toolCall) => ToolCallingWidget(toolCall: toolCall))
          .toList(),
    );
  }
}
