# app-todo-hust

A Flutter todo app with Firebase Authentication and Cloud Firestore sync. The app supports Google Sign-In + Email/Password, date-based tasks, filters, and a clean UI.

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

## Project Structure

```
lib/
  main.dart          # App entry and UI
android/
  app/google-services.json
ios/
  Runner/GoogleService-Info.plist
```

## Notes

- Firestore offline persistence is enabled (cache unlimited).
- If you add or change Firebase config files, do a full rebuild on iOS.

## License

MIT
