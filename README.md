# StudySnap Kids AI 📚

> AI-powered learning app — scan worksheets into flashcards, quizzes and explanations.

## Architecture

Clean Architecture with three layers:

```
Presentation  →  Riverpod (AsyncNotifier) + Flutter widgets
Domain        →  Entities + Repository interfaces + Use cases
Data          →  Drift (SQLite) + Dio (Claude API) + Implementations
```

## Tech Stack

| Concern | Package |
|---------|---------|
| Navigation | go_router 14 |
| State | flutter_riverpod 2 + riverpod_annotation |
| Models | freezed + json_serializable |
| Local DB | drift (SQLite, type-safe, reactive) |
| Secure storage | flutter_secure_storage |
| API client | dio + pretty_dio_logger |
| Scanning | cunning_document_scanner (native iOS) |
| OCR | google_mlkit_text_recognition (on-device) |
| Biometrics | local_auth (Face ID / fingerprint) |
| Animations | flutter_animate |
| Fonts | google_fonts (Nunito for Kid Mode) |
| Logging | logger |

## Project Structure

```
lib/
├── main.dart
├── core/
│   ├── config/
│   │   ├── app_constants.dart     ← All constants
│   │   └── app_env.dart           ← .env config
│   ├── database/
│   │   ├── app_database.dart      ← Drift DB + schema
│   │   ├── tables/                ← All table definitions
│   │   └── daos/                  ← All data access objects
│   ├── error/
│   │   └── result.dart            ← Result<T> + AppException hierarchy
│   ├── network/
│   │   └── api_client.dart        ← Dio + interceptors + retry
│   ├── providers/
│   │   └── app_providers.dart     ← Riverpod DI wiring
│   ├── router/
│   │   └── app_router.dart        ← go_router (all 30 routes)
│   └── theme/
│       ├── app_colours.dart
│       ├── app_text_styles.dart
│       └── app_theme.dart
├── data/
│   ├── datasources/
│   │   └── remote/
│   │       └── claude_service.dart ← Claude API integration
│   ├── models/                     ← Freezed JSON models
│   └── repositories/
│       ├── repository_impls.dart   ← Concrete implementations
│       └── mappers.dart            ← DB row ↔ Entity mappers
├── domain/
│   ├── entities/                   ← Pure business objects (Freezed)
│   ├── repositories/
│   │   └── repositories.dart       ← Abstract interfaces
│   └── usecases/                   ← Single-responsibility use cases
├── features/
│   ├── onboarding/                 ← S01–S08
│   ├── parent/                     ← S09–S16 + sPQ + sSS + sCT
│   ├── kid/                        ← S17–S21
│   └── settings/                   ← S22–S25
└── shared/
    └── widgets/                    ← Reusable UI components
```

## Setup

### 1. Prerequisites
- Flutter SDK ≥ 3.3 (stable channel)
- Xcode ≥ 15 (for iOS)
- Android Studio / VS Code

### 2. Clone & install
```bash
git clone https://github.com/manojwebdeveloper/studysnap-kids-ai.git
cd studysnap-kids-ai
flutter pub get
```

### 3. Environment
```bash
cp .env.example .env
# Edit .env and add your Anthropic API key
```

### 4. Code generation
```bash
dart run build_runner build --delete-conflicting-outputs
```

### 5. Run
```bash
flutter run
```

## Branches

| Branch | Section | Status |
|--------|---------|--------|
| `main` | Stable | — |
| `feature/core` | Core architecture | ✅ |
| `feature/onboarding` | S01–S08 | ✅ |
| `feature/parent-mode` | S09–S16 | ✅ |
| `feature/kid-mode` | S17–S21 | ✅ |
| `feature/settings` | S22–S25 | ✅ |

## Key Decisions

- **Drift over Hive/Isar** — type-safe, reactive streams, proper relations, SQL power when needed
- **Result<T> pattern** — forces explicit error handling, no silent failures
- **On-device OCR** — privacy-first, no API cost, works offline
- **Freezed** — immutable models, copyWith, pattern matching, JSON
- **Repository pattern** — swappable data sources, testable, clean domain layer
