# CodeAlpha StudyCard App 📱✨

A state-of-the-art, feature-rich Flashcard Study application built with **Flutter** and **Material Design 3**. This project was developed as a submission for the **CodeAlpha Internship** and is fully polished, optimized, and ready for evaluation.

It integrates advanced features such as **Google Gemini AI** for dynamic card generation, a local study statistics dashboard, customizable multi-color themes (Light/Dark mode), and custom category management.

---

## 🌟 Key Features

*   **🤖 AI-Powered Flashcard Generation**: Integrates the **Google Gemini 2.5 Flash API** to dynamically generate 10 high-quality educational flashcards based on interactive topics at the touch of a button.
*   **📊 Study Statistics & Analytics**: Track your learning progress with a dedicated stats dashboard displaying total study sessions, cards reviewed, cards mastered, and an interactive **daily streak tracker**.
*   **🎨 Premium Custom Theming**: Full Material 3 implementation featuring elegant Light and Dark modes. Includes four curated preset color schemes:
    *   `Purple` (Deep Purple)
    *   `Sunset` (Deep Orange)
    *   `Ocean` (Teal)
    *   `Forest` (Emerald Green)
*   **📁 Custom Category Management (CRUD)**: Create, edit, and delete topics. Select custom colors and icons for each category. Dynamic cards automatically reassign to standard categories when their original category is deleted.
*   **💾 Local Storage Persistence**: Seamlessly saves your custom flashcards, custom categories, auth session, theme mode, and study statistics locally using a serialized JSON database model built over `SharedPreferences`.
*   **🔒 Auth & User Profiles**: Complete Mock authentication flow supporting SignUp, Login, Forgot Password, and a quick "Continue as Guest" mode, complete with subscription tiers (`Basic`, `Plus`, `Pro`).
*   **✨ Advanced UI/UX & Animations**: Smooth card-flipping micro-animations using custom widgets, animated progress bars, responsive layouts, and modern visual styling.

---

## 🛠️ Technology Stack & Libraries

*   **Framework**: [Flutter SDK](https://flutter.dev) (v3.44.2+)
*   **Language**: [Dart](https://dart.dev) (v3.12.2+)
*   **State Management**: `provider` (MultiProvider architecture for global access to Auth, Study, and Theme states)
*   **Local Database**: `shared_preferences`
*   **API Client**: `http` (configured with exponential backoff and rate-limit retries)
*   **Configuration**: `flutter_dotenv` (for secure API key storage)

---

## 📂 Project Architecture

```text
StudyCards APP/
├── lib/
│   ├── main.dart                       # App bootstrapper, MultiProvider setup, and theme router
│   ├── models/
│   │   ├── category.dart               # Category data model and icon/color serializations
│   │   ├── flashcard.dart              # Flashcard model with copyWith and JSON parsers
│   │   └── study_stats.dart            # Analytics stats & daily streak calculation model
│   ├── providers/
│   │   ├── auth_provider.dart          # Manages login/signup, profiles, and guest access sessions
│   │   ├── study_provider.dart         # Core provider managing CRUD, API sync, and analytics
│   │   └── theme_provider.dart         # Controls Light/Dark toggles and the seed color palettes
│   ├── screens/
│   │   ├── auth/                       # Authentication screens (Login, SignUp, Welcome)
│   │   ├── categories/                 # Custom Categories management dashboard
│   │   ├── flashcards/                 # Study dashboard, swipe/flip study cards, and CRUD forms
│   │   ├── profile/                    # User settings, sub upgrades, and profile dashboard
│   │   └── statistics/                 # Analytics graphs and learning progress tracker
│   ├── services/
│   │   ├── flashcard_api_service.dart  # Gemini 2.5 API service with exponential backoff
│   │   └── storage_service.dart        # JSON-based SharedPreferences storage manager
│   └── widgets/
│       └── flip_card_widget.dart       # High-performance 3D-rotation card-flipping widget
├── test/
│   └── widget_test.dart                # Widget smoke tests validating rendering and timers
├── .env                                # Local environment secrets config (API Keys)
├── pubspec.yaml                        # Project assets, dependencies, and environment config
└── README.md                           # Documentation & Evaluator setup guide
```

---

## ⚙️ Setup & Installation

### Prerequisites
1.  Install the **Flutter SDK** (compatible with v3.22.0 up to the latest v3.44.2 stable release).
2.  Set up an emulator or connect a physical development device.
3.  Obtain a free **Google Gemini API Key** from [Google AI Studio](https://aistudio.google.com/).

### Installation Steps

1.  **Clone the Repository**:
    ```bash
    git clone https://github.com/kavypatel-pro/CodeAlpha_studycard.git
    cd CodeAlpha_studycard
    ```

2.  **Install Dependencies**:
    ```bash
    flutter pub get
    ```

3.  **Setup Environment Secrets**:
    Create a file named `.env` in the root directory and add your Google Gemini API Key:
    ```env
    FLASHCARD_API_KEY=your_gemini_api_key_here
    ```

4.  **Run Tests**:
    Verify that all unit and widget tests pass:
    ```bash
    flutter test
    ```

5.  **Run the Application**:
    ```bash
    flutter run
    ```

---

## 🧑‍🏫 Evaluation & Verification

To verify that the application complies with all static analysis rules and runs flawlessly:

1.  **Static Analysis**:
    Ensure the codebase is 100% clean and contains zero warnings or deprecations:
    ```bash
    flutter analyze
    ```
2.  **Release Build (Web)**:
    Build a optimized release build with full icon tree-shaking:
    ```bash
    flutter build web --release
    ```

---
*Created as part of the CodeAlpha Internship program.*
