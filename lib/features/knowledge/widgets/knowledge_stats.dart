import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/knowledge_provider.dart';

/// Knowledge Base Statistics - Overview metrics
///
/// **Purpose:**
/// Displays at-a-glance summary of knowledge base status:
/// - Total documents
/// - Indexed (ready for use)
/// - Indexing (in progress)
/// - Failed (errors)
///
/// **Flutter 3.38 Features:**
/// - Material 3 Card with updated styling
/// - ColorScheme-based theming
///
/// **Layout:**
/// Row of 4 equal-width stat cards
class KnowledgeStats extends ConsumerWidget {
  const KnowledgeStats({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch stats - rebuilds when any count changes
    final stats = ref.watch(knowledgeStatsProvider);
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),

      /// Row of Stat Cards
      ///
      /// **Layout:**
      /// Each card is Expanded (equal width)
      /// Spacing between cards: 12px
      child: Row(
        children: [
          // Total documents
          Expanded(
            child: _StatCard(
              icon: Icons.description,
              label: 'Total',
              value: '${stats.total}',
              color: theme.colorScheme.primary,
            ),
          ),

          const SizedBox(width: 12),

          // Successfully indexed
          Expanded(
            child: _StatCard(
              icon: Icons.check_circle,
              label: 'Indexed',
              value: '${stats.indexed}',
              color: Colors.green, // Success color
            ),
          ),

          const SizedBox(width: 12),

          // Currently indexing
          Expanded(
            child: _StatCard(
              icon: Icons.sync,
              label: 'Indexing',
              value: '${stats.indexing}',
              color: Colors.blue, // In-progress color
            ),
          ),

          const SizedBox(width: 12),

          // Failed indexing
          Expanded(
            child: _StatCard(
              icon: Icons.error,
              label: 'Failed',
              value: '${stats.failed}',
              color: theme.colorScheme.error, // Error color
            ),
          ),
        ],
      ),
    );
  }
}

/// Stat Card - Individual metric display
///
/// **Design Pattern:**
/// Vertical layout: Icon → Value → Label
///
/// **Material 3:**
/// Uses Card for elevated surface
///
/// **Color Coding:**
/// Each metric has semantic color:
/// - Primary: Total count
/// - Green: Success
/// - Blue: In progress
/// - Error: Failure
class _StatCard extends StatelessWidget {
  const _StatCard({
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

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),

        /// Vertical Stack
        ///
        /// **Layout:**
        /// Icon (32px, colored)
        ///   ↓
        /// Value (large, bold, colored)
        ///   ↓
        /// Label (small, de-emphasized)
        child: Column(
          children: [
            // Icon (colored for visual distinction)
            Icon(icon, color: color, size: 32),

            const SizedBox(height: 8),

            /// Value
            ///
            /// **Typography:**
            /// headlineMedium: Large, prominent number
            /// Bold weight: Emphasizes the metric
            /// Colored: Matches icon for visual consistency
            Text(
              value,
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),

            const SizedBox(height: 4),

            /// Label
            ///
            /// **Typography:**
            /// bodySmall: Smaller descriptive text
            /// onSurfaceVariant: De-emphasized color
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
