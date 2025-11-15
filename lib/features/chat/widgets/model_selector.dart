import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/chat_session.dart';
import '../providers/chat_provider.dart';

/// AI 模型選擇器
///
/// 允許使用者選擇：
/// - Koopa (本地 RAG)
/// - Koopa (網路搜尋)
/// - Gemini (雲端)
class ModelSelector extends ConsumerWidget {
  const ModelSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(currentSessionProvider);
    if (session == null) return const SizedBox.shrink();

    final theme = Theme.of(context);

    return MenuAnchor(
      builder: (context, controller, child) {
        return FilledButton.tonalIcon(
          onPressed: () {
            if (controller.isOpen) {
              controller.close();
            } else {
              controller.open();
            }
          },
          icon: _getModelIcon(session.selectedModel),
          label: Text(session.selectedModel.displayName),
        );
      },
      menuChildren: AIModel.values.map((model) {
        final isSelected = model == session.selectedModel;

        return MenuItemButton(
          leadingIcon: _getModelIcon(model),
          trailingIcon: isSelected
              ? Icon(Icons.check, color: theme.colorScheme.primary)
              : null,
          onPressed: () {
            final updatedSession = session.copyWith(selectedModel: model);
            ref.read(chatSessionsProvider.notifier).updateSession(
                  updatedSession,
                );
          },
          child: Text(model.displayName),
        );
      }).toList(),
    );
  }

  Icon _getModelIcon(AIModel model) {
    return Icon(
      switch (model) {
        AIModel.localRag => Icons.storage,
        AIModel.webSearch => Icons.search,
        AIModel.gemini => Icons.cloud,
      },
      size: 18,
    );
  }
}
