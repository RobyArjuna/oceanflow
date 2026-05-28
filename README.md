# OceanFlow Maritime Logistics Platform
### Enterprise-grade Offline-First Maritime Operations & Cargo Scheduler

OceanFlow is a production-ready mobile platform engineered in Flutter to handle unstable network profiles at deep-sea shipping terminals and docks. Powered by an offline transaction queue with exponential backoff retry mechanics, local SQLite cache schemas, robust role-based navigation guard screens, and streaming AI assistant tools.

---

## 🏗️ Architecture Design System

OceanFlow employs a **Modular Feature-First vertical-sliced architecture** layered over standard **Clean Architecture** patterns (**MVVM + Repository contract interfaces**).

```
  ┌─────────────────────────────────────────────────────────┐
  │                       Presentation                      │
  │     [Widgets / Views] ──◀──▶ [ViewModels / Notifiers]   │
  └───────────────────────────────────┬─────────────────────┘
                                      │
  ┌───────────────────────────────────▼─────────────────────┐
  │                          Domain                         │
  │        [Entities] ──◀──▶ [Repository Interfaces]        │
  └───────────────────────────────────┬─────────────────────┘
                                      │
  ┌───────────────────────────────────▼─────────────────────┐
  │                           Data                          │
  │   [Data Repositories] ──▶ [Local DB Cache] / [Remote]   │
  └─────────────────────────────────────────────────────────┘
```

### 🗝️ Tech Stack Specifications
* **Core Framework**: Flutter (Material 3 Dark/Light layout matching industrial logistics consoles)
* **State Management**: Riverpod 2.x (AsyncNotifiers, Providers, StateNotifiers)
* **Navigation & Guards**: GoRouter (Shell tab routing, state-driven redirect loops, widget guards)
* **Storage Engines**: sqflite (SQLite local transactional database) & flutter_secure_storage (AES encrypted credentials keys)
* **Local APIs**: Dio client with structured interceptors (JWT auth injection, exponential backoffs, logging)
* **Model Serialization**: Freezed & JsonSerializable
* **Background Orchestration**: Workmanager periodic isolates
* **AI Scheduler Core**: google_generative_ai (Gemini chat APIs)

---

## 🛰️ Offline-First Synchronization Workflow

All operational updates (logged checkpoints, container seal scans, and status alterations) are processed through an **optimistic transactional database queue**.

```
  [User logs checkpoint]
             │
             ▼
  [Update local SQLite cache] ──▶ [UI updates instantly with dirty indicator]
             │
             ▼
  [Enqueue to SQLite Sync Queue table (status = pending)]
             │
             ▼
  [Check ConnectivityStatus]
       ├─── (ONLINE)  ──▶ [Send remote API request] ──▶ [Clean SQLite dirty flag & done queue]
       └─── (OFFLINE) ──▶ [Wait for ConnectivityMonitor stream recovery OR Workmanager background task]
```

### ⏳ Exponential Backoff Retry Policy
If transient HTTP errors or server timeouts are encountered during transmission, actions are retried dynamically:
$$\text{delay} = \text{baseDelay} \times 2^{\text{retryCount}}$$
This is capped at 30 seconds to conserve battery and terminal memory allocations.

---

## 📁 Repository Directory Structure

```
lib/
├── main.dart                  # Root initialization routine
├── app/
│   ├── app.dart               # MaterialApp routing config
│   ├── flavor/                # Flavor env environments
│   ├── theme/                 # Dark/Light Material 3 theme colors
│   └── providers/             # Global Providers
├── core/
│   ├── auth/                  # JWT token storage and Session controllers
│   ├── constants/             # Constant DB column maps
│   ├── database/              # SQLite Database helpers
│   ├── error/                 # Sealed domain-level AppErrors
│   ├── network/               # HTTP clients and Dio interceptor chains
│   └── sync/                  # Transaction sync queues and schedulers
├── shared/
│   ├── widgets/               # Premium chips, skeletons, and error blocks
│   └── utils/                 # GPS / connectivity state monitors
├── features/
│   ├── auth/                  # JWT Login screens and Quick Switch demo profiles
│   ├── dashboard/             # Aggregated stats, greeting states
│   ├── shipment/              # Active shipments catalogs, timeline specifications
│   ├── tracking/              # Operator checkpoint forms, seal scanning simulators
│   ├── sync/                  # Action control boards, queue reruns
│   ├── ai_assistant/          # Streaming chatbot logs
│   └── notifications/         # Real-time message logs
└── services/
    └── background_service.dart # Workmanager system isolates
```

---

## 🔒 Multi-Role Permission Registry

Operations menus are automatically adjusted dynamically in the GoRouter shell context:
* **Admin / Supervisor**: Master operations control panel access, full system logs, queue control panels, custom ETA schedules.
* **Operator**: Checkpoint creation logs, GPS terminal inputs, container lists.
* **Driver**: assigned route schedules, digital photo proof uploads, chassis seal scans.

---

## 🚀 Local Installation & Execution

### 1️⃣ Clone Workspace dependencies
```bash
flutter pub get
```

### 2️⃣ Run Build Runner (Model Generation)
```bash
dart run build_runner build --delete-conflicting-outputs
```

### 3️⃣ Execute Compilation
```bash
# Debug dev builds
flutter run --flavor dev

# Production release builds with code obfuscation
flutter build apk --flavor prod --obfuscate --split-debug-info=/<symbols-path>
```

---

## 🛠️ Recent Production Polish & Optimization (v1.1)

To ensure the platform operates seamlessly on diverse industrial handhelds and rugged mobile devices, we implemented the following high-standard optimizations:
* **Responsive Layout Engine**: Redesigned the authentication portal using `LayoutBuilder` to switch dynamically between a rich desktop/tablet split dual-panel dashboard and a compact, scrollable vertical single-column profile for smartphones, resolving layout bounds limits.
* **Auto-Ellipsis Render Constraints**: Patched the list-view templates (`shipment_list_screen.dart` and `shipment_detail_screen.dart`). All unbounded horizontal text elements (vessel names, tracking IDs, status tags) are now properly protected using `Flexible` and `Expanded` boundaries alongside `TextOverflow.ellipsis` to prevent `RenderFlex` overflows on small displays.
* **Android SQLite WAL Compatibility**: Resolved a low-level SQLite driver exception where Android threw a `DatabaseException` during database opening. Since `PRAGMA journal_mode = WAL` returns a status row, standard `db.execute()` calls were failing under Android's strict SQLite API constraints. This was successfully refactored to use `db.rawQuery()`.
* **Zero Analyzer Debt**: Cleared package dependency solver issues, corrected duplicate parser tokens inside Material 3 styling scripts (`app_theme.dart`), and addressed import routing issues. Currently **0 warnings and 0 errors** on `flutter analyze`.

---

## 🌟 Senior Mobile Portfolio Highlights
* Exposes **cache-first repository patterns** to completely isolate the presentation layer from unstable connectivity channels.
* Structured **sealed AppError schemas** handling error translation boundary scopes from low-level Dio states up to form-validation fields.
* Parallelized background **Workmanager callback dispatchers** processing queues in detached background thread isolates.
* **Dynamic dual-pane typography grid system** with animations (`flutter_animate`) optimized for rugged industrial tablets and smartphones.
* **Proactive responsive & defensive layout practices** targeting screen variations from 320dp phones to high-DPI rugged terminal scanners.
