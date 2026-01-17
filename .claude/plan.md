# Implementation Plan: Fix BLASTBufferQueue Spam (Root Cause Analysis)

## Problem Summary

BLASTBufferQueue spam appears after 5 minutes of idle time, despite previous NetworkImage fixes. Deep analysis reveals the **root cause is MediaQuery.of(context) and Theme.of(context) triggering cascading rebuild loops**.

## Root Cause Analysis

### Critical Issue: MediaQuery.of(context) Rebuild Cascade

**Files Affected:**
1. `lib/ui/navigation/widgets/maribank_budget_card.dart:39-40` - Calls MediaQuery in build method
2. `lib/ui/navigation/home_screen.dart:116` - Calls MediaQuery inside Consumer2 builder
3. `lib/ui/shared/profile_header.dart:40` - Calls MediaQuery (already has LayoutBuilder wrapper)

**Why This Causes BLASTBufferQueue Spam:**

```
MediaQuery.of(context) in build method
    ↓
Registers widget as dependent on MediaQuery InheritedWidget
    ↓
Every system layout change → MediaQuery notifies all dependents
    ↓
On some Android devices, MediaQuery fires continuously (every few seconds)
    ↓
MaribankBudgetCard + HomeScreen rebuild on every MediaQuery change
    ↓
Rebuilds trigger NetworkImage to reload (even with onBackgroundImageError)
    ↓
Continuous image decode requests exhaust graphics buffers
    ↓
BLASTBufferQueue: "Can't acquire next buffer. Already acquired max frames 8"
```

### Secondary Issue: Redundant Consumer2 Wrapper

**File:** `lib/ui/navigation/home_screen.dart:110-153`

Current structure:
```dart
Consumer2<BudgetService, ExpenseService>(
  builder: (context, budgetService, expenseService, _) {
    final screenHeight = MediaQuery.of(context).size.height;  // ← PROBLEM
    return SingleChildScrollView(
      child: Column(
        children: [
          Consumer<BudgetService>(...),  // ← Redundant filtering
          Consumer<ExpenseService>(...), // ← Redundant filtering
        ],
      ),
    );
  },
)
```

**Problem:** Consumer2 watches BOTH services → rebuilds entire tree when either changes → MediaQuery.of() runs on line 116 → cascade begins

### Tertiary Issue: Multiple notifyListeners() in BudgetService

**File:** `lib/services/budget_service.dart`

Current flow in `loadBudgets()`:
```dart
_setLoading(true);           // notifyListeners() #1
// ... async operation ...
_setLoading(false);          // notifyListeners() #2
refreshBudgetHealth(userId); // notifyListeners() #3 (in success branch line 176)
```

**Result:** 3 notifications for single operation → triple rebuilds → amplifies MediaQuery cascade

## Implementation Strategy

### Fix 1: Remove MediaQuery.of(context) from MaribankBudgetCard ✅ CRITICAL

**File:** `lib/ui/navigation/widgets/maribank_budget_card.dart`

**Change lines 38-40:**
```dart
// BEFORE:
Widget build(BuildContext context) {
  final screenWidth = MediaQuery.of(context).size.width;
  final screenHeight = MediaQuery.of(context).size.height;

// AFTER:
Widget build(BuildContext context) {
  // No MediaQuery - use LayoutBuilder wrapper from parent
  // Parent will pass constraints via parameters
```

**Strategy:** Wrap MaribankBudgetCard in LayoutBuilder at the Consumer level and pass sizing via constructor parameters.

**Why this works:** LayoutBuilder only rebuilds when constraints change (rare), not on every MediaQuery notification.

---

### Fix 2: Remove Consumer2 and MediaQuery from HomeScreen ✅ CRITICAL

**File:** `lib/ui/navigation/home_screen.dart`

**Change lines 110-153:**
```dart
// BEFORE:
Consumer2<BudgetService, ExpenseService>(
  builder: (context, budgetService, expenseService, _) {
    final screenHeight = MediaQuery.of(context).size.height;
    return SingleChildScrollView(...);
  },
)

// AFTER:
LayoutBuilder(
  builder: (context, constraints) {
    final screenHeight = constraints.maxHeight;
    return Column(
      children: [
        Consumer<BudgetService>(...),
        Consumer<ExpenseService>(...),
      ],
    );
  },
)
```

**Why this works:**
- Removes Consumer2 redundancy
- Uses LayoutBuilder constraints instead of MediaQuery
- Each Consumer only rebuilds when its specific service changes

---

### Fix 3: Cache Theme.of(context) in MaribankBudgetCard ✅ HIGH

**File:** `lib/ui/navigation/widgets/maribank_budget_card.dart`

**Change lines 52-54:**
```dart
// BEFORE:
colors: [
  Theme.of(context).colorScheme.primary,
  Theme.of(context).colorScheme.primary.withValues(alpha: 0.8),
],

// AFTER:
Widget build(BuildContext context) {
  final theme = Theme.of(context);
  final primaryColor = theme.colorScheme.primary;
  // ... later in build:
  colors: [
    primaryColor,
    primaryColor.withValues(alpha: 0.8),
  ],
```

**Why this works:** Single Theme.of() call instead of multiple - reduces InheritedWidget lookups

---

### Fix 4: Consolidate notifyListeners() in BudgetService ✅ MEDIUM

**File:** `lib/services/budget_service.dart`

**Change lines 52-74:**
```dart
// BEFORE:
Future<void> loadBudgets(String userId) async {
  _setLoading(true);  // notifyListeners()
  final result = await _budgetUseCases.get.call(userId);
  result.fold(
    (failure) {
      _setError(failure.message);  // notifyListeners()
      _budgets = [];
      _setLoading(false);  // notifyListeners()
    },
    (budgets) {
      _budgets = budgets;
      _setLoading(false);  // notifyListeners()
      refreshBudgetHealth(userId);  // notifyListeners() AGAIN
    },
  );
}

// AFTER:
Future<void> loadBudgets(String userId) async {
  _setLoading(true);  // notifyListeners() #1
  final result = await _budgetUseCases.get.call(userId);
  result.fold(
    (failure) {
      _setErrorSilent(failure.message);  // No notify
      _budgets = [];
      _setLoading(false);  // notifyListeners() #2 (final)
    },
    (budgets) {
      _budgets = budgets;
      _setLoadingSilent(false);  // No notify
      refreshBudgetHealth(userId);  // notifyListeners() #2 (final)
    },
  );
}

// Add silent helper methods:
void _setLoadingSilent(bool loading) {
  _isLoading = loading;
  // No notifyListeners()
}

void _setErrorSilent(String error) {
  _lastError = error;
  // No notifyListeners()
}
```

**Why this works:** Reduces 3 notifications to 2 → fewer rebuilds

---

## Expected Results

### Before Fixes:
```
[5 minutes idle]
E/BLASTBufferQueue: Can't acquire next buffer. Already acquired max frames 8
E/BLASTBufferQueue: Can't acquire next buffer. Already acquired max frames 8
E/BLASTBufferQueue: Can't acquire next buffer. Already acquired max frames 8
(continuous spam...)
```

### After Fixes:
```
[5+ minutes idle]
D/ProfileInstaller: Installing profile for com.example.budmate
W/example.budmate: userfaultfd: MOVE ioctl seems unsupported
(Clean terminal - NO BLASTBufferQueue errors)
```

## Testing Plan

1. Apply all 4 fixes
2. Run `flutter run` on TECNO device
3. Let app sit idle for **10 minutes** (double the spam trigger time)
4. Monitor terminal output for BLASTBufferQueue errors
5. Navigate between tabs during idle period to test IndexedStack
6. Verify no spam appears

## Files Modified Summary

| File | Lines | Change Type |
|------|-------|-------------|
| `lib/ui/navigation/widgets/maribank_budget_card.dart` | 38-40, 52-54 | Remove MediaQuery, cache Theme |
| `lib/ui/navigation/home_screen.dart` | 110-153 | Replace Consumer2 + MediaQuery with LayoutBuilder |
| `lib/services/budget_service.dart` | 52-74, 180-193 | Consolidate notifyListeners() |

## Implementation Notes

- **DO NOT** add RepaintBoundary to ProfileHeader (already has Selector optimization)
- **DO NOT** change IndexedStack to PageView (would break navigation state)
- **DO NOT** remove const from constructors (that was a red herring)
- **KEEP** the existing NetworkImage onBackgroundImageError fixes

This plan directly addresses the root cause: **MediaQuery.of(context) dependency cascades amplified by redundant Consumer wrappers and excessive service notifications**.
