import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qfqq/common/providers/locale_provider.dart';
import 'package:qfqq/generated/l10n.dart';

class LanguageSettingsCard extends ConsumerWidget {
  const LanguageSettingsCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final loc = S.of(context);
    final currentLocale = ref.watch(localeProvider);
    final isFr = currentLocale.languageCode == 'fr';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          loc.profilePageLanguage,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: theme.primaryColor,
          ),
        ),
        const SizedBox(height: 16),
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: theme.colorScheme.outlineVariant.withAlpha(120),
            ),
          ),
          color: theme.colorScheme.surface,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _LanguageOptionTile(
                  label: loc.profilePageLanguageEnglish,
                  isSelected: !isFr,
                  onTap:
                      () => ref
                          .read(localeProvider.notifier)
                          .setLocale(const Locale('en')),
                ),
                const SizedBox(height: 10),
                _LanguageOptionTile(
                  label: loc.profilePageLanguageFrench,
                  isSelected: isFr,
                  onTap:
                      () => ref
                          .read(localeProvider.notifier)
                          .setLocale(const Locale('fr')),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _LanguageOptionTile extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _LanguageOptionTile({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color:
          isSelected
              ? theme.colorScheme.primaryContainer
              : theme.colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(
          color:
              isSelected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.outlineVariant.withAlpha(150),
          width: isSelected ? 1.5 : 1.0,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color:
                    isSelected
                        ? theme.colorScheme.onPrimaryContainer
                        : theme.colorScheme.onSurface,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
