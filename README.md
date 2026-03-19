# app-todo-hust

A Flutter todo app with Firebase Authentication and Cloud Firestore sync. The app supports Google Sign-In + Email/Password, date-based tasks, filters, and a clean UI.

## Screenshots

![Screenshot 1](docs/screenshots/Simulator%20Screenshot%20-%20iPhone%2017%20Pro%20-%202026-03-19%20at%2023.49.00.png)
![Screenshot 2](docs/screenshots/Simulator%20Screenshot%20-%20iPhone%2017%20Pro%20-%202026-03-19%20at%2023.49.05.png)
![Screenshot 3](docs/screenshots/Simulator%20Screenshot%20-%20iPhone%2017%20Pro%20-%202026-03-19%20at%2023.49.11.png)
![Screenshot 4](docs/screenshots/Simulator%20Screenshot%20-%20iPhone%2017%20Pro%20-%202026-03-19%20at%2023.49.16.png)
![Screenshot 5](docs/screenshots/Simulator%20Screenshot%20-%20iPhone%2017%20Pro%20-%202026-03-19%20at%2023.49.48.png)

## Features

- Firebase Auth: Email/Password + Google Sign-In
- Cloud Firestore sync (per-user)
- Add todo with optional due date (date only)
- Filters: All Dates, Today, This Week, No Date
- Status filters: All, Active, Completed (with counts)
- Calendar picker (collapsible)
- Offline cache enabled for Firestore

## Tech Stack

- Flutter (Material 3)
- Firebase: Auth + Firestore

## Setup

### 1) Install Flutter

Follow the official Flutter installation guide and ensure `flutter doctor` is green.

### 2) Firebase Project

Create a Firebase project and enable:

- Authentication: Email/Password and Google
- Firestore Database

### 3) Firebase Config Files

Download config files from Firebase Console for your project and place them here:

- Android: `android/app/google-services.json`
- iOS: `ios/Runner/GoogleService-Info.plist`

### 4) iOS URL Scheme (Google Sign-In)

Ensure the iOS URL scheme is added to `ios/Runner/Info.plist` (usually comes from GoogleService-Info.plist). If missing, add `REVERSED_CLIENT_ID` under `CFBundleURLSchemes`.

### 5) Firestore Rules

Use these rules (only the owner can read/write):

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId}/todos/{todoId} {
      allow read: if request.auth != null
        && request.auth.uid == userId
        && resource.data.ownerId == request.auth.uid;

      allow create: if request.auth != null
        && request.auth.uid == userId
        && request.resource.data.ownerId == request.auth.uid;

      allow update: if request.auth != null
        && request.auth.uid == userId
        && request.resource.data.ownerId == request.auth.uid
        && resource.data.ownerId == request.auth.uid;

      allow delete: if request.auth != null
        && request.auth.uid == userId
        && resource.data.ownerId == request.auth.uid;
    }
  }
}
```

### 6) Firestore Composite Index

The app uses this query:

- `ownerId` (ascending)
- `createdAt` (ascending)

Create a composite index for collection `todos` with those fields.

## Run the App

```bash
flutter pub get
flutter run -d ios
```

To run on Android, use:

```bash
flutter run -d android
```

## Build Release

### Android (APK)

```bash
flutter build apk --release
```

Output:
```
build/app/outputs/flutter-apk/app-release.apk
```

### Android (App Bundle)

```bash
flutter build appbundle --release
```

Output:
```
build/app/outputs/bundle/release/app-release.aab
```

### iOS (Archive)

```bash
flutter build ios --release
```

Then open Xcode and archive:

```bash
open ios/Runner.xcworkspace
```

In Xcode: **Product → Archive** to generate the release build.

## Project Structure

```
lib/
  main.dart          # App entry and UI
android/
  app/google-services.json
ios/
  Runner/GoogleService-Info.plist
docs/
  screenshots/
```

## Notes

- Firestore offline persistence is enabled (cache unlimited).
- If you add or change Firebase config files, do a full rebuild on iOS.

## License

MIT
