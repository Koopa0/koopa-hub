import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// Source citation data model
class SourceCitation {
  final String title;
  final String url;
  final String? snippet;
  final String? favicon;
  final int? citationNumber;

  const SourceCitation({
    required this.title,
    required this.url,
    this.snippet,
    this.favicon,
    this.citationNumber,
  });
}

/// Source card widget for displaying web search results
/// Inspired by Perplexity and Gemini's citation cards
class SourceCard extends StatelessWidget {
  const SourceCard({
    super.key,
    required this.source,
    this.compact = false,
  });

  final SourceCitation source;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (compact) {
      return _buildCompactCard(context, theme);
    }

    return _buildFullCard(context, theme);
  }

  Widget _buildFullCard(BuildContext context, ThemeData theme) {
    return InkWell(
      onTap: () => _launchUrl(source.url),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: theme.colorScheme.outlineVariant.withOpacity(0.5),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with favicon and citation number
            Row(
              children: [
                // Citation number badge
                if (source.citationNumber != null) ...[
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${source.citationNumber}',
                        style: theme.textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],

                // Favicon or default icon
                if (source.favicon != null)
                  Image.network(
                    source.favicon!,
                    width: 16,
                    height: 16,
                    errorBuilder: (_, __, ___) => Icon(
                      Icons.language,
                      size: 16,
                      color: theme.colorScheme.primary,
                    ),
                  )
                else
                  Icon(
                    Icons.language,
                    size: 16,
                    color: theme.colorScheme.primary,
                  ),

                const SizedBox(width: 8),

                // Domain
                Expanded(
                  child: Text(
                    _extractDomain(source.url),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

                // External link icon
                Icon(
                  Icons.open_in_new,
                  size: 14,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Title
            Text(
              source.title,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),

            // Snippet
            if (source.snippet != null) ...[
              const SizedBox(height: 6),
              Text(
                source.snippet!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCompactCard(BuildContext context, ThemeData theme) {
    return InkWell(
      onTap: () => _launchUrl(source.url),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: theme.colorScheme.outlineVariant.withOpacity(0.5),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Citation number
            if (source.citationNumber != null) ...[
              Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '${source.citationNumber}',
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 6),
            ],

            // Domain
            Flexible(
              child: Text(
                _extractDomain(source.url),
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),

            const SizedBox(width: 4),

            // External link icon
            Icon(
              Icons.open_in_new,
              size: 12,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }

  String _extractDomain(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.host.replaceFirst('www.', '');
    } catch (e) {
      return url;
    }
  }

  Future<void> _launchUrl(String urlString) async {
    final url = Uri.parse(urlString);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }
}

/// Widget to display multiple source citations
class SourcesGrid extends StatelessWidget {
  const SourcesGrid({
    super.key,
    required this.sources,
    this.compact = false,
  });

  final List<SourceCitation> sources;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    if (sources.isEmpty) return const SizedBox.shrink();

    if (compact) {
      return Wrap(
        spacing: 6,
        runSpacing: 6,
        children: sources
            .map((source) => SourceCard(source: source, compact: true))
            .toList(),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: sources.map((source) => SourceCard(source: source)).toList(),
    );
  }
}
