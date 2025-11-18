import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/settings_provider.dart';
import '../../../core/constants/app_constants.dart';

/// Settings Page - Application configuration
///
/// **Purpose:**
/// Central location for all app settings:
/// - Koopa Server URL configuration
/// - Gemini API Key management
/// - Theme mode selection (light/dark/system)
/// - About information
///
/// **Flutter 3.38 Features Used:**
/// - AsyncValue pattern for loading states
/// - Material 3 SegmentedButton (new widget)
/// - Updated TextField styling
/// - Card with proper elevation
///
/// **Dart 3.10 Best Practices:**
/// - ConsumerWidget + ConsumerStatefulWidget
/// - Proper TextEditingController disposal
/// - when() pattern for async state
class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    /// Watch async settings
    ///
    /// **AsyncValue Pattern:**
    /// Handles three states automatically:
    /// - data: Settings loaded successfully
    /// - loading: Still fetching from storage
    /// - error: Failed to load settings
    final settingsAsync = ref.watch(settingsProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,

      /// AsyncValue.when()
      ///
      /// **Pattern:**
      /// Maps async state to widgets
      ///
      /// **Benefits:**
      /// - Exhaustive handling (compiler ensures all cases covered)
      /// - Type-safe data access
      /// - Clean separation of loading/error/success states
      body: settingsAsync.when(
        // Success: Display settings UI
        data: (settings) => _buildContent(context, ref, settings),

        // Loading: Show spinner
        loading: () => const Center(child: CircularProgressIndicator()),

        // Error: Display error message
        error: (error, stack) => Center(
          child: Text('Error loading settings: $error'),
        ),
      ),
    );
  }

  /// Build main content with settings sections
  ///
  /// **Layout:**
  /// ScrollView with sections for:
  /// - Server configuration
  /// - AI model settings
  /// - Appearance
  /// - About
  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    AppSettings settings,
  ) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Page Title
          Row(
            children: [
              Icon(
                Icons.settings,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 12),
              Text(
                'Settings',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 32),

          // Server Settings Section
          _buildSection(
            context,
            title: 'Server Settings',
            icon: Icons.dns,
            child: _ServerSettings(settings: settings),
          ),

          const SizedBox(height: 24),

          // AI Model Settings Section
          _buildSection(
            context,
            title: 'AI Model Settings',
            icon: Icons.psychology,
            child: _AIModelSettings(settings: settings),
          ),

          const SizedBox(height: 24),

          // Appearance Section
          _buildSection(
            context,
            title: 'Appearance',
            icon: Icons.palette,
            child: _AppearanceSettings(settings: settings),
          ),

          const SizedBox(height: 24),

          // About Section
          _buildSection(
            context,
            title: 'About',
            icon: Icons.info,
            child: const _AboutSection(),
          ),
        ],
      ),
    );
  }

  /// Build settings section
  ///
  /// **Pattern:**
  /// Reusable section container with:
  /// - Icon + Title header
  /// - Card with content
  ///
  /// **Material 3:**
  /// Uses Card for elevated surface
  Widget _buildSection(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// Section Header
        Row(
          children: [
            Icon(icon, size: 20, color: theme.colorScheme.primary),
            const SizedBox(width: 8),
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        /// Content Card
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: child,
          ),
        ),
      ],
    );
  }
}

/// Server Settings - Koopa server configuration
///
/// **Features:**
/// - URL input field
/// - Connection test button
/// - Real-time connection status
///
/// **StatefulWidget:**
/// Needs TextEditingController (local state)
class _ServerSettings extends ConsumerStatefulWidget {
  const _ServerSettings({required this.settings});

  final AppSettings settings;

  @override
  ConsumerState<_ServerSettings> createState() => _ServerSettingsState();
}

class _ServerSettingsState extends ConsumerState<_ServerSettings> {
  late TextEditingController _urlController;

  @override
  void initState() {
    super.initState();
    // Initialize controller with current server URL
    _urlController = TextEditingController(text: widget.settings.serverUrl);
  }

  @override
  void dispose() {
    /// Clean up controller
    ///
    /// **Critical:**
    /// TextEditingController must be disposed
    /// to prevent memory leaks
    _urlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Watch server connection status (async)
    final serverStatus = ref.watch(serverStatusProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// URL Input Field
        ///
        /// **Material 3 TextField:**
        /// - labelText: Floating label
        /// - hintText: Placeholder when empty
        /// - prefixIcon: Icon before text
        ///
        /// **onChanged:**
        /// Updates settings in real-time as user types
        TextField(
          controller: _urlController,
          decoration: const InputDecoration(
            labelText: 'Koopa Server URL',
            hintText: 'http://localhost:8080',
            prefixIcon: Icon(Icons.link),
          ),
          onChanged: (value) {
            ref.read(settingsProvider.notifier).updateServerUrl(value);
          },
        ),

        const SizedBox(height: 16),

        /// Test Connection Row
        ///
        /// **Layout:**
        /// Button | Status Indicator
        Row(
          children: [
            // Test button
            FilledButton.icon(
              onPressed: () {
                ref.read(serverStatusProvider.notifier).checkConnection();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Test Connection'),
            ),

            const SizedBox(width: 12),

            /// Connection Status
            ///
            /// **AsyncValue.when():**
            /// Handles loading/success/error states
            serverStatus.when(
              // Connected/disconnected
              data: (isConnected) => Row(
                children: [
                  Icon(
                    isConnected ? Icons.check_circle : Icons.error,
                    color: isConnected ? Colors.green : Colors.red,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isConnected ? 'Connected' : 'Connection Failed',
                    style: TextStyle(
                      color: isConnected ? Colors.green : Colors.red,
                    ),
                  ),
                ],
              ),

              // Testing connection
              loading: () => const CircularProgressIndicator(),

              // Check failed (error)
              error: (_, __) => const Text('Check Failed'),
            ),
          ],
        ),
      ],
    );
  }
}

/// AI Model Settings - API key configuration
///
/// **Features:**
/// - Gemini API Key input
/// - Show/hide password toggle
/// - Helper text with link to API console
///
/// **Security:**
/// Uses obscureText for API key privacy
class _AIModelSettings extends ConsumerStatefulWidget {
  const _AIModelSettings({required this.settings});

  final AppSettings settings;

  @override
  ConsumerState<_AIModelSettings> createState() => _AIModelSettingsState();
}

class _AIModelSettingsState extends ConsumerState<_AIModelSettings> {
  late TextEditingController _apiKeyController;

  /// Password visibility toggle
  ///
  /// **Local State:**
  /// Only this widget needs to know if key is visible
  /// No need to store in global state
  bool _obscureApiKey = true;

  @override
  void initState() {
    super.initState();
    // Initialize with existing API key (if set)
    _apiKeyController =
        TextEditingController(text: widget.settings.geminiApiKey);
  }

  @override
  void dispose() {
    // Clean up controller
    _apiKeyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// API Key Input
        ///
        /// **obscureText:**
        /// Hides characters (like password field)
        /// Toggled by suffixIcon button
        ///
        /// **suffixIcon:**
        /// Button to show/hide API key
        TextField(
          controller: _apiKeyController,
          obscureText: _obscureApiKey,
          decoration: InputDecoration(
            labelText: 'Gemini API Key',
            hintText: 'Enter your Gemini API Key',
            prefixIcon: const Icon(Icons.key),

            /// Show/Hide Toggle
            ///
            /// **Pattern:**
            /// Icon changes based on state
            /// - visibility_off: Currently hidden
            /// - visibility: Currently shown
            suffixIcon: IconButton(
              icon: Icon(
                _obscureApiKey ? Icons.visibility : Icons.visibility_off,
              ),
              onPressed: () {
                setState(() => _obscureApiKey = !_obscureApiKey);
              },
            ),
          ),

          /// Update on change
          ///
          /// **Null handling:**
          /// Empty string converted to null
          /// (API key is optional)
          onChanged: (value) {
            ref
                .read(settingsProvider.notifier)
                .updateGeminiApiKey(value.isEmpty ? null : value);
          },
        ),

        const SizedBox(height: 8),

        /// Helper Text
        ///
        /// **Purpose:**
        /// Explains what this setting is for
        /// and where to get an API key
        Text(
          'Required for Gemini (Cloud) model. Get your key from Google AI Studio.',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
      ],
    );
  }
}

/// Appearance Settings - Theme mode selection
///
/// **Features:**
/// - System/Light/Dark mode toggle
/// - Material 3 SegmentedButton (new widget)
class _AppearanceSettings extends ConsumerWidget {
  const _AppearanceSettings({required this.settings});

  final AppSettings settings;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Theme Mode',
          style: Theme.of(context).textTheme.titleSmall,
        ),

        const SizedBox(height: 12),

        /// Material 3 SegmentedButton
        ///
        /// **New in Flutter 3.10+, improved in 3.38:**
        /// Replaces older ToggleButtons with better UX
        ///
        /// **Features:**
        /// - Single selection mode
        /// - Icon + label support
        /// - Proper Material 3 styling
        /// - Better touch targets
        ///
        /// **Pattern:**
        /// - selected: Set<T> of selected values
        /// - onSelectionChanged: Callback with new selection
        /// - segments: List of button configurations
        ///
        /// **Type Safety:**
        /// Generic <ThemeMode> ensures compile-time type checking
        SegmentedButton<ThemeMode>(
          // Currently selected theme
          selected: {settings.themeMode},

          /// Selection callback
          ///
          /// **Set Parameter:**
          /// Even though single-select, uses Set for consistency
          /// with multi-select mode
          onSelectionChanged: (Set<ThemeMode> selection) {
            ref
                .read(settingsProvider.notifier)
                .updateThemeMode(selection.first);
          },

          /// Button Segments
          ///
          /// **Each segment:**
          /// - value: Enum value
          /// - label: Display text
          /// - icon: Visual indicator
          segments: const [
            ButtonSegment(
              value: ThemeMode.system,
              label: Text('System'),
              icon: Icon(Icons.brightness_auto),
            ),
            ButtonSegment(
              value: ThemeMode.light,
              label: Text('Light'),
              icon: Icon(Icons.light_mode),
            ),
            ButtonSegment(
              value: ThemeMode.dark,
              label: Text('Dark'),
              icon: Icon(Icons.dark_mode),
            ),
          ],
        ),
      ],
    );
  }
}

/// About Section - App information
///
/// **Content:**
/// - App name and version
/// - License information
/// - Source code link
class _AboutSection extends StatelessWidget {
  const _AboutSection();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// App Info
        ///
        /// **ListTile:**
        /// Material component for list items with:
        /// - leading: Icon
        /// - title: Main text
        /// - subtitle: Secondary text
        ///
        /// **contentPadding: EdgeInsets.zero:**
        /// Removes default padding (already in Card)
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.psychology),
          title: Text(
            AppConstants.appName,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text('Version ${AppConstants.appVersion}'),
        ),

        const Divider(),

        /// License Link
        ///
        /// **TODO:**
        /// Should open license dialog or web page
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.description),
          title: const Text('License'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            // TODO: Show license dialog
          },
        ),

        /// Source Code Link
        ///
        /// **TODO:**
        /// Should open GitHub in browser
        ///
        /// **Icon:**
        /// open_in_new indicates external link
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.code),
          title: const Text('Source Code'),
          subtitle: const Text('github.com/Koopa0/koopa-hub'),
          trailing: const Icon(Icons.open_in_new),
          onTap: () {
            // TODO: Open GitHub URL
          },
        ),
      ],
    );
  }
}
