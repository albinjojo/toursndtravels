# Alphonsa Van Service

> A Flutter + Firebase mobile application for managing school van routes, student pickups, and daily trip lists — designed for use by school van drivers in the field.

![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart&logoColor=white)
![Firebase](https://img.shields.io/badge/Firebase-Firestore-FFCA28?logo=firebase&logoColor=black)
![Riverpod](https://img.shields.io/badge/State-Riverpod_2.6-00B4D8)
![Version](https://img.shields.io/badge/version-2.0.0-brightgreen)
![Platform](https://img.shields.io/badge/platform-Android%20%7C%20iOS-lightgrey)

---

## Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Tech Stack](#tech-stack)
- [Architecture](#architecture)
- [Project Structure](#project-structure)
- [Data Models & Firestore Schema](#data-models--firestore-schema)
- [Getting Started](#getting-started)
- [Firebase Setup](#firebase-setup)
- [Building for Production](#building-for-production)
- [Screens](#screens)

---

## Overview

Alphonsa Van Service is a purpose-built field tool for school van drivers. The driver selects their assigned school, views the full student roster with trip assignments, applies route-specific filters, and builds or loads saved student lists for morning and evening runs. Lists can be exported as formatted PDFs or WhatsApp-ready text messages directly from the device.

The app is designed for daily outdoor use: large touch targets, high-contrast badges, and a compact card layout that is readable at a glance while standing.

---

## Features

| Category | Capability |
|---|---|
| **School Management** | Select from multiple schools; each school maintains its own isolated student roster |
| **Student CRUD** | Add, edit, delete students with name, grade, division, pickup point, trip assignment, and two contact numbers |
| **Trip Assignment** | Per-student FIRST / SECOND trip assignment for both To School and From School directions |
| **Multi-Select Filters** | Filter by Grade, Division, To School trip, and From School trip simultaneously (AND across categories, OR within) |
| **Live Search** | Real-time search across student name and pickup point |
| **Saved Route Lists** | Create named, filtered student subsets persisted to Firestore for reuse on future runs |
| **PDF Export** | Generate a formatted A4 PDF roster with school name, date, active filters, and a numbered student table |
| **WhatsApp Text Export** | Format a share-ready student list with emoji section headers and student details |
| **Clipboard Copy** | One-tap copy of the formatted list |
| **Direct Dial** | Tap any phone number on the student detail screen to open the system dialer |
| **Offline-Tolerant** | Firestore local persistence keeps data accessible without a network connection |

---

## Tech Stack

| Layer | Technology |
|---|---|
| UI Framework | Flutter 3.x · Material 3 (`useMaterial3: true`) |
| Language | Dart 3.x |
| State Management | [Riverpod](https://riverpod.dev) 2.6.x — `Provider`, `FutureProvider.family`, `NotifierProvider` |
| Navigation | [go_router](https://pub.dev/packages/go_router) 14.x — `StatefulShellRoute.indexedStack` |
| Backend | Firebase Anonymous Auth + Cloud Firestore 6.x |
| PDF Generation | `pdf` 3.10.x + `printing` 5.12.x |
| Sharing | `share_plus` 10.x · `url_launcher` 6.x |
| Fonts | `google_fonts` 6.x (Roboto) |
| Linting | `flutter_lints` 6.x — zero warnings policy |

---

## Architecture

The project follows **Clean Architecture** with a **Repository Pattern**, keeping business logic decoupled from both the UI layer and the Firebase implementation.

```
┌──────────────────────────────────────────────┐
│               Presentation Layer              │
│   Screens · Widgets · Riverpod Providers      │
└──────────────────┬───────────────────────────┘
                   │ depends on (abstract interface only)
┌──────────────────▼───────────────────────────┐
│             Repository Interfaces             │
│   SchoolRepository                            │
│   StudentRepository                           │
│   ListRepository                              │
└──────────────────┬───────────────────────────┘
                   │ implemented by
┌──────────────────▼───────────────────────────┐
│           Firebase Implementations            │
│   *_impl.dart  →  Cloud Firestore SDK         │
└──────────────────────────────────────────────┘
```

### Key Design Decisions

**Repository abstraction.** Abstract interfaces in `lib/repositories/` are the only types providers and screens ever import. Firestore implementations live alongside them as `*_impl.dart`. Swapping the data source requires changing only the provider registration.

**Client-side filtering.** `StudentFilters` is an immutable value class with a `matches(Student)` predicate. All filter logic runs client-side after the initial Firestore fetch. This avoids composite index requirements and keeps the filter logic testable without a database.

**Embedded snapshots in saved lists.** `SavedListModel` embeds a `List<StudentSummary>` snapshot inside the Firestore document. A saved route list renders correctly even after the underlying student records are edited or deleted — no additional queries required.

**Anonymous Auth.** Firebase Anonymous Authentication is initialised at startup and used as the Firestore security context. No user-facing sign-in flow is required.

**`copyWith` sentinel pattern.** Nullable fields like `toSchoolTrip` and `fromSchoolTrip` use a private `_sentinel` object so that explicitly passing `null` is distinguishable from omitting the parameter in `copyWith`.

---

## Project Structure

```
lib/
├── app.dart                         # MaterialApp root, theme wiring
├── main.dart                        # Firebase init, anonymous auth, runApp
├── firebase_options.dart            # Generated by FlutterFire CLI
│
├── core/
│   ├── constants/
│   │   └── app_colors.dart          # Single source of truth for all colours
│   ├── services/
│   │   ├── pdf_export_service.dart  # A4 PDF generation (pdf package)
│   │   └── text_export_service.dart # WhatsApp-formatted text roster
│   └── theme/
│       └── app_theme.dart           # Material 3 ThemeData
│
├── models/
│   ├── school.dart
│   ├── student.dart                 # Full student entity with copyWith + equality
│   ├── student_summary.dart         # Lightweight snapshot embedded in SavedList
│   ├── saved_list_model.dart        # Saved route list with embedded student data
│   └── trip_type.dart               # Enum: first | second
│
├── repositories/
│   ├── school_repository.dart       # Abstract interface
│   ├── school_repository_impl.dart  # Firestore implementation
│   ├── student_repository.dart
│   ├── student_repository_impl.dart
│   ├── list_repository.dart
│   └── list_repository_impl.dart
│
├── providers/
│   ├── school_providers.dart        # selectedSchoolProvider, schoolsProvider
│   ├── student_providers.dart       # studentsProvider, StudentFilters, filteredStudentsProvider
│   └── list_providers.dart          # savedListsProvider, listRepositoryProvider
│
├── routing/
│   └── app_router.dart              # GoRouter config + AppRoutes constants
│
└── presentation/
    ├── screens/
    │   ├── splash/                  # Animated logo + dots; auto-navigates after 2.5 s
    │   ├── school_selection/        # Pick the active school
    │   ├── home/                    # HomeShell — StatefulShellRoute bottom nav
    │   ├── students/
    │   │   ├── students_screen.dart          # Roster with multi-select filters + search
    │   │   ├── student_detail_screen.dart    # Full profile; call button; edit/delete
    │   │   └── add_edit_student_screen.dart  # Create / update student form
    │   ├── lists/
    │   │   ├── lists_hub_screen.dart         # All saved lists for the current school
    │   │   ├── create_list_screen.dart       # Filter → select students → name → save
    │   │   └── saved_list_view_screen.dart   # View roster; PDF / text / clipboard export
    │   └── settings/
    │       └── settings_screen.dart
    └── widgets/
        ├── common/
        │   ├── filter_chip_button.dart    # Reusable filter chip with label + arrow
        │   ├── trip_badge.dart            # FIRST / SECOND coloured status chip
        │   ├── info_row.dart
        │   └── settings_tile.dart
        ├── student/
        │   ├── student_card.dart          # List tile card + shared GradeBadge widget
        │   └── student_avatar.dart        # Colour-cycled initials avatar
        └── lists/
            ├── list_card.dart
            └── export_bottom_sheet.dart   # PDF / Text / Clipboard export bottom sheet
```

---

## Data Models & Firestore Schema

### Collections

```
schools/                              (root collection)
  {schoolId}/
    name           : String
    active         : bool
    createdAt      : Timestamp

    students/                         (subcollection)
      {studentId}/
        name             : String
        nickname         : String
        grade            : int         # -2 = LKG · -1 = UKG · 1–12 = standard grades
        division         : String      # "A" | "B" | "C" | "D" | "E"
        fatherName       : String
        pickupPoint      : String
        phone1           : String
        phone2           : String
        address          : String
        notes            : String
        toSchoolTrip     : String?     # "FIRST" | "SECOND" | null
        fromSchoolTrip   : String?     # "FIRST" | "SECOND" | null
        createdAt        : Timestamp
        updatedAt        : Timestamp   # server-side via FieldValue.serverTimestamp()

    lists/                            (subcollection)
      {listId}/
        schoolId             : String
        name                 : String
        filterGrade          : int?
        filterDivision       : String?
        filterToSchoolTrip   : String?
        filterFromSchoolTrip : String?
        createdAt            : Timestamp
        students             : List<Map>    # embedded StudentSummary snapshots
          └─ id, name, grade, division, pickupPoint, phone1
```

> **No composite indexes required.** Queries use at most a single `.orderBy()`. All filter logic (`StudentFilters.matches()`) runs client-side after the initial fetch.

---

## Getting Started

### Prerequisites

| Tool | Minimum version |
|---|---|
| Flutter SDK | 3.12.0 |
| Dart SDK | 3.0.0 |
| Android Studio / Xcode | Latest stable |
| Firebase CLI | Latest — `npm i -g firebase-tools` |
| FlutterFire CLI | Latest — `dart pub global activate flutterfire_cli` |

### Clone & install

```bash
git clone https://github.com/<your-org>/alphonsatravels.git
cd alphonsatravels
flutter pub get
```

---

## Firebase Setup

The app requires a Firebase project with **Firestore** and **Anonymous Authentication** enabled.

### 1. Create a project

```bash
firebase login
firebase projects:create alphonsa-van-service
```

### 2. Enable services in the Firebase Console

- **Authentication** → Sign-in method → **Anonymous** → Enable
- **Firestore Database** → Create database (start in production mode)

### 3. Connect FlutterFire

```bash
flutterfire configure --project=alphonsa-van-service
```

This regenerates `lib/firebase_options.dart`. Do not commit secrets stored in this file to a public repository.

### 4. Deploy Firestore Security Rules

```js
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /schools/{schoolId} {
      allow read: if request.auth != null;

      match /students/{studentId} {
        allow read, write: if request.auth != null;
      }

      match /lists/{listId} {
        allow read, write: if request.auth != null;
      }
    }
  }
}
```

```bash
firebase deploy --only firestore:rules
```

### 5. Run

```bash
flutter run                   # debug on connected device
flutter run --release         # release build on device
```

---

## Building for Production

### Android APK (direct install)

```bash
flutter build apk --release
# → build/app/outputs/flutter-apk/app-release.apk
```

### Android App Bundle (Play Store)

```bash
flutter build appbundle --release
# → build/app/outputs/bundle/release/app-release.aab
```

### Signing

Create `android/key.properties` (not committed to version control):

```properties
storePassword=<keystore-password>
keyPassword=<key-password>
keyAlias=<key-alias>
storeFile=<absolute-path-to-keystore.jks>
```

Reference it in `android/app/build.gradle.kts` under the `signingConfigs` block before building.

---

## Screens

| Screen | Route | Description |
|---|---|---|
| Splash | `/` | Animated logo + pulsing dots; navigates to school selection after 2.5 s |
| School Selection | `/schools` | Pick the active school; persists selection in Riverpod state |
| Students | `/students` | Full roster with multi-select filters, live search, and FAB to add |
| Student Detail | `/students/:id` | Complete profile; one-tap call, edit, and delete |
| Add / Edit Student | `/students/add` · `/students/:id/edit` | Form covering all student fields and trip assignments |
| Lists Hub | `/lists` | All saved route lists for the current school |
| Create List | `/lists/create` | Filter roster → select students → enter name → save to Firestore |
| Saved List View | `/lists/:id` | Numbered student roster; export sheet with PDF / text / clipboard options |
| Settings | `/settings` | App preferences |

---

## State Management

```
schoolsProvider            FutureProvider          Firestore schools collection
selectedSchoolProvider     StateProvider<School?>  Active school selection

studentsProvider           FutureProvider.family   Students subcollection for a school
studentFiltersProvider     NotifierProvider        Immutable StudentFilters value
filteredStudentsProvider   Provider.family         Derived: students × filters

savedListsProvider         FutureProvider.family   Lists subcollection for a school
listRepositoryProvider     Provider                ListRepository implementation
```

Screens consume derived providers only. No screen imports a repository implementation directly.

---

## Android Notes

### Dialer support on Android 11+

Android API 30+ restricts package visibility. The `tel:` URI scheme must be declared in `AndroidManifest.xml` for `url_launcher` to open the phone dialer:

```xml
<queries>
    <intent>
        <action android:name="android.intent.action.DIAL" />
        <data android:scheme="tel" />
    </intent>
</queries>
```

This is already present in the project manifest.

---

*Built with Flutter · Powered by Firebase · Designed for daily use in the field*
