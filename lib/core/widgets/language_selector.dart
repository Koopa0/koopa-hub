import 'package:flutter/material.dart';

/// 支援的語言
class SupportedLanguage {
  const SupportedLanguage({
    required this.code,
    required this.name,
    required this.nativeName,
    required this.locale,
  });

  final String code;
  final String name;
  final String nativeName;
  final Locale locale;
}

/// 支援的語言列表
class SupportedLanguages {
  static const languages = [
    SupportedLanguage(
      code: 'en',
      name: 'English',
      nativeName: 'English',
      locale: Locale('en', ''),
    ),
    SupportedLanguage(
      code: 'zh_TW',
      name: 'Traditional Chinese',
      nativeName: '繁體中文',
      locale: Locale('zh', 'TW'),
    ),
  ];

  static SupportedLanguage getLanguage(Locale locale) {
    return languages.firstWhere(
      (lang) => lang.locale == locale,
      orElse: () => languages.first,
    );
  }
}

/// 語言選擇器
class LanguageSelector extends StatelessWidget {
  const LanguageSelector({
    required this.currentLocale,
    required this.onLanguageChanged,
    super.key,
  });

  final Locale currentLocale;
  final ValueChanged<Locale> onLanguageChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentLanguage = SupportedLanguages.getLanguage(currentLocale);

    return Card(
      child: Column(
        children: [
          // 標題
          ListTile(
            leading: const Icon(Icons.language),
            title: Text(
              '語言 / Language',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const Divider(height: 1),

          // 語言選項
          ...SupportedLanguages.languages.map((language) {
            final isSelected = language.code == currentLanguage.code;

            return RadioListTile<String>(
              value: language.code,
              groupValue: currentLanguage.code,
              onChanged: (_) => onLanguageChanged(language.locale),
              title: Row(
                children: [
                  Text(language.nativeName),
                  const SizedBox(width: 8),
                  Text(
                    language.name,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              selected: isSelected,
            );
          }),
        ],
      ),
    );
  }
}
