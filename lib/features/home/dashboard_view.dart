import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_constants.dart';
import 'home_page.dart';

/// Dashboard view - Home mode
///
/// Displays quick actions, recent conversations, and statistics
/// Gemini-style center layout
class DashboardView extends ConsumerWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Container(
      color: theme.colorScheme.surface,
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: AppConstants.maxContentWidth,
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Welcome Header
                _buildWelcomeHeader(theme),

                const SizedBox(height: 48),

                // Quick Actions Grid
                _buildQuickActions(context, ref, theme),

                const SizedBox(height: 48),

                // Recent Activity
                _buildRecentActivity(theme),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeHeader(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          Icons.psychology,
          size: 48,
          color: theme.colorScheme.primary,
        ),
        const SizedBox(height: 16),
        Text(
          'Welcome to Koopa Assistant',
          style: theme.textTheme.headlineLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Your personal AI-powered assistant for coding, research, and creativity',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions(
    BuildContext context,
    WidgetRef ref,
    ThemeData theme,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 2.5,
          children: [
            _QuickActionCard(
              icon: Icons.chat_bubble_outline,
              title: 'New Chat',
              subtitle: 'Start a conversation',
              color: theme.colorScheme.primaryContainer,
              onTap: () {
                ref.read(appModeProvider.notifier).state =
                    AppConstants.modeChat;
              },
            ),
            _QuickActionCard(
              icon: Icons.library_add_outlined,
              title: 'Add Knowledge',
              subtitle: 'Index documents',
              color: theme.colorScheme.secondaryContainer,
              onTap: () {
                ref.read(appModeProvider.notifier).state =
                    AppConstants.modeKnowledge;
              },
            ),
            _QuickActionCard(
              icon: Icons.compare_outlined,
              title: 'Model Arena',
              subtitle: 'Compare AI models',
              color: theme.colorScheme.tertiaryContainer,
              onTap: () {
                ref.read(appModeProvider.notifier).state =
                    AppConstants.modeArena;
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRecentActivity(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Activity',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Center(
              child: Column(
                children: [
                  Icon(
                    Icons.history,
                    size: 48,
                    color: theme.colorScheme.outlineVariant,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No recent activity',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Start a conversation or add documents to see activity here',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Quick action card widget
class _QuickActionCard extends StatelessWidget {
  const _QuickActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: theme.colorScheme.onPrimaryContainer,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
