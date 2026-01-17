import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants.dart';
import '../../../core/managers/navigation_manager.dart';
import '../../../l10n/app_localizations.dart';
import '../../../services/preferences_service.dart';
import '../../shared/base_modal.dart';
import '../../shared/modal_text_button.dart';

/// Language picker modal following established BaseModal pattern.
///
/// Displays list of supported languages for user selection.
/// Updates PreferencesService immediately upon selection and persists to SharedPreferences.
///
/// Supported languages: English, Filipino
///
/// Note: For MVP, UI remains in English. This stores preference for future l10n.
///
/// Pattern:
/// - StatefulWidget with static show() method
/// - Returns BaseModal with title, titleIcon, content, and actions
/// - Uses NavigationManager for modal dismissal
/// - Consistent with AddBudgetModal, PayExpensesModal structure
class LanguagePickerModal extends StatefulWidget {
  final String currentLanguage;

  const LanguagePickerModal({super.key, required this.currentLanguage});

  /// Show language picker modal.
  ///
  /// Returns selected language code or null if cancelled.
  static Future<String?> show(BuildContext context, {required String currentLanguage}) {
    return BaseModal.show<String>(
      context: context,
      child: LanguagePickerModal(currentLanguage: currentLanguage),
    );
  }

  @override
  State<LanguagePickerModal> createState() => _LanguagePickerModalState();
}

class _LanguagePickerModalState extends State<LanguagePickerModal> {
  late PreferencesService _prefsService;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _prefsService = context.read<PreferencesService>();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BaseModal(
      title: l10n.selectLanguage,
      titleIcon: Icons.language,
      content: _buildLanguageList(),
      actions: _buildActions(),
    );
  }

  /// Build list of language options with names and selection indicators.
  Widget _buildLanguageList() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: SupportedLanguages.all.map((language) {
        final languageName = SupportedLanguages.names[language] ?? language;
        final isSelected = language == widget.currentLanguage;

        return ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(languageName),
          trailing: isSelected
              ? Icon(Icons.check, color: Theme.of(context).colorScheme.primary)
              : null,
          onTap: () => _handleLanguageSelected(language),
        );
      }).toList(),
    );
  }

  /// Build action buttons (Cancel).
  List<Widget> _buildActions() {
    final l10n = AppLocalizations.of(context)!;

    return [
      ModalTextButton(
        text: l10n.cancel,
        onPressed: () => NavigationManager.closeModal(context),
      ),
    ];
  }

  /// Handle language selection - update preferences and close modal.
  Future<void> _handleLanguageSelected(String language) async {
    await _prefsService.setLanguage(language);
    if (mounted) {
      NavigationManager.closeModal(context, language);
    }
  }
}
