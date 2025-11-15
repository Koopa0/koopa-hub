import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/settings_provider.dart';
import '../../../core/constants/app_constants.dart';

/// 設定頁面
///
/// 功能：
/// - 伺服器 URL 配置
/// - Gemini API Key 設定
/// - 主題模式切換
/// - 關於資訊
class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(settingsProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: settingsAsync.when(
        data: (settings) => _buildContent(context, ref, settings),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('載入設定時發生錯誤：$error'),
        ),
      ),
    );
  }

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
          // 標題
          Row(
            children: [
              Icon(
                Icons.settings,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 12),
              Text(
                '設定',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 32),

          // 伺服器設定區塊
          _buildSection(
            context,
            title: '伺服器設定',
            icon: Icons.dns,
            child: _ServerSettings(settings: settings),
          ),

          const SizedBox(height: 24),

          // AI 模型設定
          _buildSection(
            context,
            title: 'AI 模型設定',
            icon: Icons.psychology,
            child: _AIModelSettings(settings: settings),
          ),

          const SizedBox(height: 24),

          // 外觀設定
          _buildSection(
            context,
            title: '外觀',
            icon: Icons.palette,
            child: _AppearanceSettings(settings: settings),
          ),

          const SizedBox(height: 24),

          // 關於
          _buildSection(
            context,
            title: '關於',
            icon: Icons.info,
            child: const _AboutSection(),
          ),
        ],
      ),
    );
  }

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

/// 伺服器設定
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
    _urlController = TextEditingController(text: widget.settings.serverUrl);
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final serverStatus = ref.watch(serverStatusProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
        Row(
          children: [
            FilledButton.icon(
              onPressed: () {
                ref.read(serverStatusProvider.notifier).checkConnection();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('測試連接'),
            ),
            const SizedBox(width: 12),
            serverStatus.when(
              data: (isConnected) => Row(
                children: [
                  Icon(
                    isConnected ? Icons.check_circle : Icons.error,
                    color: isConnected ? Colors.green : Colors.red,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isConnected ? '連接成功' : '連接失敗',
                    style: TextStyle(
                      color: isConnected ? Colors.green : Colors.red,
                    ),
                  ),
                ],
              ),
              loading: () => const CircularProgressIndicator(),
              error: (_, __) => const Text('檢查失敗'),
            ),
          ],
        ),
      ],
    );
  }
}

/// AI 模型設定
class _AIModelSettings extends ConsumerStatefulWidget {
  const _AIModelSettings({required this.settings});

  final AppSettings settings;

  @override
  ConsumerState<_AIModelSettings> createState() => _AIModelSettingsState();
}

class _AIModelSettingsState extends ConsumerState<_AIModelSettings> {
  late TextEditingController _apiKeyController;
  bool _obscureApiKey = true;

  @override
  void initState() {
    super.initState();
    _apiKeyController =
        TextEditingController(text: widget.settings.geminiApiKey);
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _apiKeyController,
          obscureText: _obscureApiKey,
          decoration: InputDecoration(
            labelText: 'Gemini API Key',
            hintText: '輸入您的 Gemini API Key',
            prefixIcon: const Icon(Icons.key),
            suffixIcon: IconButton(
              icon: Icon(
                _obscureApiKey ? Icons.visibility : Icons.visibility_off,
              ),
              onPressed: () {
                setState(() => _obscureApiKey = !_obscureApiKey);
              },
            ),
          ),
          onChanged: (value) {
            ref
                .read(settingsProvider.notifier)
                .updateGeminiApiKey(value.isEmpty ? null : value);
          },
        ),
        const SizedBox(height: 8),
        Text(
          '用於使用 Gemini (雲端) 模型。可在 Google AI Studio 獲取。',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
      ],
    );
  }
}

/// 外觀設定
class _AppearanceSettings extends ConsumerWidget {
  const _AppearanceSettings({required this.settings});

  final AppSettings settings;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '主題模式',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 12),
        SegmentedButton<ThemeMode>(
          selected: {settings.themeMode},
          onSelectionChanged: (Set<ThemeMode> selection) {
            ref
                .read(settingsProvider.notifier)
                .updateThemeMode(selection.first);
          },
          segments: const [
            ButtonSegment(
              value: ThemeMode.system,
              label: Text('系統'),
              icon: Icon(Icons.brightness_auto),
            ),
            ButtonSegment(
              value: ThemeMode.light,
              label: Text('淺色'),
              icon: Icon(Icons.light_mode),
            ),
            ButtonSegment(
              value: ThemeMode.dark,
              label: Text('深色'),
              icon: Icon(Icons.dark_mode),
            ),
          ],
        ),
      ],
    );
  }
}

/// 關於區塊
class _AboutSection extends StatelessWidget {
  const _AboutSection();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.psychology),
          title: Text(
            AppConstants.appName,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text('版本 ${AppConstants.appVersion}'),
        ),
        const Divider(),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.description),
          title: const Text('授權條款'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            // TODO: 顯示授權條款
          },
        ),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.code),
          title: const Text('原始碼'),
          subtitle: const Text('github.com/Koopa0/koopa-hub'),
          trailing: const Icon(Icons.open_in_new),
          onTap: () {
            // TODO: 開啟 GitHub
          },
        ),
      ],
    );
  }
}
