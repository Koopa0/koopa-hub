import 'package:flutter/material.dart';

/// 快速搜尋對話框
///
/// Cmd/Ctrl + K 觸發的全局搜尋
class SearchDialog extends StatefulWidget {
  const SearchDialog({super.key});

  @override
  State<SearchDialog> createState() => _SearchDialogState();

  /// 顯示搜尋對話框
  static Future<String?> show(BuildContext context) {
    return showDialog<String>(
      context: context,
      builder: (context) => const SearchDialog(),
    );
  }
}

class _SearchDialogState extends State<SearchDialog> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    // 自動聚焦
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        width: 600,
        constraints: const BoxConstraints(maxHeight: 500),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 搜尋輸入框
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _controller,
                focusNode: _focusNode,
                decoration: InputDecoration(
                  hintText: '搜尋對話、文件...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _controller.clear();
                            setState(() => _searchQuery = '');
                          },
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onChanged: (value) {
                  setState(() => _searchQuery = value);
                },
                onSubmitted: (value) {
                  if (value.isNotEmpty) {
                    Navigator.of(context).pop(value);
                  }
                },
              ),
            ),

            // 搜尋結果
            Flexible(
              child: _searchQuery.isEmpty
                  ? _buildRecentSearches(context)
                  : _buildSearchResults(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentSearches(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // TODO: 從儲存中載入最近搜尋
    final recentSearches = [
      'Flutter 狀態管理',
      'Riverpod 使用方法',
      'Material 3 設計',
    ];

    return ListView(
      shrinkWrap: true,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            '最近搜尋',
            style: theme.textTheme.labelMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        ...recentSearches.map(
          (query) => ListTile(
            leading: const Icon(Icons.history),
            title: Text(query),
            onTap: () {
              Navigator.of(context).pop(query);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSearchResults(BuildContext context) {
    final theme = Theme.of(context);

    // TODO: 實作實際搜尋邏輯
    final results = [
      _SearchResult(
        title: '對話 1',
        snippet: '包含 "$_searchQuery" 的對話內容...',
        type: _SearchResultType.chat,
      ),
      _SearchResult(
        title: 'document.pdf',
        snippet: '包含 "$_searchQuery" 的文件內容...',
        type: _SearchResultType.document,
      ),
    ];

    if (results.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.search_off, size: 64),
            const SizedBox(height: 16),
            Text(
              '找不到結果',
              style: theme.textTheme.titleMedium,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      itemCount: results.length,
      itemBuilder: (context, index) {
        final result = results[index];
        return ListTile(
          leading: Icon(_getResultIcon(result.type)),
          title: Text(result.title),
          subtitle: Text(
            result.snippet,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          onTap: () {
            Navigator.of(context).pop(result.title);
          },
        );
      },
    );
  }

  IconData _getResultIcon(_SearchResultType type) {
    return switch (type) {
      _SearchResultType.chat => Icons.chat_bubble_outline,
      _SearchResultType.document => Icons.description_outlined,
      _SearchResultType.setting => Icons.settings_outlined,
    };
  }
}

enum _SearchResultType {
  chat,
  document,
  setting,
}

class _SearchResult {
  const _SearchResult({
    required this.title,
    required this.snippet,
    required this.type,
  });

  final String title;
  final String snippet;
  final _SearchResultType type;
}
