# Assignment 3 – Flutter Offline Support & State Management Upgrade

**Student:** [Your Name]  
**Student ID:** [Your ID]  
**Branch:** `feature/offline-cache-and-state-manangement`

---

## Overview

This is an extension of the Assignment 2 (CRUD + API) Flutter app.  
Assignment 3 adds **offline-first support**, **Riverpod state management**, a clean **Repository Pattern**, and **optimistic UI updates**.

---

## Architecture

```
UI (Screens)
  ↓
State Management (Riverpod – CoursesNotifier)
  ↓
Repository (CourseRepository)
  ↓              ↓
API Service    Local DB (Hive)
(HTTP only)   (cache + offline)
```

### Layer Responsibilities

| Layer | File | Responsibility |
|---|---|---|
| **UI** | `screens/` | Display, user interaction |
| **State** | `providers/course_providers.dart` | CoursesState, loading/error/success, optimistic updates |
| **Repository** | `repositories/course_repository.dart` | Decides API vs local storage |
| **API Service** | `services/course_api_service.dart` | HTTP requests only |
| **Local DB** | `services/local_storage_service.dart` | Hive CRUD |

---

## Packages Used

| Package | Purpose |
|---|---|
| `flutter_riverpod ^2.5.1` | State management |
| `hive_flutter ^1.1.0` | Local offline storage |
| `http ^1.2.1` | REST API calls |
| `connectivity_plus ^6.0.3` | Online/offline detection |

---

## Features Implemented

### ✅ Offline Data Persistence (Hive)
- Courses fetched from API are cached locally in a Hive box
- When offline, app loads from local cache automatically
- Connectivity banner shows "Offline – showing cached data"
- Last sync timestamp displayed in UI

### ✅ State Management (Riverpod)
- `CoursesNotifier` manages `loading`, `success`, `error`, and `empty` states
- `searchQueryProvider` for real-time search/filter
- `filteredCoursesProvider` derives filtered list reactively
- `isOnlineProvider` streams connectivity changes

### ✅ Repository Pattern
- `CourseRepository` is the single source of truth
- Automatically decides: API (online) or Hive cache (offline)
- Falls back to cache if API fails even when online

### ✅ Optimistic UI Updates
- **Delete**: item removed from UI immediately; restored on API failure
- **Update**: changes shown instantly; rolled back if API fails
- Pending-sync icon shown on items awaiting confirmation

### ✅ UX Improvements
- Pull-to-refresh on course list
- Search/filter bar (live filtering by title and description)
- Empty state UI with contextual messages
- Confirmation dialog before delete
- Success/error snackbars

---

## Offline & State Management Approach

**Offline:** On every fetch, the app checks connectivity via `connectivity_plus`. If online, it fetches from JSONPlaceholder and saves to Hive. If offline (or if the API call fails), it reads from Hive. This gives a true **offline-first** experience.

**State:** Riverpod's `StateNotifier` manages a `CoursesState` value object covering all UI states. Optimistic updates mutate state immediately and rollback on failure, keeping the UI responsive with no loading delays for common actions.

---

## Screenshots

> Add screenshots here after running the app.

---

## API Used

**JSONPlaceholder** – https://jsonplaceholder.typicode.com  
Reference: https://jsonplaceholder.typicode.com/guide  
Endpoint: `/posts` (used as course data)

---

## How to Run

```bash
flutter pub get
flutter run
```

> **Note:** `hive_generator` and `build_runner` are listed as dev dependencies.  
> The `course_model.g.dart` file is pre-generated and included — no need to run `build_runner` manually.
