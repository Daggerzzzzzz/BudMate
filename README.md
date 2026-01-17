# BudMate

A mobile-based personal finance application with smart budget tracking for real-time expense management.

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=flat&logo=flutter&logoColor=white)
![Firebase](https://img.shields.io/badge/Firebase-FFCA28?style=flat&logo=firebase&logoColor=black)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=flat&logo=dart&logoColor=white)

## Features

- **Secure Authentication** - Google Sign-In and Email/Password via Firebase Auth
- **Budget Management** - Create and track monthly budgets with visual progress indicators
- **Expense Tracking** - Add, edit, and categorize expenses with predefined categories
- **Real-time Budget Health** - Monitor remaining balance, spent amount, and percentage used
- **Upcoming Expenses** - View bills sorted by due date
- **Budget Adjustments** - Add or subtract budget amounts with validation
- **Push Notifications** - Optional reminders for expense due dates
- **Multi-Currency Support** - PHP, USD, EUR, JPY, GBP
- **Bilingual** - English and Filipino language options
- **Dark/Light Mode** - Theme switching based on preference
- **Cloud Sync** - Firebase Firestore with offline persistence

## Tech Stack

| Category | Technology |
|----------|------------|
| Framework | Flutter |
| State Management | Provider |
| Backend | Firebase (Auth, Firestore) |
| Architecture | Clean Architecture |
| Error Handling | dartz (Either type) |

## Getting Started

### Prerequisites

- Flutter SDK (3.0+)
- Firebase project configured
- Android Studio / VS Code

### Installation

1. Clone the repository
```bash
git clone https://github.com/yourusername/budmate.git
cd budmate
```

2. Install dependencies
```bash
flutter pub get
```

3. Configure Firebase
   - Create a Firebase project at [Firebase Console](https://console.firebase.google.com)
   - Enable Email/Password and Google Sign-In authentication
   - Add `google-services.json` to `android/app/`

4. Run the app
```bash
flutter run
```

## Project Structure

```
lib/
├── core/           # Constants, errors, extensions, managers
├── data/           # Models and data sources
├── domain/         # Entities (business logic)
├── repositories/   # Repository pattern implementation
├── services/       # State management (ChangeNotifier)
├── usecases/       # Single-responsibility actions
├── ui/             # Screens and widgets
└── main.dart       # App entry point
```

## Architecture

Built with **Clean Architecture** principles:

- **Presentation Layer** - UI screens, widgets, Provider state management
- **Domain Layer** - Entities, repository interfaces, use cases
- **Data Layer** - Models, Firebase data sources, repository implementations

## License

This project is for educational purposes.

---

*Built with Flutter and Firebase*
