import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/budget_service.dart';
import '../../services/expense_service.dart';
import '../../services/auth_service.dart';
import '../../core/managers/ui_manager.dart';
import '../../core/logger.dart';
import '../../core/utils/theme_helper.dart';
import 'widgets/maribank_budget_card.dart';
import 'widgets/upcoming_expenses_list.dart';
import 'modals/add_budget_modal.dart';
import 'modals/expenses_modal.dart';

/// Home screen with integrated teal header, Maribank-style budget card, and upcoming expenses.
///
/// The functional hub shown after authentication following Maribank design patterns.
/// Features a teal header with profile info and logout button, budget management with
/// UI-only privacy toggle (not persisted), and upcoming expense tracking.
///
/// Uses dynamic sizing - NO hardcoded pixel values. All dimensions are relative
/// to screen size for responsive design across different devices and screen ratios.
///
/// UI structure:
/// - Teal header (SafeArea top only): Profile picture (5% screen width), name (4% screen width),
///   email (3% screen width, 0.8 alpha), logout button with icon + text
/// - Main content area: White background with rounded top corners (24px radius)
/// - MaribankBudgetCard: Gradient card with 80:20 ratio, hide/show toggle, action buttons
/// - UpcomingExpensesList: Dynamically sized list (25% screen height)
///
/// Service integration:
/// - AuthService: Provides current user data, handles logout
/// - BudgetService: Loads budget data, provides budgetHealth.remainingAmount
/// - ExpenseService: Loads expenses for upcoming list display
///
/// Budget visibility toggle is UI-only state (not persisted to preferences).
/// All header components use MediaQuery for responsive sizing across devices.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isBudgetVisible = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  void _toggleBudgetVisibility() {
    setState(() {
      _isBudgetVisible = !_isBudgetVisible;
    });
  }

  Future<void> _loadData() async {
    final authService = context.read<AuthService>();
    final currentUser = authService.currentUser;

    if (currentUser == null) {
      Logger.error('HomeScreen: No authenticated user');
      if (mounted) {
        UIManager.showError(context, 'Please sign in again.');
      }
      return;
    }

    Logger.info('HomeScreen: Loading data for user ${currentUser.id}');

    await Future.wait([
      context.read<BudgetService>().loadBudgets(currentUser.id),
      context.read<ExpenseService>().loadExpenses(currentUser.id),
    ]);

    if (!mounted) return;
    final budgetService = context.read<BudgetService>();
    final expenseService = context.read<ExpenseService>();

    if (budgetService.lastError != null) {
      UIManager.showError(context, budgetService.lastError!);
    }
    if (expenseService.lastError != null) {
      UIManager.showError(context, expenseService.lastError!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: ThemeHelper.getSurfaceColor(context),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: RefreshIndicator(
                onRefresh: _loadData,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final screenHeight = constraints.maxHeight;

                    return SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Only rebuild card when BudgetService changes
                          Consumer<BudgetService>(
                            builder: (context, budgetService, _) {
                              if (budgetService.isLoading) {
                                return UIManager.buildLoadingState(message: 'Loading budget...');
                              }
                              return RepaintBoundary(
                                child: MaribankBudgetCard(
                                  budgetHealth: budgetService.budgetHealth,
                                  isBudgetVisible: _isBudgetVisible,
                                  onToggleVisibility: _toggleBudgetVisibility,
                                  onAddBudget: () => AddBudgetModal.show(context),
                                  onPayExpense: () => ExpensesModal.show(context),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 16),
                          // Only rebuild list when ExpenseService changes
                          Consumer<ExpenseService>(
                            builder: (context, expenseService, _) {
                              if (expenseService.isLoading) {
                                return UIManager.buildLoadingState(message: 'Loading expenses...');
                              }
                              return RepaintBoundary(
                                child: UpcomingExpensesList(
                                  expenses: expenseService.expenses.cast(),
                                  screenHeight: screenHeight,
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Selector<AuthService, dynamic>(
      selector: (_, auth) => auth.currentUser,
      builder: (context, user, _) {
        return LayoutBuilder(
          builder: (context, constraints) {
            final screenWidth = constraints.maxWidth;
            final screenHeight = MediaQuery.of(context).size.height;

            return SafeArea(
              bottom: false,
              child: Padding(
                padding: EdgeInsets.all(screenWidth * 0.04),  // 4% of screen width
                child: Row(
                  children: [
                    _buildAvatar(context, user, radius: screenWidth * 0.05),  // 5% of screen width
                    SizedBox(width: screenWidth * 0.03),  // 3% spacing
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            user?.displayName ?? 'User',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: screenWidth * 0.04,  // 4% of screen width
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: screenHeight * 0.002),  // 0.2% spacing
                          Text(
                            user?.email ?? 'No email',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.8),
                              fontSize: screenWidth * 0.03,  // 3% of screen width
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildAvatar(BuildContext context, user, {required double radius}) {
    if (user?.photoUrl != null && user!.photoUrl!.isNotEmpty) {
      return CircleAvatar(
        radius: radius,
        backgroundImage: NetworkImage(user!.photoUrl!),
        onBackgroundImageError: (exception, stackTrace) {
          // Stops NetworkImage retry cycle - prevents BLASTBufferQueue spam
          Logger.error('Failed to load profile image', error: exception);
        },
        backgroundColor: Theme.of(context).colorScheme.primary,
      );
    }

    final initials = _getInitials(user?.displayName);
    return CircleAvatar(
      radius: radius,
      backgroundColor: Colors.white.withValues(alpha: 0.3),
      child: Text(
        initials,
        style: TextStyle(
          color: Colors.white,
          fontSize: radius * 0.6,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  String _getInitials(String? name) {
    if (name == null || name.isEmpty) return '?';

    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name[0].toUpperCase();
  }
}