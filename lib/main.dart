import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/app_localizations.dart';

import 'firebase_options.dart';
import 'core/logger.dart';
import 'core/managers/repository_manager.dart';
import 'package:budmate/core/managers/usecase_manager.dart';
import 'package:budmate/core/managers/budget_manager.dart';
import 'package:budmate/core/managers/service_manager.dart';
import 'services/category_service.dart';
import 'services/preferences_service.dart';
import 'services/notification_service.dart';
import 'ui/shared/app_theme.dart';
import 'ui/shared/auth_wrapper.dart';

/// BudMate application entry point initializing Firebase, Firestore, and dependency injection.
///
/// This file bootstraps the entire application by setting up all infrastructure dependencies
/// before the UI launches. It uses Provider pattern for dependency injection making services
/// and repositories available throughout the widget tree.
///
/// Initialization sequence:
/// 1. Firebase: Remote authentication and cloud services
/// 2. Firestore: Cloud database for data persistence across devices
/// 3. SharedPreferences: Fast key-value cache for session data
/// 4. Repository setup: Auth repository coordinating remote and local datasources
/// 5. Provider configuration: Injecting repositories, use cases, and services into widget tree
///
/// The entire initialization is wrapped in try/catch providing graceful error handling.
/// If initialization fails, users see a helpful error screen instead of a crash, displaying
/// diagnostic information and troubleshooting steps.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  Logger.info('Starting BudMate application...');

  try {
    Logger.info('Initializing Firebase...');
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    Logger.info('Firebase initialized successfully');

    Logger.info('Configuring Firestore...');
    final firestore = FirebaseFirestore.instance;

    // Enable offline persistence for better UX (default is already enabled on mobile)
    Logger.info('Firestore configured with offline persistence');

    Logger.info('Initializing SharedPreferences...');
    final sharedPreferences = await SharedPreferences.getInstance();
    Logger.info('SharedPreferences initialized successfully');

    Logger.info('Initializing PreferencesService...');
    final preferencesService = PreferencesService(sharedPreferences);
    Logger.info('PreferencesService initialized successfully');

    Logger.info('Initializing NotificationService...');
    final notificationService = NotificationService();
    await notificationService.initialize();
    Logger.info('NotificationService initialized successfully');

    final repositoryFactory = RepositoryManager(firestore);
    final authRepository = repositoryFactory.createAuthRepository(sharedPreferences);
    final budgetRepository = repositoryFactory.createBudgetRepository();
    final categoryRepository = repositoryFactory.createCategoryRepository();
    final expenseRepository = repositoryFactory.createExpenseRepository();

    final authUseCases = UseCaseManager.createAuthUseCases(authRepository);
    final budgetUseCases = UseCaseManager.createBudgetUseCases(budgetRepository);
    final categoryUseCases = UseCaseManager.createCategoryUseCases(categoryRepository);
    final expenseUseCases = UseCaseManager.createExpenseUseCases(expenseRepository);

    final budgetManager = BudgetManager(
      budgetRepository: budgetRepository,
      expenseRepository: expenseRepository,
    );

    Logger.info('All dependencies initialized successfully');

    // Initialize global categories at startup
    Logger.info('Initializing global categories...');
    CategoryService? initializedCategoryService;

    try {
      final tempCategoryService = CategoryService(categoryUseCases: categoryUseCases);
      final categoriesCreated = await tempCategoryService.initializeDefaultCategories();

      if (categoriesCreated) {
        Logger.info('Global categories initialized successfully');
      } else {
        Logger.info('Global categories already exist');
      }

      initializedCategoryService = tempCategoryService;
    } catch (e, stackTrace) {
      // Critical error - categories could not be created
      Logger.error(
        'CRITICAL: Failed to initialize categories',
        error: e,
        stackTrace: stackTrace,
      );

      // Show error to user instead of continuing with broken app
      runApp(
        MaterialApp(
          home: Scaffold(
            backgroundColor: Colors.red.shade50,
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 64, color: Colors.red),
                    const SizedBox(height: 24),
                    const Text(
                      'Failed to Initialize Categories',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Error: ${e.toString()}',
                      style: const TextStyle(fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Please check:\n'
                      '1. Firestore connection\n'
                      '2. Firestore rules allow category writes\n'
                      '3. Internet connection',
                      style: TextStyle(fontSize: 12),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
      return;
    }

    runApp(
      MultiProvider(
        providers: [
          // Firestore instance (used by datasources)
          Provider<FirebaseFirestore>.value(value: firestore),

          // ===== REPOSITORIES =====
          Provider<AuthRepository>.value(value: authRepository),
          Provider<BudgetRepository>.value(value: budgetRepository),
          Provider<CategoryRepository>.value(value: categoryRepository),
          Provider<ExpenseRepository>.value(value: expenseRepository),

          // ===== USE CASE GROUPS =====
          Provider<AuthUseCases>.value(value: authUseCases),
          Provider<BudgetUseCases>.value(value: budgetUseCases),
          Provider<CategoryUseCases>.value(value: categoryUseCases),
          Provider<ExpenseUseCases>.value(value: expenseUseCases),

          // ===== DOMAIN SERVICES =====
          Provider<BudgetManager>.value(value: budgetManager),

          // ===== PRESENTATION SERVICES (via ServiceManager) =====
          ...ServiceManager.createProviders(
            authUseCases: authUseCases,
            budgetUseCases: budgetUseCases,
            categoryUseCases: categoryUseCases,
            expenseUseCases: expenseUseCases,
            budgetManager: budgetManager,
            categoryService: initializedCategoryService,
            notificationService: notificationService,
          ),

          // ===== USER PREFERENCES SERVICE =====
          ChangeNotifierProvider<PreferencesService>(
            create: (_) => preferencesService,
          ),
        ],
        child: Builder(
          builder: (context) => MyApp(),
        ),
      ),
    );
  } catch (e, stackTrace) {
    Logger.error(
      'Failed to initialize application',
      error: e,
      stackTrace: stackTrace,
    );

    runApp(
      MaterialApp(
        home: Scaffold(
          backgroundColor: Colors.red.shade50,
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red,
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Failed to Initialize Application',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error: ${e.toString()}',
                    style: const TextStyle(fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Please check:\n'
                    '1. Firebase configuration (google-services.json)\n'
                    '2. Internet connection (required for Firestore)\n'
                    '3. App permissions',
                    style: TextStyle(fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<PreferencesService>(
      builder: (context, prefsService, _) {
        Logger.debug('MyApp rebuild: themeMode=${prefsService.themeMode}');

        return MaterialApp(
          title: 'BudMate',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: _getThemeMode(prefsService.themeMode),
          locale: _getLocale(prefsService.language),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en'),
            Locale('fil'),
          ],
          home: const AuthWrapper(),
        );
      },
    );
  }

  /// Convert theme mode string to ThemeMode enum
  ThemeMode _getThemeMode(String mode) {
    switch (mode) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
      default:
        return ThemeMode.system;
    }
  }

  /// Convert language code string to Locale
  Locale _getLocale(String languageCode) {
    return Locale(languageCode == 'fil' ? 'fil' : 'en');
  }
}

class HomePage extends StatelessWidget{
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('BudMate'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.check_circle,
                size: 80,
                color: Colors.green,
              ),
              const SizedBox(height: 24),
              const Text(
                'BudMate Backend Initialized',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              const Text(
                'Clean Architecture Backend Ready',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Initialized Components:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildCheckItem('Firebase Authentication'),
                    _buildCheckItem('Firestore Cloud Database'),
                    _buildCheckItem('Auth Feature (Domain + Data)'),
                    _buildCheckItem('Category Feature (Domain + Data)'),
                    _buildCheckItem('Budget Feature (Domain + Data)'),
                    _buildCheckItem('Expense Feature (Domain + Data)'),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                'Next: Build UI (Phase 2)',
                style: TextStyle(
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCheckItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          const Icon(Icons.check, size: 16, color: Colors.green),
          const SizedBox(width: 8),
          Text(text),
        ],
      ),
    );
  }
}
