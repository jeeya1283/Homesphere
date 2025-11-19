# HomeSphere (Flutter)

A simple Flutter real-estate demo app (UI + basic Firestore auth & data examples).  
This repository contains the app UI, screens, and client logic — **sensitive configuration and credentials are intentionally kept out of this public repo**.

---

## Contents

This repository contains the following safe-to-publish source files (UI & app logic):

- `addProperty.dart`  
- `admin_chat_list.dart`  
- `chat_page.dart`  
- `detail_page.dart`  
- `home_page.dart`  
- `login_page.dart`  
- `profile.dart`  
- `properties.dart`  
- `sign_up_page.dart`  
- `viewProperty.dart`  
- `wishlist.dart`  
- `AndroidManifest.xml`  
- `pubspec.yaml`  

> ⚠️ **Do not commit** `main.dart`, `auth.dart`, `.env`, `google-services.json`, or `GoogleService-Info.plist` — these files contain sensitive keys or project configuration and are listed in `.gitignore`.

---
## Team Members
  
- **Jiya Roy**
- **Foram Tarsariya**

---  
## Demo screenshot

<img width="370" height="788" alt="Capture2" src="https://github.com/user-attachments/assets/d4852b8f-5794-4e8d-8725-bc65e425a24d" />
<img width="732" height="756" alt="Capture" src="https://github.com/user-attachments/assets/d70cbde5-6540-4ba6-8325-250edabee549" />

---

## Features

- Flutter UI for listing & viewing properties  
- Authentication flows (email/password) via Firebase Auth (client-side logic in `auth.dart` — kept private in this repo)  
- Chat & admin screens (UI)  
- Wishlist, property CRUD UI examples

---

## Requirements

- Flutter SDK (stable channel)  
- Dart  
- An Android or iOS device / emulator  
- Firebase project (for authentication and Firestore) — see **Setup** below
