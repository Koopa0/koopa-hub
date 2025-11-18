import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../core/constants/app_constants.dart';
import 'dashboard_view.dart';
import '../chat/pages/chat_page.dart';
import '../knowledge/pages/knowledge_page.dart';
import '../settings/pages/settings_page.dart';
import '../../core/utils/responsive.dart';

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

    return Scaffold(
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
class _ChatSidebarContent extends StatelessWidget {
  const _ChatSidebarContent({required this.isExpanded});

  final bool isExpanded;

  @override
  Widget build(BuildContext context) {
    // TODO: Implement conversation list
    return Center(
      child: Text(isExpanded ? 'Conversations' : ''),
    );
  }
}

/// Knowledge mode sidebar content (document list)
class _KnowledgeSidebarContent extends StatelessWidget {
  const _KnowledgeSidebarContent({required this.isExpanded});

  final bool isExpanded;

  @override
  Widget build(BuildContext context) {
    // TODO: Implement document list
    return Center(
      child: Text(isExpanded ? 'Documents' : ''),
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
      AppConstants.modeKnowledge =>
        const KnowledgePage(key: ValueKey('knowledge')),
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
