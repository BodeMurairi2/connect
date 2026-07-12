# AnzaConnect

**Author:** Bode Murairi — [b.murairi@alustudent.com](mailto:b.murairi@alustudent.com)

---

## What It Is

AnzaConnect is a mobile platform built for the African Leadership University ecosystem. It closes the gap between ALU students looking for real-world experience and ALU-affiliated startups looking for talent.

Students browse verified startup opportunities, save the ones they care about, and submit applications with a cover letter and supporting documents — all from one place. Startups post openings, review applicants, and manage the hiring pipeline. A facilitator account lets ALU staff verify startup registrations before they can post, keeping the ecosystem trusted.

**The problem it solves:** ALU students currently rely on informal channels (WhatsApp groups, word of mouth) to find startup opportunities. AnzaConnect makes discovery structured, applications trackable, and the process transparent for everyone involved.

---

## Why AnzaConnect

*Anza* means "begin" in Swahili. The name reflects the app's purpose: helping students take their first step into the professional world and helping startups begin building their teams — within a community that already shares a set of values.

---

## Architecture

AnzaConnect follows a strict **four-layer unidirectional architecture**:

```
Flutter UI  →  BLoC (State)  →  Repository (Data)  →  Firebase & Services
```

| Layer | Role |
|---|---|
| **Flutter UI** | Screens and widgets. Dispatches events, renders state. Never touches data sources directly. |
| **BLoC** | `FeedBloc`, `AuthBloc`, `StartupBloc`. Receives events, calls repositories, emits new states. |
| **Repository** | Encapsulates all Firestore queries, Auth calls, file uploads, and email sends. |
| **Backend** | Firestore, Firebase Auth, Cloudflare R2, Gmail SMTP. |

**Navigation** uses `go_router` with flat `GoRoute` definitions. Tab state is preserved via `IndexedStack` inside `StudentHomeScreen`.

**State** is managed exclusively through BLoC. Screens never hold business data in `setState`. The only local state is UI-level (animation controllers, text field focus, etc.).

---

## Components

| Component | Purpose |
|---|---|
| **Flutter + Dart** | Cross-platform mobile UI, Dart SDK `^3.12.2` |
| **flutter_bloc** | BLoC pattern for predictable, testable state management |
| **go_router** | Declarative routing with role-based navigation |
| **Firebase Auth** | Email/password and Google OAuth sign-in |
| **Cloud Firestore** | Real-time NoSQL database for all app data |
| **Cloudflare R2** | S3-compatible object storage for documents and logos (no egress fees) |
| **Gmail SMTP** (`mailer`) | Email notifications on application submit and status change |
| **file_picker** | Cross-platform document selection |
| **url_launcher** | Opens submitted documents from the admin portal |
| **crypto / http** | AWS4-HMAC-SHA256 request signing for R2 uploads |

---

## Repository Structure

```
lib/
├── core/
│   ├── constants/          # App-wide constants
│   ├── errors/             # Error types
│   ├── router/             # app_router.dart — all GoRoute definitions
│   ├── theme/              # Colours, text styles
│   └── widgets/            # Shared UI components
│
├── features/
│   ├── admin/
│   │   └── screens/        # AdminDashboardScreen — verify/revoke startups
│   │
│   ├── auth/
│   │   ├── bloc/           # AuthBloc, AuthEvent, AuthState
│   │   ├── components/     # Form fields, Google button
│   │   └── screens/        # LoginScreen, RegisterScreen, RoleSelectionScreen
│   │
│   ├── onboarding/
│   │   ├── components/
│   │   └── screens/        # StudentOnboardingScreen, StartupOnboardingScreen
│   │
│   ├── startups/
│   │   ├── bloc/           # StartupBloc, StartupEvent, StartupState
│   │   ├── components/     # StartupProfileSheet, opportunity cards
│   │   ├── data/
│   │   └── screens/        # StartupHomeScreen, StartupDashboardScreen
│   │
│   └── student/
│       ├── bloc/           # FeedBloc, FeedEvent, FeedState
│       ├── components/     # FeedHeaderSliver, OpportunityCard
│       ├── data/           # FeedOpportunity model
│       └── screens/        # FeedScreen, BookmarkScreen, ApplyScreen,
│                           # OpportunityDetailScreen, StudentProfileScreen
│
└── repositories/
    ├── application_repository.dart   # Submit applications, update status
    ├── auth_repository.dart          # Sign in, sign up, sign out, isAdmin
    ├── bookmark_repository.dart      # Subcollection CRUD + live stream
    ├── notification_repository.dart  # SMTP email via Gmail
    ├── opportunity_repository.dart   # Fetch and filter open opportunities
    ├── r2_storage_service.dart       # Signed uploads to Cloudflare R2
    ├── startup_repository.dart       # Startup profiles, getAllStartups, setVerified
    ├── storage_repository.dart       # Firebase Storage (legacy/fallback)
    └── student_repository.dart       # Student profile reads
```

### Firestore Collections

| Collection | Description |
|---|---|
| `Users/{uid}` | firstName, role, email |
| `Opportunities/{id}` | title, field, type, deadline, isOpen, startupId |
| `Bookmarks/{uid}/items/{id}` | Saved opportunity snapshot + savedAt timestamp |
| `Applications/{id}` | studentId, opportunityId, coverLetter, status, fileUrls |
| `Startups/{uid}` | name, field, logoUrl, isVerified, businessCertificateUrl |
| `admins/{uid}` | Presence of document = facilitator access granted |

---

## Setup

### Prerequisites

- Flutter SDK `>=3.12.2`
- A Firebase project with Firestore and Authentication enabled
- A Cloudflare R2 bucket with an API token (read/write permissions)
- A Gmail account with an [App Password](https://support.google.com/accounts/answer/185833) enabled

### 1. Clone the repository

```bash
git clone https://github.com/BodeMurairi2/connect.git
cd connect
```

### 2. Connect Firebase

Download `google-services.json` (Android) and/or `GoogleService-Info.plist` (iOS) from your Firebase project console and place them in:

```
android/app/google-services.json
ios/Runner/GoogleService-Info.plist
```

Enable the following in your Firebase project:
- **Authentication** → Email/Password provider + Google provider
- **Firestore Database** → create in production mode

### 3. Create your `.env.json`

Copy the example structure below, fill in your credentials, and save the file as `.env.json` in the project root. This file is listed in `.gitignore` and must never be committed.

**.env.json.example**
```json
{
  "R2_ACCESS_KEY":  "your-r2-access-key-id",
  "R2_SECRET_KEY":  "your-r2-secret-access-key",
  "R2_BUCKET":      "your-bucket-name",
  "R2_ENDPOINT":    "https://<account-id>.r2.cloudflarestorage.com",
  "R2_PUBLIC_URL":  "https://pub.yourdomain.com",
  "SMTP_EMAIL":     "your-gmail@gmail.com",
  "SMTP_PASSWORD":  "your-16-char-gmail-app-password"
}
```

> **R2_ENDPOINT** — found in your Cloudflare R2 dashboard under bucket settings.  
> **R2_PUBLIC_URL** — the public base URL of your bucket (custom domain or the `*.r2.dev` URL Cloudflare provides).  
> **SMTP_PASSWORD** — must be a Gmail **App Password** (16 characters), not your account password. Generate one at [myaccount.google.com/apppasswords](https://myaccount.google.com/apppasswords).

### 4. Install dependencies

```bash
flutter pub get
```

### 5. (Optional) Create a facilitator admin account

Register a user through the app using the normal flow. Then open your Firebase console → Firestore → create a collection named `admins` and add a document whose **Document ID is that user's UID**. The document body can be empty. That user will see the admin verification portal on their next login.

---

## Running the App

Credentials are injected at build time via `--dart-define-from-file`. Running without this flag will start the app, but file uploads and email notifications will be silently disabled.

```bash
flutter run --dart-define-from-file=.env.json
```

To build a release APK:

```bash
flutter build apk --dart-define-from-file=.env.json
```

---

## License

This project is licensed under the **MIT License**.

```
MIT License

Copyright (c) 2025 Bode Murairi

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

---

## Feedback

Feedback is genuinely valuable — whether it is a bug report, a UX friction point, a missing feature, or a suggestion on how AnzaConnect could better serve the ALU community.

If you are an ALU student, startup founder, or facilitator who has used (or tried to use) this app, please reach out:

**Email:** [b.murairi@alustudent.com](mailto:b.murairi@alustudent.com)

Every piece of feedback shapes the next version. Thank you for taking the time.
