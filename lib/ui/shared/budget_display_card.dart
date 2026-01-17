/// Reusable budget display card component.
///
/// Shows a styled container with a label and formatted amount value.
/// Used by Add Budget and Pay Expenses modals for consistent UI across the app.
///
/// Design features:
/// - Responsive layout with Flexible wrapper to prevent text overflow
/// - Consistent 12px padding matching app design system
/// - Theme-aware colors using primaryContainer background
/// - Formatted currency display via UIManager.formatAmount()
///
/// Example:
/// ```dart
/// BudgetDisplayCard(
///   label: 'Current Budget',
///   amount: 10000.00,
/// )
/// ```
library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:budmate/core/managers/ui_manager.dart';
import 'package:budmate/services/preferences_service.dart';

class BudgetDisplayCard extends StatelessWidget {
  final String label;
  final double amount;

  const BudgetDisplayCard({
    super.key,
    required this.label,
    required this.amount,
  });

  @override
  Widget build(BuildContext context) {
    final currencySymbol = context.watch<PreferencesService>().currencySymbol;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            UIManager.formatAmount(amount, currencySymbol: currencySymbol),
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
          ),
        ],
      ),
    );
  }
}
