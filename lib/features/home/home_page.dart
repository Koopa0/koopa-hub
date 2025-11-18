import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../core/constants/app_constants.dart';
import 'dashboard_view.dart';
import '../chat/pages/chat_page.dart';
import '../chat/providers/chat_provider.dart';
import '../knowledge/pages/knowledge_page.dart';
import '../knowledge/providers/knowledge_provider.dart';
import '../knowledge/models/knowledge_document.dart';
import '../settings/pages/settings_page.dart';
import '../canvas/pages/canvas_page.dart';
import '../mindmap/pages/mindmap_page.dart';
import '../arena/pages/arena_page.dart';
import '../../core/utils/responsive.dart';
import '../../core/utils/keyboard_shortcuts.dart';
import '../../core/widgets/search_dialog.dart';
import '../../core/constants/design_tokens.dart';

/// Current app mode provider
final appModeProvider = StateProvider<String>((ref) => AppConstants.modeHome);

/// Sidebar expanded state provider
final sidebarExpandedProvider = StateProvider<bool>((ref) => true);

/// Main application page with new Gemini-style layout
///
/// Layout structure:
/// ┌──────┬────────┬──────────────────┐
/// │ Tool │Sidebar │  Center Stage    │
/// │ Bar  │(collap)│                  │
/// └──────┴────────┴──────────────────┘
class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentMode = ref.watch(appModeProvider);

    // 整合鍵盤快捷鍵
    return Shortcuts(
      shortcuts: {
        AppShortcuts.newChat: const _NewChatIntent(),
        AppShortcuts.search: const _SearchIntent(),
        AppShortcuts.settings: const _SettingsIntent(),
        AppShortcuts.help: const _HelpIntent(),
        AppShortcuts.page1: const _Page1Intent(),
        AppShortcuts.page2: const _Page2Intent(),
        AppShortcuts.page3: const _Page3Intent(),
      },
      child: Actions(
        actions: {
          _NewChatIntent: CallbackAction<_NewChatIntent>(
            onInvoke: (_) {
              ref.read(chatSessionsProvider.notifier).createSession();
              ref.read(appModeProvider.notifier).state = AppConstants.modeChat;
              return null;
            },
          ),
          _SearchIntent: CallbackAction<_SearchIntent>(
            onInvoke: (_) {
              SearchDialog.show(context);
              return null;
            },
          ),
          _SettingsIntent: CallbackAction<_SettingsIntent>(
            onInvoke: (_) {
              ref.read(appModeProvider.notifier).state = 'settings';
              return null;
            },
          ),
          _HelpIntent: CallbackAction<_HelpIntent>(
            onInvoke: (_) {
              ShortcutsHelpDialog.show(context);
              return null;
            },
          ),
          _Page1Intent: CallbackAction<_Page1Intent>(
            onInvoke: (_) {
              ref.read(appModeProvider.notifier).state = AppConstants.modeChat;
              return null;
            },
          ),
          _Page2Intent: CallbackAction<_Page2Intent>(
            onInvoke: (_) {
              ref.read(appModeProvider.notifier).state =
                  AppConstants.modeKnowledge;
              return null;
            },
          ),
          _Page3Intent: CallbackAction<_Page3Intent>(
            onInvoke: (_) {
              ref.read(appModeProvider.notifier).state =
                  AppConstants.modeCanvas;
              return null;
            },
          ),
        },
        child: Scaffold(
          body: Row(
            children: [
              // Left: Tool Selector Bar
              const _ToolBar(),

              // Middle: Collapsible Sidebar
              const _CollapsibleSidebar(),

              // Right: Center Stage (main content)
              Expanded(
                child: _CenterStage(mode: currentMode),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Tool selector bar (left-most)
class _ToolBar extends ConsumerWidget {
  const _ToolBar();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentMode = ref.watch(appModeProvider);
    final theme = Theme.of(context);

    return Container(
      width: AppConstants.toolbarWidth,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLowest,
        border: Border(
          right: BorderSide(
            color: theme.colorScheme.outlineVariant,
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          // App Logo
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.psychology_outlined,
                color: theme.colorScheme.onPrimaryContainer,
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Mode buttons
          _ModeButton(
            icon: Icons.dashboard_outlined,
            selectedIcon: Icons.dashboard,
            mode: AppConstants.modeHome,
            label: 'Home',
            isSelected: currentMode == AppConstants.modeHome,
            onTap: () => ref.read(appModeProvider.notifier).state =
                AppConstants.modeHome,
          ),

          _ModeButton(
            icon: Icons.chat_bubble_outline,
            selectedIcon: Icons.chat_bubble,
            mode: AppConstants.modeChat,
            label: 'Chat',
            isSelected: currentMode == AppConstants.modeChat,
            onTap: () => ref.read(appModeProvider.notifier).state =
                AppConstants.modeChat,
          ),

          _ModeButton(
            icon: Icons.account_tree_outlined,
            selectedIcon: Icons.account_tree,
            mode: AppConstants.modeMindMap,
            label: 'Mind Map',
            isSelected: currentMode == AppConstants.modeMindMap,
            onTap: () => ref.read(appModeProvider.notifier).state =
                AppConstants.modeMindMap,
          ),

          _ModeButton(
            icon: Icons.library_books_outlined,
            selectedIcon: Icons.library_books,
            mode: AppConstants.modeKnowledge,
            label: 'Knowledge',
            isSelected: currentMode == AppConstants.modeKnowledge,
            onTap: () => ref.read(appModeProvider.notifier).state =
                AppConstants.modeKnowledge,
          ),

          _ModeButton(
            icon: Icons.edit_note_outlined,
            selectedIcon: Icons.edit_note,
            mode: AppConstants.modeCanvas,
            label: 'Canvas',
            isSelected: currentMode == AppConstants.modeCanvas,
            onTap: () => ref.read(appModeProvider.notifier).state =
                AppConstants.modeCanvas,
          ),

          _ModeButton(
            icon: Icons.compare_outlined,
            selectedIcon: Icons.compare,
            mode: AppConstants.modeArena,
            label: 'Arena',
            isSelected: currentMode == AppConstants.modeArena,
            onTap: () => ref.read(appModeProvider.notifier).state =
                AppConstants.modeArena,
          ),

          const Spacer(),

          // Settings at bottom
          _ModeButton(
            icon: Icons.settings_outlined,
            selectedIcon: Icons.settings,
            mode: 'settings',
            label: 'Settings',
            isSelected: currentMode == 'settings',
            onTap: () =>
                ref.read(appModeProvider.notifier).state = 'settings',
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

/// Mode button widget
class _ModeButton extends StatelessWidget {
  const _ModeButton({
    required this.icon,
    required this.selectedIcon,
    required this.mode,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final IconData icon;
  final IconData selectedIcon;
  final String mode;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Tooltip(
      message: label,
      waitDuration: const Duration(milliseconds: 500),
      child: InkWell(
        onTap: onTap,
        child: Container(
          width: AppConstants.toolbarWidth,
          height: 56,
          decoration: BoxDecoration(
            color: isSelected
                ? theme.colorScheme.secondaryContainer.withOpacity(0.5)
                : Colors.transparent,
            border: Border(
              left: BorderSide(
                color: isSelected
                    ? theme.colorScheme.primary
                    : Colors.transparent,
                width: 3,
              ),
            ),
          ),
          child: Icon(
            isSelected ? selectedIcon : icon,
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

/// Collapsible sidebar for conversations/history
class _CollapsibleSidebar extends ConsumerWidget {
  const _CollapsibleSidebar();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isExpanded = ref.watch(sidebarExpandedProvider);
    final currentMode = ref.watch(appModeProvider);
    final theme = Theme.of(context);

    // Only show sidebar in certain modes
    final showSidebar = currentMode == AppConstants.modeChat ||
        currentMode == AppConstants.modeKnowledge ||
        currentMode == AppConstants.modeCanvas;

    if (!showSidebar) return const SizedBox.shrink();

    return AnimatedContainer(
      duration: AppConstants.mediumDuration,
      curve: Curves.easeInOutCubic,
      width: isExpanded
          ? AppConstants.sidebarWidthExpanded
          : AppConstants.sidebarWidthCollapsed,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLowest,
        border: Border(
          right: BorderSide(
            color: theme.colorScheme.outlineVariant,
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          // Header with toggle button
          _SidebarHeader(isExpanded: isExpanded),

          const Divider(height: 1),

          // Content based on mode
          Expanded(
            child: _getSidebarContent(currentMode, isExpanded),
          ),
        ],
      ),
    );
  }

  Widget _getSidebarContent(String mode, bool isExpanded) {
    return switch (mode) {
      AppConstants.modeChat => _ChatSidebarContent(isExpanded: isExpanded),
      AppConstants.modeKnowledge =>
        _KnowledgeSidebarContent(isExpanded: isExpanded),
      _ => const SizedBox.shrink(),
    };
  }
}

/// Sidebar header with toggle button
class _SidebarHeader extends ConsumerWidget {
  const _SidebarHeader({required this.isExpanded});

  final bool isExpanded;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: Row(
        children: [
          if (isExpanded)
            Expanded(
              child: Text(
                'Conversations',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          IconButton(
            icon: Icon(
              isExpanded ? Icons.chevron_left : Icons.chevron_right,
              size: 20,
            ),
            onPressed: () {
              ref.read(sidebarExpandedProvider.notifier).state = !isExpanded;
            },
            tooltip: isExpanded ? 'Collapse' : 'Expand',
          ),
        ],
      ),
    );
  }
}

/// Chat mode sidebar content (conversation list)
class _ChatSidebarContent extends ConsumerWidget {
  const _ChatSidebarContent({required this.isExpanded});

  final bool isExpanded;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessions = ref.watch(chatSessionsProvider);
    final currentSessionId = ref.watch(currentSessionIdProvider);
    final theme = Theme.of(context);

    if (!isExpanded) {
      // Collapsed view - just show icons
      return ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: sessions.length,
        itemBuilder: (context, index) {
          final session = sessions[index];
          final isSelected = session.id == currentSessionId;

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Tooltip(
              message: session.title,
              child: InkWell(
                onTap: () {
                  ref.read(currentSessionIdProvider.notifier).setSessionId(
                        session.id,
                      );
                },
                child: Container(
                  height: 40,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? theme.colorScheme.secondaryContainer.withOpacity(0.5)
                        : null,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.chat_bubble_outline,
                    size: 20,
                    color: isSelected
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ),
          );
        },
      );
    }

    // Expanded view - full conversation list
    return Column(
      children: [
        // New chat button
        Padding(
          padding: const EdgeInsets.all(12),
          child: ElevatedButton.icon(
            onPressed: () {
              ref.read(chatSessionsProvider.notifier).createSession();
            },
            icon: const Icon(Icons.add, size: 18),
            label: const Text('New Chat'),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 40),
            ),
          ),
        ),

        const Divider(height: 1),

        // Session list
        Expanded(
          child: sessions.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      'No conversations yet.\nStart a new chat!',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: sessions.length,
                  itemBuilder: (context, index) {
                    final session = sessions[index];
                    final isSelected = session.id == currentSessionId;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            ref
                                .read(currentSessionIdProvider.notifier)
                                .setSessionId(session.id);
                          },
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? theme.colorScheme.secondaryContainer
                                      .withOpacity(0.5)
                                  : null,
                              borderRadius: BorderRadius.circular(8),
                              border: isSelected
                                  ? Border.all(
                                      color: theme.colorScheme.primary
                                          .withOpacity(0.3),
                                      width: 1,
                                    )
                                  : null,
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.chat_bubble_outline,
                                  size: 18,
                                  color: isSelected
                                      ? theme.colorScheme.primary
                                      : theme.colorScheme.onSurfaceVariant,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        session.title,
                                        style:
                                            theme.textTheme.bodyMedium?.copyWith(
                                          fontWeight: isSelected
                                              ? FontWeight.w600
                                              : FontWeight.normal,
                                          color: isSelected
                                              ? theme.colorScheme.primary
                                              : theme.colorScheme.onSurface,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      if (session.messages.isNotEmpty) ...[
                                        const SizedBox(height: 2),
                                        Text(
                                          '${session.messages.length} messages',
                                          style: theme.textTheme.bodySmall
                                              ?.copyWith(
                                            color: theme
                                                .colorScheme.onSurfaceVariant,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                                // Delete button
                                IconButton(
                                  icon: Icon(
                                    Icons.delete_outline,
                                    size: 16,
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                  onPressed: () {
                                    ref
                                        .read(chatSessionsProvider.notifier)
                                        .deleteSession(session.id);
                                  },
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(
                                    minWidth: 32,
                                    minHeight: 32,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

/// Knowledge mode sidebar content (document list)
class _KnowledgeSidebarContent extends ConsumerWidget {
  const _KnowledgeSidebarContent({required this.isExpanded});

  final bool isExpanded;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final documents = ref.watch(knowledgeDocumentsProvider);
    final stats = ref.watch(knowledgeStatsProvider);
    final theme = Theme.of(context);

    if (!isExpanded) {
      // Collapsed view - just show document count
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.description_outlined,
              size: 24,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: 4),
            Text(
              '${stats.total}',
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.primary,
              ),
            ),
          ],
        ),
      );
    }

    // Expanded view - full document list with stats
    return Column(
      children: [
        // Stats summary
        Container(
          margin: const EdgeInsets.all(12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer.withOpacity(0.3),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _StatItem(
                icon: Icons.description,
                label: 'Total',
                value: stats.total.toString(),
                color: theme.colorScheme.primary,
              ),
              _StatItem(
                icon: Icons.check_circle,
                label: 'Indexed',
                value: stats.indexed.toString(),
                color: Colors.green,
              ),
              _StatItem(
                icon: Icons.hourglass_empty,
                label: 'Processing',
                value: stats.indexing.toString(),
                color: Colors.orange,
              ),
            ],
          ),
        ),

        const Divider(height: 1),

        // Document list
        Expanded(
          child: documents.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.folder_open,
                          size: 48,
                          color: theme.colorScheme.onSurfaceVariant
                              .withOpacity(0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No documents yet.\nAdd files to get started!',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: documents.length,
                  itemBuilder: (context, index) {
                    final doc = documents[index];

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceContainerHighest
                              .withOpacity(0.3),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            // Status icon
                            _getStatusIcon(doc.status, theme),
                            const SizedBox(width: 12),

                            // Document info
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    doc.name,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    _formatSize(doc.size),
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.colorScheme.onSurfaceVariant,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _getStatusIcon(DocumentStatus status, ThemeData theme) {
    return switch (status) {
      DocumentStatus.pending => Icon(
          Icons.pending_outlined,
          size: 18,
          color: theme.colorScheme.onSurfaceVariant,
        ),
      DocumentStatus.indexing => SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: Colors.orange,
          ),
        ),
      DocumentStatus.indexed => Icon(
          Icons.check_circle,
          size: 18,
          color: Colors.green,
        ),
      DocumentStatus.failed => Icon(
          Icons.error_outline,
          size: 18,
          color: Colors.red,
        ),
      DocumentStatus.deleted => Icon(
          Icons.delete_outline,
          size: 18,
          color: theme.colorScheme.onSurfaceVariant,
        ),
    };
  }

  String _formatSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}

/// Small stat display widget
class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
            Text(
              value,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            fontSize: 10,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

/// Center stage - main content area
class _CenterStage extends StatelessWidget {
  const _CenterStage({required this.mode});

  final String mode;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: AppConstants.mediumDuration,
      switchInCurve: Curves.easeInOutCubic,
      switchOutCurve: Curves.easeInOutCubic,
      child: _getContent(mode),
    );
  }

  Widget _getContent(String mode) {
    return switch (mode) {
      AppConstants.modeHome => const DashboardView(key: ValueKey('home')),
      AppConstants.modeChat => const ChatPage(key: ValueKey('chat')),
      AppConstants.modeMindMap => const MindMapPage(key: ValueKey('mindmap')),
      AppConstants.modeKnowledge =>
        const KnowledgePage(key: ValueKey('knowledge')),
      AppConstants.modeCanvas => const CanvasPage(key: ValueKey('canvas')),
      AppConstants.modeArena => const ArenaPage(key: ValueKey('arena')),
      'settings' => const SettingsPage(key: ValueKey('settings')),
      _ => _ComingSoonView(mode: mode, key: ValueKey(mode)),
    };
  }
}

/// Coming soon placeholder for unimplemented modes
class _ComingSoonView extends StatelessWidget {
  const _ComingSoonView({required this.mode, super.key});

  final String mode;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.construction_outlined,
            size: 80,
            color: theme.colorScheme.outlineVariant,
          ),
          const SizedBox(height: 24),
          Text(
            _getModeName(mode),
            style: theme.textTheme.headlineSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Coming soon...',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  String _getModeName(String mode) {
    return switch (mode) {
      AppConstants.modeMindMap => 'Mind Map Mode',
      AppConstants.modeCanvas => 'Canvas Mode',
      AppConstants.modeArena => 'Multi-Model Arena',
      AppConstants.modeAudio => 'Audio Overview',
      AppConstants.modeTools => 'MCP Tools',
      _ => 'Unknown Mode',
    };
  }
}

// 鍵盤快捷鍵 Intents
class _NewChatIntent extends Intent {
  const _NewChatIntent();
}

class _SearchIntent extends Intent {
  const _SearchIntent();
}

class _SettingsIntent extends Intent {
  const _SettingsIntent();
}

class _HelpIntent extends Intent {
  const _HelpIntent();
}

class _Page1Intent extends Intent {
  const _Page1Intent();
}

class _Page2Intent extends Intent {
  const _Page2Intent();
}

class _Page3Intent extends Intent {
  const _Page3Intent();
}
