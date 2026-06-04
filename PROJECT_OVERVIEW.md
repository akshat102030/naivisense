# NaiviSense - Project Overview & Features

## 🎯 Project Description
**NaiviSense** is an AI-powered therapy coordination platform designed to manage therapy sessions, child profiles, and treatment plans for therapy centers. The app supports three main user roles: **Therapists**, **Parents**, and **Center Heads** (administrators).

---

## 🏗️ Architecture Overview

### Tech Stack
- **Framework**: Flutter (Dart)
- **State Management**: Flutter Riverpod (async notifiers)
- **Routing**: GoRouter with role-based navigation
- **Storage**: Shared Preferences + Hive (local persistence)
- **Networking**: Dio HTTP client
- **UI Libraries**: Material Design, FL Chart, Google Fonts, Cached Network Images

### Project Structure
```
naivisense/
├── lib/
│   ├── main.dart                 # App entry point
│   ├── features/                 # Feature modules
│   │   ├── auth/                 # Authentication
│   │   ├── therapist/            # Therapist feature
│   │   ├── parent/               # Parent feature
│   │   ├── center_head/          # Admin/Center Head feature
│   │   └── reports/              # Reporting feature
│   ├── data/
│   │   ├── models/               # Data models
│   │   ├── repositories/         # Repository pattern for data access
│   │   └── services/             # API, storage, error handling
│   └── core/
│       ├── theme/                # App theming & colors
│       ├── routing/              # GoRouter configuration
│       └── constants/            # App constants
```

---

## ✨ Implemented Features

### 1. **Authentication System**
- **Login Screen** (`auth/screens/login_screen.dart`)
  - Phone number + password authentication
  - Form validation (phone, password)
  - Error display handling
  - Role-based redirect on successful login
  
- **Auth Provider** (`auth/providers/auth_provider.dart`)
  - Manages authentication state (authenticated/unauthenticated)
  - Token storage and retrieval
  - User session management
  - Logout functionality
  
- **Auth Repository** (`data/repositories/auth_repository.dart`)
  - API communication for login/register
  - Token persistence
  - User data retrieval (`/auth/me`)

### 2. **Therapist Features**
- **Therapist Home Screen** (`therapist/screens/therapist_home_screen.dart`)
  - Dashboard with therapy sessions list
  - Navigation to child profiles
  - Session management

- **Create Session Screen** (`therapist/screens/create_session_screen.dart`)
  - Form to create new therapy sessions
  - Session scheduling
  - Child selection

- **Therapist Child Profile Screen** (`therapist/screens/therapist_child_profile_screen.dart`)
  - View child details from therapist perspective
  - Session history
  - Progress tracking

- **Session Notes Screen** (`therapist/screens/session_notes_screen.dart`)
  - Document therapy session notes
  - Session observations

- **Diet Plan Feature** (NEW - In Progress)
  - Models: `DietPlanModel`, `Meal` class
  - Repository: `diet_plans_repository.dart`
  - Support for meal planning (breakfast, lunch, dinner, snacks)
  - Calorie tracking and meal frequency management

### 3. **Parent Features**
- **Parent Home Screen** (`parent/screens/parent_home_screen.dart`)
  - View enrolled children
  - Access child details
  - Monitor therapy progress

- **Child Detail Screen** (`parent/screens/child_detail_screen.dart`)
  - Detailed child profile view
  - Therapy session history
  - Progress metrics

- **Raise Alert Screen** (`parent/screens/raise_alert_screen.dart`)
  - Alert/concern submission to center
  - Communication feature for parents

### 4. **Center Head (Admin) Features**
- **Center Head Home Screen** (`center_head/screens/center_head_home_screen.dart`)
  - Admin dashboard
  - Center management
  - User oversight

- **Enrollment Wizard Screen** (`center_head/screens/enrollment_wizard_screen.dart`)
  - Multi-step child enrollment process
  - Form validation
  - Child onboarding

- **Admin Child Report Screen** (`center_head/screens/admin_child_report_screen.dart`)
  - Comprehensive child analytics
  - Therapy progress reports
  - Center statistics

### 5. **Reporting & Analytics**
- **Weekly Report Screen** (`reports/screens/weekly_report_screen.dart`)
  - Generate weekly therapy reports
  - Progress visualization (FL Chart integration)
  - Metrics and analytics

- **Reports Provider** (`reports/providers/reports_provider.dart`)
  - Report data state management

### 6. **Data Models**
- **UserModel** - User authentication and profile
- **ChildModel** - Child/patient information
- **SessionModel** - Therapy session details
- **HomePlanModel** - Home exercise/therapy plans
- **AlertModel** - Parent alerts/concerns
- **DietPlanModel** - Dietary plans with meal details (NEW)

### 7. **Storage & Persistence**
- **StorageService** - Token and user info caching
- **Hive Integration** - Local data persistence for offline access
- **Shared Preferences** - Session storage

---

## 🐛 Current Issues Found

### Lint/Code Quality Issues (13 found)

1. **Missing Braces in Flow Control** (2 issues)
   - `lib/data/models/child.dart:41`
   - `lib/features/center_head/screens/enrollment_wizard_screen.dart:875`
   - Fix: Wrap single-statement `if` blocks in braces

2. **Unnecessary Underscores** (5 issues)
   - Multiple underscore usage indicating unused variables
   - Locations:
     - `admin_child_report_screen.dart:520, 552`
     - `child_detail_screen.dart:415`
     - `parent_home_screen.dart:61`
     - `therapist_child_profile_screen.dart:314, 401, 422`
   - Fix: Remove extra underscores or use the variables

3. **Deprecated API Usage** (4 issues)
   - `value` → use `initialValue` instead (TextFormField)
     - `enrollment_wizard_screen.dart:364, 694`
     - `create_session_screen.dart:122`
   - `activeColor` → use `activeThumbColor` for Switch
     - `enrollment_wizard_screen.dart:808`

---

## 🔧 Debug Information

### Git Status
```
Modified Files:
- app_colors.dart (theme updates)
- user.dart (user model changes)
- home_plans_repository.dart
- storage_service.dart
- Multiple provider files (parent, therapist, center_head)
- Multiple screen files with updates

Untracked Files (In Progress):
- diet_plan.dart (new model)
- diet_plans_repository.dart (new repository)
- therapist_child_profile_screen.dart (new screen)
```

### Recent Commit
```
a7f1c2f - Initial commit: NaiviSense — AI-powered therapy coordination platform
```

---

## 🚀 Next Steps / In-Progress Work

1. **Diet Plan Feature Integration**
   - Models and repository are created
   - Need to integrate into therapist workflow
   - Add UI screens for diet plan management

2. **Fix Lint Issues**
   - Replace deprecated APIs
   - Add proper braces to flow control statements
   - Clean up unused underscore variables

3. **Backend API Integration**
   - Ensure all endpoints are properly connected
   - Error handling for API failures
   - Token refresh mechanism

4. **Testing**
   - Unit tests for providers
   - Widget tests for screens
   - Integration tests for API communication

---

## 📱 How to Run

```bash
cd naivisense
flutter pub get
flutter run
```

### Test Credentials
- Check backend documentation for test user credentials
- Login with phone number (+91 format) and password

---

## 🔐 Security Considerations
- Tokens stored in SharedPreferences (consider using FlutterSecureStorage for sensitive tokens)
- HTTPS enforced for API communication (Dio)
- User roles enforced at navigation level

---

## 📝 API Endpoints Referenced
- `POST /auth/login` - User authentication
- `POST /auth/register` - User registration
- `GET /auth/me` - Get current user
- `POST /auth/logout` - User logout
- Additional endpoints for therapist, parent, and center head features

