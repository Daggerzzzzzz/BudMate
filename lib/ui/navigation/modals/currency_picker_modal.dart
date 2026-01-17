import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants.dart';
import '../../../core/managers/navigation_manager.dart';
import '../../../l10n/app_localizations.dart';
import '../../../services/preferences_service.dart';
import '../../shared/base_modal.dart';
import '../../shared/modal_text_button.dart';

/// Currency picker modal following established BaseModal pattern.
///
/// Displays list of supported currencies with their symbols for user selection.
/// Updates PreferencesService immediately upon selection and persists to SharedPreferences.
///
/// Supported currencies: PHP, USD, EUR, JPY, GBP
///
/// Pattern:
/// - StatefulWidget with static show() method
/// - Returns BaseModal with title, titleIcon, content, and actions
/// - Uses NavigationManager for modal dismissal
/// - Consistent with AddBudgetModal, PayExpensesModal structure
class CurrencyPickerModal extends StatefulWidget {
  final String currentCurrency;

  const CurrencyPickerModal({super.key, required this.currentCurrency});

  /// Show currency picker modal.
  ///
  /// Returns selected currency code or null if cancelled.
  static Future<String?> show(BuildContext context, {required String currentCurrency}) {
    return BaseModal.show<String>(
      context: context,
      child: CurrencyPickerModal(currentCurrency: currentCurrency),
    );
  }

  @override
  State<CurrencyPickerModal> createState() => _CurrencyPickerModalState();
}

class _CurrencyPickerModalState extends State<CurrencyPickerModal> {
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
      title: l10n.selectCurrency,
      titleIcon: Icons.attach_money,
      content: _buildCurrencyList(),
      actions: _buildActions(),
    );
  }

  /// Build list of currency options with symbols and selection indicators.
  Widget _buildCurrencyList() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: SupportedCurrencies.all.map((currency) {
        final symbol = SupportedCurrencies.symbols[currency] ?? '';
        final isSelected = currency == widget.currentCurrency;

        return ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Text(
            symbol,
            style: const TextStyle(fontSize: 24),
          ),
          title: Text(currency),
          trailing: isSelected
              ? Icon(Icons.check, color: Theme.of(context).colorScheme.primary)
              : null,
          onTap: () => _handleCurrencySelected(currency),
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

  /// Handle currency selection - update preferences and close modal.
  Future<void> _handleCurrencySelected(String currency) async {
    await _prefsService.setCurrency(currency);
    if (mounted) {
      NavigationManager.closeModal(context, currency);
    }
  }
}
