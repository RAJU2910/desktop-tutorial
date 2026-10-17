# InstaLite — Flutter Web App

A learning project inspired by the login, signup, home feed, and profile screens taught in the C-DAC Mohali **Full-Stack Mobile App Development using Flutter & REST APIs** bootcamp.

## Screens and features
- Login screen with basic form validation
- Signup screen with name, email, and password fields
- Home feed with story-style avatars and post cards
- Like/unlike posts during the current session
- Explore grid and profile screen
- Feed data loaded from the public JSONPlaceholder REST API
- Responsive Flutter web layout and bottom navigation
- GitHub Actions build, test, and GitHub Pages deployment

## Important demo limitations
This is an educational UI demo, not a production Instagram clone.
- Login/signup are **not real authentication**; credentials are not sent to a server or saved.
- Posts are placeholder text from JSONPlaceholder; image tiles are illustrations, not real user photos.
- Likes and profile changes are temporary and disappear when the app session ends.
- Never enter a real password or sensitive information.
- Production use requires a secure authentication API, database, real media storage, access controls, and privacy safeguards.

## Run locally
Install Flutter stable, then:
```bash
flutter pub get
flutter analyze
flutter test
flutter run -d chrome
```

## GitHub Pages
The workflow at `.github/workflows/deploy.yml` builds the web app using `/desktop-tutorial/` as the base path and deploys on pushes to `main`.

1. Open repository **Settings → Pages**.
2. Select **GitHub Actions** as the build and deployment source.
3. Merge this branch into `main`.
4. Check the **Actions** tab for the build/deployment result.

Expected URL after a successful workflow:
https://raju2910.github.io/desktop-tutorial/

## Stack
Flutter, Dart, Material 3, REST API (Dart `http`), GitHub Actions, GitHub Pages.
