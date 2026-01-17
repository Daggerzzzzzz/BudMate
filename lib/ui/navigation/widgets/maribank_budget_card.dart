/// Maribank-style budget card with integrated action buttons using dynamic UI design.
///
/// Features gradient background, available budget display with UI-only show/hide toggle,
/// and integrated action buttons for budget and expense management. Uses 80:20 ratio
/// (Available Budget : Action Buttons) with NO hardcoded pixel values - all dimensions
/// are relative to screen size for responsive design across different devices.
///
/// Key responsibilities:
/// - Display available budget amount with color-coded formatting (80% of card height)
/// - Toggle budget visibility with eye icon (shows dash lines when hidden, UI-only, not persisted)
/// - Render subtle gradient line separator between sections
/// - Provide two action buttons (Budget and Expenses) with + icons (20% of card height)
/// - Handle loading states gracefully
/// - Use dynamic sizing - MediaQuery percentages, Expanded widgets, Spacer for flexibility
library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:budmate/domain/budget_health_result.dart';
import 'package:budmate/core/managers/ui_manager.dart';
import 'package:budmate/services/preferences_service.dart';

class MaribankBudgetCard extends StatelessWidget {
  final BudgetHealthResult? budgetHealth;
  final bool isBudgetVisible;
  final VoidCallback onToggleVisibility;
  final VoidCallback onAddBudget;
  final VoidCallback onPayExpense;

  const MaribankBudgetCard({
    super.key,
    required this.budgetHealth,
    required this.isBudgetVisible,
    required this.onToggleVisibility,
    required this.onAddBudget,
    required this.onPayExpense,
  });

  @override
  Widget build(BuildContext context) {
    // Use LayoutBuilder to get constraints instead of MediaQuery
    // This prevents rebuild cascades from MediaQuery dependency
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        // Cache Theme.of(context) to avoid multiple lookups
        final theme = Theme.of(context);
        final primaryColor = theme.colorScheme.primary;
        final currencySymbol = context.watch<PreferencesService>().currencySymbol;

        return Container(
          // Use aspect ratio instead of fixed screenHeight percentage
          height: constraints.maxWidth * 0.55,  // Reduced from 0.65 to decrease Available Budget space
          margin: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.04,  // 4% screen width
            vertical: screenWidth * 0.04,  // 4% screen width for consistency
          ),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                primaryColor,
                primaryColor.withValues(alpha: 0.8),
              ],
            ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
          ),
          child: Stack(
            children: [
              // Background wallet icon decoration
              Positioned(
                top: 4,  // Top-right position with small margin
                right: 5,
                child: Icon(
                  Icons.account_balance_wallet,
                  size: screenWidth * 0.5,  // 50% of screen width
                  color: Colors.white.withValues(alpha: 0.08),  // Low opacity to blend
                ),
              ),
              // Content layer
              Padding(
                padding: EdgeInsets.only(
                  left: screenWidth * 0.05,
                  right: screenWidth * 0.05,
                  top: screenWidth * 0.05,
                  bottom: 0,  // Remove bottom padding so vertical divider touches card edge
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                // Available Budget Section (70%)
                Expanded(
                  flex: 70,  // Reduced from 80 to give more space to action buttons
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Label + visibility toggle
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Available Budget',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: screenWidth * 0.04,  // Matched with button font size
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          GestureDetector(
                            onTap: onToggleVisibility,
                            child: Icon(
                              isBudgetVisible ? Icons.visibility : Icons.visibility_off,
                              color: Colors.white,
                              size: screenWidth * 0.05,  // ~5% of screen width
                            ),
                          ),
                        ],
                      ),
                      const Spacer(flex: 1),
                      // Budget amount - takes remaining space in 80% section
                      if (budgetHealth == null)
                        const CircularProgressIndicator(color: Colors.white)
                      else if (isBudgetVisible)
                        Text.rich(
                          TextSpan(
                            children: [
                              // Currency code - SMALLER
                              TextSpan(
                                text: '$currencySymbol ',
                                style: TextStyle(
                                  color: _getAmountColor(budgetHealth!.remainingAmount),
                                  fontSize: screenWidth * 0.07,  // Smaller: 7% of screen width
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                              // Amount - LARGER
                              TextSpan(
                                text: UIManager.formatAmount(
                                  budgetHealth!.remainingAmount,
                                  currencySymbol: '',  // Remove currency symbol, we handle it above
                                ),
                                style: TextStyle(
                                  color: _getAmountColor(budgetHealth!.remainingAmount),
                                  fontSize: screenWidth * 0.14,  // Larger: 14% of screen width
                                  fontWeight: FontWeight.normal,
                                  letterSpacing: 1.0,
                                ),
                              ),
                            ],
                          ),
                        )
                      else
                        Text(
                          '- - - - - -',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: screenWidth * 0.08,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 4.0,
                          ),
                        ),
                      const Spacer(flex: 1),
                    ],
                  ),
                ),

                // Gradient Divider
                _buildGradientDivider(),

                // Action Buttons Section (30%)
                Expanded(
                  flex: 30,  // Increased from 20 to accommodate larger button fonts
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildActionButton(
                          context,
                          screenWidth: screenWidth,
                          icon: Icons.add_circle_outline,
                          label: 'Budget',
                          onTap: onAddBudget,
                        ),
                      ),
                      Container(
                        width: 1,
                        height: double.infinity,  // Match parent height
                        color: Colors.white.withValues(alpha: 0.3),
                      ),
                      Expanded(
                        child: _buildActionButton(
                          context,
                          screenWidth: screenWidth,
                          icon: Icons.add_circle_outline,  // Changed from Icons.attach_money
                          label: 'Expenses',
                          onTap: onPayExpense,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],  // Close Stack children
      ),  // Close Stack
    );
      },
    );
  }

  Widget _buildGradientDivider() {
    return Container(
      height: 1,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withValues(alpha: 0.0),
            Colors.white.withValues(alpha: 0.5),
            Colors.white.withValues(alpha: 0.0),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required double screenWidth,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: Colors.white,
            size: screenWidth * 0.05,  // ~5% of screen width
          ),
          SizedBox(width: screenWidth * 0.02),  // 2% spacing
          Text(
            label,
            style: TextStyle(
              color: Colors.white,
              fontSize: screenWidth * 0.04,  // Slightly larger than original for better readability
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Color _getAmountColor(double remaining) {
    return Colors.white;  // Always white for consistency
  }
}
