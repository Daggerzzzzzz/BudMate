# BudMate - Personal Budget Tracking App

Clean Architecture Flutter app with Firebase cloud architecture. Backend complete, UI pending.

## Status
✅ Backend: Complete (51 files, 18 passing tests, 0 analyze issues)
⏳ UI: Pending
📊 Test Coverage: BudgetManager (18/18 tests)
💰 Cost: $0/month (100% Firebase Free Tier - Spark Plan)

## Tech Stack
Provider | Firebase Auth | Cloud Firestore | dartz Either | Clean Architecture

## Architecture Highlights
**Authentication:** Firebase Auth (email/password + Google OAuth)
**Data Storage:** Cloud Firestore (NoSQL cloud database, FREE tier)
**Session Cache:** SharedPreferences (fast startup)
**Cost:** $0/month (Spark Plan: 50k reads/day, 20k writes/day, 1GB storage)

## Features
- Multi-period budgets (daily/weekly/monthly) with 90% spending alerts
- Category-based expense tracking with filtering
- Cloud sync with offline persistence (automatic Firestore caching)
- Zero cost on FREE tier (Spark Plan limits sufficient for personal use)

## Navigation Structure

BudMate uses a bottom navigation bar with 5 main sections for easy access to all features:

### 🏠 Home (Main Entry Point)
- **Overview**: Budget health snapshot and spending summary
- **Upcoming Bills**: Track expenses due soon to avoid late payments (Coming soon)
- **Quick Actions**: One-tap shortcuts to common tasks (Coming soon)
- **Recent Activity**: Latest transactions at a glance (Coming soon)

**Purpose**: Central hub showing the most important information at a glance. This is the main entry point after authentication, replacing the traditional dashboard.

### 📋 Expense History
- **Full Transaction Log**: Complete list of all expenses sorted by date
- **Status Tracking**: View and manage all your recorded expenses
- **Smart Filters**: Filter by status, category, date range, or amount (Coming soon)
- **Search**: Quick search by description or amount (Coming soon)

**Purpose**: Comprehensive expense management and tracking. Never lose track of a payment again.

### ➕ Pay Expenses (Center Button)
- **Quick Entry**: Fast expense creation with minimal fields
- **Category Selection**: Choose from predefined categories with icons
- **Date Picker**: Select expense date (defaults to today)
- **Optional Notes**: Add descriptions for better tracking

**Purpose**: Primary action button for creating new expenses. Prominently placed in the center of the navigation bar for easy access from any screen. Features a payments icon without shadow for a modern, flat appearance.

### 📊 Analytics Dashboard
- **Spending Trends**: Visualize spending patterns over time (Coming soon)
- **Category Breakdown**: See where your money goes with charts (Coming soon)
- **Budget Health**: Detailed view of budget utilization and spending progress
- **Comparison Reports**: Compare spending across different periods (Coming soon)

**Purpose**: Data-driven insights into spending habits. Helps users make informed financial decisions.

### 👤 Profile & Settings
- **Account Management**: View and edit profile information
- **Currency Selection**: Choose preferred currency for display (Coming soon)
- **Language Options**: Select interface language (Coming soon)
- **Dark Mode Toggle**: Switch between light and dark themes (Coming soon)
- **Security Settings**: Password, biometric lock, and privacy options (Coming soon)
- **Sign Out**: Securely log out of the application

**Purpose**: Personalization and account management. Customize the app to match user preferences.

## Quick Navigation
[Architecture](#architecture) | [Database](#database-schema) | [Auth](#authentication-flow) | [UI Guide](#building-the-ui) | [API](#api-reference)

---

## Quick Start

```bash
flutter pub get           # Install dependencies
flutter test              # 18/18 passing
flutter analyze           # 0 issues
```

### Firebase Setup (Required)

#### 1. Firebase Console Setup (MANDATORY - Do This First)
1. ✅ Firebase project: `budmate-94196`
2. ✅ google-services.json added to `android/app/`
3. ✅ firebase_options.dart configured with platform options
4. ✅ Email/Password + Google Sign-In enabled in Firebase Console

#### 2. Firestore Security Rules (MUST SET BEFORE RUNNING APP)
Go to: https://console.firebase.google.com/project/budmate-94196/firestore/rules

Copy and paste these rules, then click **Publish**:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    function isAuthenticated() {
      return request.auth != null;
    }

    function isOwner(userId) {
      return request.auth.uid == userId;
    }

    match /budgets/{budgetId} {
      allow read, write: if isAuthenticated() && isOwner(resource.data.userId);
      allow create: if isAuthenticated() && isOwner(request.resource.data.userId);
    }

    match /categories/{categoryId} {
      allow read, write: if isAuthenticated() && isOwner(resource.data.userId);
      allow create: if isAuthenticated() && isOwner(request.resource.data.userId);
    }

    match /expenses/{expenseId} {
      allow read, write: if isAuthenticated() && isOwner(resource.data.userId);
      allow create: if isAuthenticated() && isOwner(request.resource.data.userId);
    }
  }
}
```

#### 3. Firestore Composite Indexes (Created Automatically)
When you run the app and try to load data, Firestore will show errors with clickable links to auto-create these indexes:

**Required Indexes** (5 total):
1. **budgets** collection:
   - `userId` (Ascending) + `startDate` (Descending)

2. **categories** collection:
   - `userId` (Ascending) + `name` (Ascending)

3. **expenses** collection (3 indexes):
   - `userId` (Ascending) + `date` (Descending)
   - `userId` (Ascending) + `categoryId` (Ascending) + `date` (Descending)
   - `categoryId` (Ascending) + `date` (Descending)

**How to create indexes:**
- Option 1 (Automatic): Run the app, click the error links in console to auto-create
- Option 2 (Manual): Go to Firestore console > Indexes > Create index manually

---

## Architecture

### Cloud Architecture Decision

**Why Firebase Auth + Cloud Firestore?**
- **Firebase Auth:** Industry-standard authentication (free tier: unlimited users)
- **Cloud Firestore:** NoSQL cloud database with automatic offline sync
- **Offline Persistence:** Automatic caching (works without internet)
- **Free Tier:** 50k reads/day, 20k writes/day, 1GB storage (100% free for personal use)
- **Multi-Device Sync:** Data syncs across all user devices automatically
- **Real-time Updates:** Changes sync in real-time across devices

### Clean Architecture Layers

```
┌─────────────────────────────────────────────────────┐
│              PRESENTATION LAYER (UI)                 │
│        Screens, Widgets, State Management            │
└──────────────────┬───────────────────────────────────┘
                   ↓ depends on
┌──────────────────┴───────────────────────────────────┐
│                   SERVICES LAYER                     │
│   AuthService, BudgetService, CategoryService,       │
│   ExpenseService, BudgetManager (Provider)           │
└──────────────────┬───────────────────────────────────┘
                   ↓ depends on
┌──────────────────┴───────────────────────────────────┐
│                  USE CASES LAYER                     │
│  SignIn, CreateBudget, CreateExpense (24 use cases) │
└──────────────────┬───────────────────────────────────┘
                   ↓ depends on
┌──────────────────┴───────────────────────────────────┐
│              REPOSITORY INTERFACES (Domain)          │
│   AuthRepo, BudgetRepo, CategoryRepo, ExpenseRepo   │
└──────────────────┬───────────────────────────────────┘
                   ↑ implemented by
┌──────────────────┴───────────────────────────────────┐
│            REPOSITORY IMPLEMENTATIONS (Data)         │
│    4 Repository Impls coordinating datasources       │
└──────────┬─────────────────┬────────────────────────┘
           ↓                 ↓
┌──────────┴─────────┐  ┌────┴───────────────────────┐
│  FIREBASE AUTH     │  │  FIRESTORE DATASOURCES (4) │
│  (AuthRemote)      │  │  Budget/Category/Expense/  │
│  Email + Google    │  │  User → Cloud Firestore    │
└─────────────────────┘  └────────────────────────────┘
                              ↓
                     ┌────────┴─────────────┐
                     │   Cloud Firestore     │
                     │   3 collections:      │
                     │   - budgets           │
                     │   - categories        │
                     │   - expenses          │
                     │   User-scoped data    │
                     │   Offline persistence │
                     └───────────────────────┘
```

**Key Insight:** Firebase handles both authentication AND data storage. All data stored in cloud with automatic offline sync.

### Folder Structure

```
lib/
├── core/                    # Infrastructure
│   ├── constants.dart       # App, Firebase constants
│   ├── errors.dart          # Exceptions & Failures
│   ├── extensions.dart      # DateTime helpers
│   ├── logger.dart          # Logging
│   └── managers/            # Infrastructure managers (6 files)
│       ├── budget_manager.dart      # Domain: Budget health calculations, 90% alerts
│       ├── navigation_manager.dart  # UI: Screen/modal/dialog navigation (centralized)
│       ├── ui_manager.dart          # UI: Feedback, widget builders, formatters
│       ├── repository_manager.dart  # DI: Repository factory + datasource wiring
│       ├── service_manager.dart     # DI: Service factory + Provider wiring
│       └── usecase_manager.dart     # DI: Use case grouping (24 → 4 groups)
├── domain/                  # Entities (pure business logic)
│   ├── user_entity.dart
│   ├── budget_entity.dart
│   ├── category_entity.dart
│   ├── expense_entity.dart
│   └── budget_health_result.dart
├── data/
│   ├── models/              # Serialization
│   │   ├── user_model.dart
│   │   ├── budget_model.dart
│   │   ├── category_model.dart
│   │   └── expense_model.dart
│   └── sources/             # External data access
│       ├── auth_remote_datasource.dart      # Firebase Auth
│       ├── auth_local_datasource.dart       # SharedPreferences
│       ├── budget_firestore_datasource.dart # Cloud Firestore
│       ├── category_firestore_datasource.dart
│       └── expense_firestore_datasource.dart
├── repositories/            # Repository pattern
│   ├── auth_repository.dart
│   ├── auth_repository_impl.dart
│   ├── budget_repository.dart
│   ├── budget_repository_impl.dart
│   ├── category_repository.dart
│   ├── category_repository_impl.dart
│   ├── expense_repository.dart
│   └── expense_repository_impl.dart
├── usecases/                # Single-responsibility actions
│   ├── auth/ (8 use cases)
│   │   ├── sign_in_with_email.dart
│   │   ├── sign_up_with_email.dart
│   │   ├── sign_in_with_google.dart
│   │   ├── sign_out.dart
│   │   ├── get_current_user.dart
│   │   ├── send_verification_email.dart
│   │   ├── check_email_verified.dart
│   │   └── clear_all_data.dart
│   ├── budget/ (create, get, update, delete)
│   ├── category/ (create, get, update, delete)
│   └── expense/ (create, get, update, delete)
├── services/
│   ├── auth_service.dart         # ChangeNotifier
│   ├── budget_service.dart       # ChangeNotifier
│   ├── category_service.dart     # ChangeNotifier
│   └── expense_service.dart      # ChangeNotifier
├── ui/                          # Presentation layer (3 folders, 70% reduction)
│   ├── auth/                    # Authentication flow screens (4 files)
│   │   ├── login_screen.dart
│   │   ├── email_sign_in_screen.dart
│   │   ├── sign_up_screen.dart
│   │   └── email_verification_waiting_screen.dart
│   ├── navigation/              # All main app screens + modals (7 files + modals/ + widgets/)
│   │   ├── main_navigation_screen.dart
│   │   ├── home_screen.dart
│   │   ├── analytics_screen.dart
│   │   ├── expense_history_screen.dart
│   │   ├── profile_screen.dart
│   │   ├── dashboard_screen.dart
│   │   ├── bottom_navigation_bar.dart
│   │   ├── modals/              # Modal dialogs (3 files)
│   │   │   ├── add_budget_modal.dart       # Budget card "Budget" button
│   │   │   ├── expenses_modal.dart         # Budget card "Expenses" button
│   │   │   └── pay_expenses_modal.dart     # FAB "Pay Expenses" button
│   │   └── widgets/
│   │       ├── maribank_budget_card.dart
│   │       ├── upcoming_expenses_list.dart
│   │       ├── budget_health_card.dart
│   │       └── budget_list.dart
│   └── shared/                  # Reusable UI components (7 files)
│       ├── app_theme.dart
│       ├── base_modal.dart
│       ├── primary_button.dart
│       ├── secondary_button.dart
│       ├── email_text_field.dart
│       ├── password_text_field.dart
│       └── placeholder_screen.dart
└── main.dart                     # DI + bootstrap
```

**Benefits**:
- Single Responsibility: Each layer has one job
- Testability: Mock dependencies easily
- Maintainability: Changes isolated to specific layers
- Dependency Inversion: Domain doesn't depend on frameworks

---

## Modals and Dialogs

BudMate uses three main modals for budget and expense management:

### 📝 Add Budget Modal
**File:** `lib/ui/navigation/modals/add_budget_modal.dart`
**Trigger:** Budget card "Budget" button (left action button)
**Purpose:** Create new budget entries with amount, period, and date range
**Status:** Placeholder (Phase 6 implementation)

### 💰 Expenses Modal
**File:** `lib/ui/navigation/modals/expenses_modal.dart`
**Trigger:** Budget card "Expenses" button (right action button)
**Purpose:** Manage and view expense tracking
**Status:** Placeholder (Phase 6 implementation)

### 💳 Pay Expenses Modal
**File:** `lib/ui/navigation/modals/pay_expenses_modal.dart`
**Trigger:** FAB "Pay Expenses" button (center-docked floating action button)
**Purpose:** Quick expense entry with amount, category, date, and description
**Icon:** `Icons.payments`
**Design:** Flat appearance with elevation: 0 (no shadow)
**Status:** Placeholder (Phase 6 implementation)

**Design Pattern:** All modals extend the shared `BaseModal` component (`lib/ui/shared/base_modal.dart`) for consistent styling with backdrop blur effects (sigma 5.0) following Maribank design patterns.

---

## Core Infrastructure

### Error Handling

```dart
// EXCEPTIONS (Data Layer):
ServerException       // Firebase/network
CacheException        // SharedPreferences
FirestoreException    // Cloud Firestore

// FAILURES (Domain Layer):
AuthFailure
DatabaseFailure

// FLOW:
DataSource throws Exception
  → Repository catches
  → Converts to Failure
  → Returns Either<Failure, Success>
```

### Constants

```dart
AppConstants:
  budgetAlertThreshold = 0.90  // 90% threshold
  currencySymbol = 'PHP'
  appName = 'budMate'

FirebaseConstants:
  errorEmailAlreadyInUse = 'email-already-in-use'
  errorUserNotFound = 'user-not-found'
  ...

FirestoreConstants:
  collectionBudgets = 'budgets'
  collectionCategories = 'categories'
  collectionExpenses = 'expenses'
  fieldUserId = 'userId'
  fieldAmount = 'amount'
  ...
```

### Logger

```dart
Logger.debug('message')          // Level 500
Logger.info('message')           // Level 800
Logger.error('msg', error, stack) // Level 1000
```

### DateTime Extensions

```dart
DateTime.now().toFirestoreTimestamp()  // → Timestamp (for Firestore)
Timestamp.toDateTime()                 // → DateTime

date.startOfDay, date.endOfDay
date.startOfWeek, date.endOfWeek
date.startOfMonth, date.endOfMonth
date.isToday  // bool
```

---

## Domain Layer

### Entities

```dart
// UserEntity:
UserEntity(
  id: String,           // Firebase UID
  email: String?,       // Optional for social login
  displayName: String?,
  photoUrl: String?,
)

// BudgetEntity:
BudgetEntity(
  id, userId, name, amount, period,
  startDate, endDate, createdAt, updatedAt,
)
bool get isActive  // current date within startDate/endDate

// CategoryEntity:
CategoryEntity(id, userId, name, icon, color, createdAt, updatedAt)

// ExpenseEntity:
ExpenseEntity(id, userId, amount, description?, categoryId, date, createdAt, updatedAt)

// BudgetHealthResult:
BudgetHealthResult(
  userId, totalExpenses, budgetAmount,
  percentageUsed, isOverBudget, shouldAlert, calculatedAt,
)
double get remainingAmount  // budgetAmount - totalExpenses
```

### Repository Contracts

```dart
// AuthRepository:
abstract class AuthRepository {
  Future<Either<AuthFailure, UserEntity>> signInWithEmail({email, password});
  Future<Either<AuthFailure, UserEntity>> signUpWithEmail({email, password, displayName?});
  Future<Either<AuthFailure, UserEntity>> signInWithGoogle();
  Future<Either<AuthFailure, void>> signOut();
  Future<Either<AuthFailure, UserEntity?>> getCurrentUser();
  Future<Either<AuthFailure, void>> sendVerificationEmail();
  Future<Either<AuthFailure, bool>> checkEmailVerified();
  Future<Either<AuthFailure, void>> clearAllData(String userId);
}

// BudgetRepository, CategoryRepository, ExpenseRepository:
// Same pattern: create, getAll, update, delete
```

---

## Data Layer

### Models (Serialization)

```dart
// UserModel: 3 serialization methods
fromFirebase(firebase_auth.User) → UserModel  // Firebase → Domain
toJson/fromJson → Map<String, dynamic>        // SharedPreferences
toMap/fromMap → Map<String, dynamic>          // Firestore

// BudgetModel, CategoryModel, ExpenseModel:
toMap() → Map<String, dynamic>    // DateTime → Timestamp
fromMap(Map) → Model              // Timestamp → DateTime
```

### DataSources

```dart
// AuthRemoteDataSource (Firebase):
signInWithEmail, signUpWithEmail, signInWithGoogle, signOut, getCurrentUser,
sendVerificationEmail, checkEmailVerified

// AuthLocalDataSource (SharedPreferences):
cacheUser, getCachedUser, clearCache  // Key: 'CACHED_USER'

// BudgetFirestoreDataSource, CategoryFirestoreDataSource, ExpenseFirestoreDataSource:
create, getAll, update, delete
// All queries are user-scoped (.where('userId', isEqualTo: userId))
```

### Repository Pattern

```dart
class BudgetRepositoryImpl implements BudgetRepository {
  final BudgetFirestoreDataSource datasource;

  Future<Either<DatabaseFailure, BudgetEntity>> create(BudgetEntity budget) async {
    try {
      final model = BudgetModel(...);           // Entity → Model
      final result = await datasource.create(model);
      return Right(result);                     // Model → Entity
    } on FirestoreException catch (e) {
      return Left(DatabaseFailure(e.message));  // Exception → Failure
    }
  }
}
```

---

## Authentication Flow

### Two-Layer Authentication Pattern

**Why 2 layers?**
- **Firebase:** Cloud authentication (email/password, Google OAuth)
- **SharedPreferences:** Fast session cache (instant app startup)

```
┌─────────────────────────────────────────┐
│  1. Firebase Auth (Remote)              │
│     • Email/password authentication      │
│     • Google OAuth sign-in               │
│     • User management & security         │
│     • Email verification                 │
└────────┬────────────────────────────────┘
         ↓ on success
┌────────┴────────────────────────────────┐
│  2. SharedPreferences (Cache)           │
│     • JSON serialization                 │
│     • Fast session restoration           │
│     • No internet required for startup   │
└──────────────────────────────────────────┘
```

### Sign In/Up Flow

```dart
1. Authenticate with Firebase (remote)
   → signInWithEmailAndPassword() or signInWithGoogle()
2. Cache user in SharedPreferences (key: 'CACHED_USER')
   → JSON serialization for instant session restoration
3. Return UserEntity to caller

// Error handling: Firebase exception → AuthFailure
```

**Cost:** Firebase Auth free tier supports unlimited users (no cost).

### Graceful Degradation (GetCurrentUser)

```
┌─────────────────┐
│  Try Firebase   │ ──┐
└────────┬────────┘   │ if null/error
         ↓ success    ↓
     Return user   ┌────────────────┐
                   │ Try Cache      │
                   └────────┬───────┘
                            ↓ fail
                      AuthFailure
```

### Google Sign-In

```dart
1. GoogleSignIn → Get auth tokens
2. Create Firebase credential
3. Sign in to Firebase
4. Cache (same as email)
```

### Sign Out

```dart
1. Firebase.signOut() → Clear remote session
2. SharedPreferences.clear() → Clear cached session
```

---

## Database Schema

### Cloud Firestore Database

**Database Type:** NoSQL Document Database (Cloud-based)
**Cost:** FREE (Spark Plan: 50k reads/day, 20k writes/day, 1GB storage)
**Offline Persistence:** ENABLED (automatic caching on mobile)
**Security:** User-scoped rules (request.auth.uid == resource.data.userId)

### Collections Structure

```
firestore
├── budgets/{budgetId}
│   ├── id: String (auto-generated)
│   ├── userId: String (Firebase UID)
│   ├── name: String
│   ├── amount: Number
│   ├── period: String ('daily'|'weekly'|'monthly')
│   ├── startDate: Timestamp
│   ├── endDate: Timestamp
│   ├── createdAt: Timestamp
│   └── updatedAt: Timestamp
│
├── categories/{categoryId}
│   ├── id: String (auto-generated)
│   ├── userId: String (Firebase UID)
│   ├── name: String
│   ├── icon: String
│   ├── color: String
│   ├── createdAt: Timestamp
│   └── updatedAt: Timestamp
│
└── expenses/{expenseId}
    ├── id: String (auto-generated)
    ├── userId: String (Firebase UID)
    ├── categoryId: String
    ├── amount: Number
    ├── description: String (optional)
    ├── date: Timestamp
    ├── createdAt: Timestamp
    └── updatedAt: Timestamp
```

### Composite Indexes (Required)

Firestore requires composite indexes for queries that filter + sort on multiple fields:

```javascript
// Collection: budgets
// Fields: userId (Ascending) + startDate (Descending)

// Collection: categories
// Fields: userId (Ascending) + name (Ascending)

// Collection: expenses (3 indexes)
// Index 1: userId (Ascending) + date (Descending)
// Index 2: userId (Ascending) + categoryId (Ascending) + date (Descending)
// Index 3: categoryId (Ascending) + date (Descending)
```

**How to create:**
- Run the app → Click error links in console to auto-create
- OR go to Firebase Console → Firestore → Indexes → Create manually

### Security Rules (User-Scoped)

```javascript
// Each user can ONLY access their own data
// Enforced by: request.auth.uid == resource.data.userId

match /budgets/{budgetId} {
  allow read, write: if isAuthenticated() && isOwner(resource.data.userId);
  allow create: if isAuthenticated() && isOwner(request.resource.data.userId);
}
```

### Cascade Delete Behavior

**Note:** Firestore does NOT have built-in CASCADE DELETE like SQL databases.

**Implementation:** Client-side cascade delete in repositories:

```dart
// CategoryRepository: Delete category + all expenses in that category
Future<Either<DatabaseFailure, void>> delete(String id) async {
  // 1. Delete all expenses with this categoryId
  // 2. Delete the category
}
```

### Date Storage Format

```dart
// Firestore stores DateTime as Timestamp type
// Extensions in core/extensions.dart handle conversions

DART → FIRESTORE:
DateTime.now().toFirestoreTimestamp() → Timestamp

FIRESTORE → DART:
Timestamp.toDateTime() → DateTime

HELPERS:
date.startOfDay, date.endOfDay       // Day boundaries
date.startOfWeek, date.endOfWeek     // Week boundaries
date.startOfMonth, date.endOfMonth   // Month boundaries
date.isToday                          // bool check
```

---

## Use Cases

### All 24 Use Cases

```dart
// AUTH (8):
SignInWithEmail         (email, password) → UserEntity
SignUpWithEmail         (email, password, displayName?) → UserEntity
SignInWithGoogle        () → UserEntity
SignOut                 () → void
GetCurrentUser          () → UserEntity? (graceful degradation)
SendVerificationEmail   () → void
CheckEmailVerified      () → bool
ClearAllData            (userId) → void (delete all user data)

// BUDGET (4):
CreateBudget            (BudgetEntity) → BudgetEntity
GetBudgets              (userId) → List<BudgetEntity>
UpdateBudget            (BudgetEntity) → BudgetEntity
DeleteBudget            (id) → void

// CATEGORY (4):
CreateCategory          (CategoryEntity) → CategoryEntity
GetCategories           (userId) → List<CategoryEntity>
UpdateCategory          (CategoryEntity) → CategoryEntity
DeleteCategory          (id) → void (CASCADE DELETE expenses)

// EXPENSE (4):
CreateExpense           (ExpenseEntity) → ExpenseEntity
GetExpenses             (userId) → List<ExpenseEntity>
UpdateExpense           (ExpenseEntity) → ExpenseEntity
DeleteExpense           (id) → void
```

### Use Case Pattern

```dart
class CreateBudget {
  final BudgetRepository repository;

  CreateBudget(this.repository);

  Future<Either<DatabaseFailure, BudgetEntity>> call(BudgetEntity budget) {
    return repository.create(budget);
  }
}
```

---

## Services

### AuthService (ChangeNotifier)

```dart
class AuthService extends ChangeNotifier {
  UserEntity? _currentUser;
  bool _isLoading;
  String? _lastError;

  // Getters
  UserEntity? get currentUser;
  bool get isLoading;
  String? get lastError;
  bool get isUserLoggedIn;

  // Methods
  Future<Either<AuthFailure, UserEntity>> signInWithEmail({email, password}) async {
    _isLoading = true;
    notifyListeners();

    final result = await _signInUseCase(email: email, password: password);
    result.fold(
      (failure) => _lastError = failure.message,
      (user) => _currentUser = user,
    );

    _isLoading = false;
    notifyListeners();
    return result;
  }

  // signUpWithEmail, signInWithGoogle, signOut similar pattern
  // checkAuthState() → restores session on app startup
}
```

### BudgetService, CategoryService, ExpenseService (ChangeNotifiers)

```dart
class BudgetService extends ChangeNotifier {
  final BudgetUseCases useCases;
  final BudgetManager budgetManager;

  List<BudgetEntity> _budgets = [];
  BudgetHealthResult? _currentHealth;
  bool _isLoading = false;
  String? _lastError;

  // Methods: loadBudgets, createBudget, updateBudget, deleteBudget
  // refreshBudgetHealth (called after expense changes)
}
```

### BudgetManager (Domain Service)

```dart
class BudgetManager {
  final BudgetRepository _budgetRepo;
  final ExpenseRepository _expenseRepo;

  Future<Either<DatabaseFailure, BudgetHealthResult>> calculateBudgetHealth(userId) async {
    // 1. Get all budgets → filter active
    // 2. Get expenses in budget period (by date range)
    // 3. Calculate: totalExpenses, percentageUsed, shouldAlert (≥90%)
    // 4. Return BudgetHealthResult
  }

  Future<Either<DatabaseFailure, bool>> checkAlertTriggers(userId) async {
    final result = await calculateBudgetHealth(userId);
    return result.fold(
      (failure) => Left(failure),
      (health) => Right(health.shouldAlert),
    );
  }
}
```

---

## Budget Health Algorithm

### Calculation Steps

```dart
Step 1: Fetch all user budgets
  budgetRepository.getAll(userId)

Step 2: Filter for active budget
  budgets.firstWhere((b) => b.isActive)
  // isActive = current date within startDate/endDate
  If none → DatabaseFailure("No active budget")

Step 3: Fetch expenses in budget period
  expenseRepository.getAll(userId)
  → Filter by date range (startDate <= expense.date <= endDate)

Step 4: Calculate metrics
  totalExpenses = expenses.fold(0, (sum, e) => sum + e.amount)
  percentageUsed = (totalExpenses / budget.amount) * 100
  isOverBudget = totalExpenses > budget.amount
  shouldAlert = percentageUsed >= 90.0

Step 5: Return BudgetHealthResult
  BudgetHealthResult(
    userId, totalExpenses, budget.amount,
    percentageUsed, isOverBudget, shouldAlert,
    DateTime.now(),
  )
```

### Alert Thresholds

```
< 90%:  No alert
≥ 90%:  shouldAlert = true (warning)
≥ 100%: isOverBudget = true (critical)
```

---

## Error Handling

### Exception → Failure Flow

```dart
// DATA LAYER: Throw exceptions
if (snapshot.docs.isEmpty) throw FirestoreException('Not found');

// REPOSITORY: Catch → Convert to Failure
try {
  final result = await datasource.create(model);
  return Right(result);
} on FirestoreException catch (e) {
  return Left(DatabaseFailure(e.message));
}

// UI: Handle Either
result.fold(
  (failure) => showError(failure.message),
  (success) => showSuccess(),
);
```

### Either Type Pattern

```dart
Future<Either<Failure, Success>> operation() async {
  try {
    return Right(successValue);
  } catch (e) {
    return Left(Failure(e.message));
  }
}

// Usage:
final result = await operation();
result.fold(
  (failure) => print('Error: ${failure.message}'),
  (success) => print('Success: $success'),
);
```

---

## Provider Usage

### Dependency Injection (main.dart)

All dependencies are wired through manager classes:

```dart
// 1. Create Firestore instance
final firestore = FirebaseFirestore.instance;

// 2. Create all repositories (via RepositoryManager)
final repositoryManager = RepositoryManager(firestore);
final authRepository = repositoryManager.createAuthRepository();
final budgetRepository = repositoryManager.createBudgetRepository();
final categoryRepository = repositoryManager.createCategoryRepository();
final expenseRepository = repositoryManager.createExpenseRepository();

// 3. Create use case groups (via UseCaseManager)
final authUseCases = UseCaseManager.createAuthUseCases(authRepository);
final budgetUseCases = UseCaseManager.createBudgetUseCases(budgetRepository);
final categoryUseCases = UseCaseManager.createCategoryUseCases(categoryRepository);
final expenseUseCases = UseCaseManager.createExpenseUseCases(expenseRepository);

// 4. Create domain service
final budgetManager = BudgetManager(budgetRepository, expenseRepository);

// 5. Wire services (via ServiceManager)
MultiProvider(
  providers: [
    Provider.value(value: firestore),
    Provider.value(value: authRepository),
    Provider.value(value: budgetRepository),
    Provider.value(value: categoryRepository),
    Provider.value(value: expenseRepository),
    Provider.value(value: authUseCases),
    Provider.value(value: budgetUseCases),
    Provider.value(value: categoryUseCases),
    Provider.value(value: expenseUseCases),
    Provider.value(value: budgetManager),
    ...ServiceManager.createProviders(
      authUseCases: authUseCases,
      budgetUseCases: budgetUseCases,
      categoryUseCases: categoryUseCases,
      expenseUseCases: expenseUseCases,
      budgetManager: budgetManager,
    ),
  ],
  child: MyApp(),
)
```

### Consumer Pattern

```dart
Consumer<AuthService>(
  builder: (context, authService, child) {
    if (authService.isLoading) return CircularProgressIndicator();
    return Text(authService.currentUser?.displayName ?? 'Guest');
  },
)
```

### Read vs Watch

```dart
context.read<AuthService>()   // One-time access, no rebuild
context.watch<AuthService>()  // Listens, rebuilds on notifyListeners
```

---

## Building the UI

### Step 1: Build Budget List Screen

```dart
class BudgetListScreen extends StatefulWidget {
  @override
  _BudgetListScreenState createState() => _BudgetListScreenState();
}

class _BudgetListScreenState extends State<BudgetListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userId = context.read<AuthService>().currentUser!.id;
      context.read<BudgetService>().loadBudgets(userId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Budgets')),
      body: Consumer<BudgetService>(
        builder: (context, service, child) {
          if (service.isLoading) return Center(child: CircularProgressIndicator());
          if (service.lastError != null) {
            return Center(child: Text('Error: ${service.lastError}'));
          }

          return ListView.builder(
            itemCount: service.budgets.length,
            itemBuilder: (context, index) {
              final budget = service.budgets[index];
              return ListTile(
                title: Text(budget.name),
                subtitle: Text('PHP ${budget.amount} - ${budget.period}'),
                trailing: budget.isActive ? Chip(label: Text('Active')) : null,
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/budget/create'),
        child: Icon(Icons.add),
      ),
    );
  }
}
```

### Step 2: Handle Either in Forms

```dart
Future<void> _submitBudget() async {
  final budget = BudgetEntity(...);
  final result = await context.read<BudgetService>().createBudget(budget);

  result.fold(
    (failure) => ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error: ${failure.message}'), backgroundColor: Colors.red),
    ),
    (budget) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Budget created!'), backgroundColor: Colors.green),
      );
      Navigator.pop(context);
    },
  );
}
```

### Step 3: Budget Health Widget

```dart
Consumer<BudgetService>(
  builder: (context, service, child) {
    final health = service.currentHealth;
    if (health == null) return Text('No active budget');

    return Column(
      children: [
        Text('Spent: PHP ${health.totalExpenses.toStringAsFixed(2)}'),
        Text('Budget: PHP ${health.budgetAmount.toStringAsFixed(2)}'),
        Text('Remaining: PHP ${health.remainingAmount.toStringAsFixed(2)}'),
        LinearProgressIndicator(
          value: health.percentageUsed / 100,
          backgroundColor: Colors.grey[300],
          valueColor: AlwaysStoppedAnimation(
            health.shouldAlert ? Colors.red : Colors.green,
          ),
        ),
        if (health.shouldAlert)
          Chip(label: Text('90% Alert!'), backgroundColor: Colors.red),
        if (health.isOverBudget)
          Chip(label: Text('Over Budget'), backgroundColor: Colors.deepOrange),
      ],
    );
  },
)
```

---

## Testing

### Test Structure

```dart
@GenerateMocks([BudgetRepository, ExpenseRepository])
void main() {
  group('BudgetManager - Alert Tests', () {
    late BudgetManager manager;
    late MockBudgetRepository mockBudgetRepo;
    late MockExpenseRepository mockExpenseRepo;

    setUp(() {
      mockBudgetRepo = MockBudgetRepository();
      mockExpenseRepo = MockExpenseRepository();
      manager = BudgetManager(mockBudgetRepo, mockExpenseRepo);
    });

    test('should trigger alert at 90% usage', () async {
      when(mockBudgetRepo.getAll(any)).thenAnswer((_) async => Right([budget]));
      when(mockExpenseRepo.getAll(any))
          .thenAnswer((_) async => Right([expense90]));

      final result = await manager.checkAlertTriggers(userId);

      expect(result.isRight(), true);
      result.fold(
        (_) => fail('Should not fail'),
        (alert) => expect(alert, true),
      );
    });
  });
}
```

### Run Tests

```bash
flutter test  # 18/18 passing
```

---

## Complete File Reference

```
CORE (5):
  core/constants.dart         App/Firebase constants
  core/errors.dart            Exceptions & Failures
  core/extensions.dart        DateTime helpers
  core/logger.dart            Logging
  core/managers/              DI managers (4 files)

DOMAIN (5):
  domain/user_entity.dart
  domain/budget_entity.dart           + isActive getter
  domain/category_entity.dart
  domain/expense_entity.dart
  domain/budget_health_result.dart    + remainingAmount getter

DATA MODELS (4):
  data/models/user_model.dart         fromFirebase, toJson, toMap
  data/models/budget_model.dart       toMap, fromMap
  data/models/category_model.dart     toMap, fromMap
  data/models/expense_model.dart      toMap, fromMap

DATA SOURCES (5):
  data/sources/auth_remote_datasource.dart       Firebase Auth
  data/sources/auth_local_datasource.dart        SharedPreferences
  data/sources/budget_firestore_datasource.dart  Cloud Firestore
  data/sources/category_firestore_datasource.dart
  data/sources/expense_firestore_datasource.dart

REPOSITORIES (8):
  repositories/auth_repository.dart              Abstract
  repositories/auth_repository_impl.dart         2-layer implementation
  repositories/budget_repository.dart
  repositories/budget_repository_impl.dart
  repositories/category_repository.dart
  repositories/category_repository_impl.dart
  repositories/expense_repository.dart
  repositories/expense_repository_impl.dart

USE CASES (24):
  usecases/auth/ (8): sign_in_with_email, sign_up_with_email, sign_in_with_google,
                      sign_out, get_current_user, send_verification_email,
                      check_email_verified, clear_all_data
  usecases/budget/ (4): create, get, update, delete
  usecases/category/ (4): create, get, update, delete
  usecases/expense/ (4): create, get, update, delete

SERVICES (4):
  services/auth_service.dart          ChangeNotifier
  services/budget_service.dart        ChangeNotifier
  services/category_service.dart      ChangeNotifier
  services/expense_service.dart       ChangeNotifier

CONFIG (1):
  main.dart                           DI + bootstrap
```

---

## API Reference

### Entities

```dart
UserEntity: id, email?, displayName?, photoUrl?

BudgetEntity: id, userId, name, amount, period, startDate, endDate, createdAt, updatedAt
  → bool get isActive

CategoryEntity: id, userId, name, icon, color, createdAt, updatedAt

ExpenseEntity: id, userId, amount, description?, categoryId, date, createdAt, updatedAt

BudgetHealthResult: userId, totalExpenses, budgetAmount, percentageUsed, isOverBudget, shouldAlert, calculatedAt
  → double get remainingAmount
```

### Repositories

```dart
AuthRepository:
  signInWithEmail({email, password})              → Either<AuthFailure, UserEntity>
  signUpWithEmail({email, password, displayName}) → Either<AuthFailure, UserEntity>
  signInWithGoogle()                              → Either<AuthFailure, UserEntity>
  signOut()                                       → Either<AuthFailure, void>
  getCurrentUser()                                → Either<AuthFailure, UserEntity?>
  sendVerificationEmail()                         → Either<AuthFailure, void>
  checkEmailVerified()                            → Either<AuthFailure, bool>
  clearAllData(userId)                            → Either<AuthFailure, void>

BudgetRepository, CategoryRepository, ExpenseRepository:
  create(Entity)       → Either<DatabaseFailure, Entity>
  getAll(userId)       → Either<DatabaseFailure, List<Entity>>
  update(Entity)       → Either<DatabaseFailure, Entity>
  delete(id)           → Either<DatabaseFailure, void>
```

### Services

```dart
AuthService (ChangeNotifier):
  currentUser: UserEntity?
  isLoading: bool
  lastError: String?
  isUserLoggedIn: bool
  signInWithEmail({email, password})              → Either<AuthFailure, UserEntity>
  signUpWithEmail({email, password, displayName}) → Either<AuthFailure, UserEntity>
  signInWithGoogle()                              → Either<AuthFailure, UserEntity>
  signOut()                                       → Either<AuthFailure, void>
  checkAuthState()                                → Future<void>

BudgetService, CategoryService, ExpenseService (ChangeNotifiers):
  Similar pattern with state + CRUD methods

BudgetManager:
  calculateBudgetHealth(userId)  → Either<DatabaseFailure, BudgetHealthResult>
  checkAlertTriggers(userId)     → Either<DatabaseFailure, bool>
```

---

## Next Steps

1. ✅ Set up Firestore security rules (MANDATORY)
2. ✅ Create composite indexes (automatic or manual)
3. Build auth screens (login, signup, Google sign-in)
4. Build budget screens (list, create, edit, delete)
5. Build expense screens with category filtering
6. Implement budget health dashboard using `BudgetManager`
7. Add budget alerts when usage ≥ 90%

---

## Dependencies

```yaml
# State Management & Architecture
provider: ^6.1.1                       # Dependency injection & state
dartz: ^0.10.1                         # Either<Failure, Success> type
equatable: ^2.0.5                      # Value equality for entities

# Firebase (100% Free Tier)
firebase_core: ^3.15.2                 # Firebase initialization
firebase_auth: ^5.7.0                  # Email/password + OAuth
google_sign_in: ^6.3.0                 # Google OAuth provider
cloud_firestore: ^5.6.12               # Cloud Firestore database

# Local Storage (Session Cache)
shared_preferences: ^2.2.2             # Session cache

# Utilities
intl: ^0.18.1                          # Date/number formatting
flutter_local_notifications: ^17.2.4   # Budget alerts (90% threshold)

# Testing
mockito: ^5.4.4                        # Mocking repositories
build_runner: ^2.4.8                   # Code generation for mocks
```

---

## Cost Breakdown

### Current Architecture: $0/month (FREE Tier)

| Service             | Free Tier Limits        | Cost        |
|---------------------|-------------------------|-------------|
| Firebase Auth       | Unlimited users         | FREE        |
| Cloud Firestore     | 50k reads/day           | FREE        |
|                     | 20k writes/day          | FREE        |
|                     | 1GB storage             | FREE        |
| SharedPreferences   | Local session cache     | FREE        |
| **Total**           |                         | **$0/month**|

**Usage Estimates for Personal Use:**
- Reads: ~100-200/day (well under 50k limit)
- Writes: ~20-50/day (well under 20k limit)
- Storage: ~10-50MB (well under 1GB limit)

**Staying on FREE Tier:**
- Single user or small family use
- Personal budget tracking
- No heavy data operations
- Automatic offline caching reduces reads

---

**License**: Personal budget tracking app built with Flutter and Clean Architecture principles.