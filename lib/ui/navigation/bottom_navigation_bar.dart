import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import 'home_screen.dart';
import 'expense_history_screen.dart';
import 'modals/pay_expenses_modal.dart';
import 'dashboard_screen.dart';
import 'profile_screen.dart';

/// Bottom navigation bar container with 4-tab navigation and center-docked FAB.
///
/// Provides the primary navigation structure for the authenticated app experience. Uses IndexedStack
/// to preserve state when switching between tabs (Home, History, Analytics, Profile). The center
/// FloatingActionButton opens AddExpenseModal for quick expense entry. BottomAppBar with notched
/// cutout creates the gap where the FAB sits, following Material Design 3 patterns. Only 4 navigation
/// items are shown - the FAB is not part of the bottom navigation, it floats above in the notch.
class BottomNavigationBarScreen extends StatefulWidget {
  final int initialIndex;

  const BottomNavigationBarScreen({
    super.key,
    this.initialIndex = 0,
  });

  @override
  State<BottomNavigationBarScreen> createState() => _BottomNavigationBarScreenState();
}

class _BottomNavigationBarScreenState extends State<BottomNavigationBarScreen> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final isSelected = _currentIndex == index;
    final color = isSelected
        ? Theme.of(context).colorScheme.primary
        : Colors.grey;

    return Expanded(
      child: InkWell(
        onTap: () => _onItemTapped(index),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 24, color: color),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFabLabel(String label) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 26),  // Space for icon (24px icon + 2px spacing)
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: Colors.grey,  // Unselected color to match other nav items
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: const [
          HomeScreen(),
          ExpenseHistoryScreen(),
          DashboardScreen(),
          ProfileScreen(),
        ],
      ),
      floatingActionButton: Transform.translate(
        offset: const Offset(0, 14),  // Move FAB down by 14 pixels
        child: FloatingActionButton(
          onPressed: () => PayExpensesModal.show(context),
          tooltip: l10n.addExpense,
          elevation: 0,  // Remove shadow
          child: const Icon(Icons.payments),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        padding: EdgeInsets.zero,
        child: SizedBox(
          height: kBottomNavigationBarHeight,
          child: Row(
            children: [
              _buildNavItem(Icons.home, l10n.home, 0),
              _buildNavItem(Icons.receipt_long, l10n.history, 1),
              _buildFabLabel(l10n.addExpense),
              _buildNavItem(Icons.analytics, l10n.dashboard, 2),
              _buildNavItem(Icons.person, l10n.profile, 3),
            ],
          ),
        ),
      ),
    );
  }
}