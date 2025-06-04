# TapIn@UW – User Manual

Welcome to TapIn@UW, a mobile app tailored for University of Washington students, alumni, and faculty to make meaningful social and academic connections.

## About

TapIn@UW enables users to:
- Discover and post campus events
- Match with students based on shared interests and courses
- Directly message others
- Browse a personalized feed tailored to their academic and social preferences

By offering a verified UW-only platform, TapIn@UW fosters a safer and more intentional environment for students to make friends, share meetups, and participate in UW community events.

## Installation
### 1. Download the project
- Open the repository: [Click Here](https://github.com/yonasnat/tapin-uw)
- Click code
- Click Download ZIP
- Navigate to your computer's downloads folder
- Unzip the package
### 2. If Flutter is not downloaded on Mac:
- Determine the processor (Intel or Apple Silicon)
- Follow the respective instructions on the Flutter Docs: [Link Here](https://docs.flutter.dev/get-started/install/macos/web)
- The Flutter Version/SDK: ^3.7.2
### 3. Next Steps
- Open the project in an IDE (VS Code is best)
- Open Terminal
- Navigate to the main directory of the project (tapin-uw)
### 4. If Firebase is not downloaded on Mac
**Run this command in the terminal:**
```bash
curl -sL https://firebase.tools | bash
``` 
**5. Follow instructions to create an account and setup Firebase:**
[Link Here](https://firebase.google.com/docs/flutter/setup?platform=ios)

- The Firebase Packages/Versions:
-   firebase_core: ^2.27.0
-   firebase_auth: ^4.17.4
-   cloud_firestore: ^4.15.5
-   cloud_functions: ^4.6.5

## Running the Software
**1. Navigate to the project directory**
```bash
cd tapin-uw
cd flutter_frontend
```
**2. Run Firebase**
```bash
firebase login
```
**3. Get the Flutterfire CLI**
```bash
dart pub global activate flutterfire_cli
```
#### Note the export path (e.g., export PATH="$PATH:$HOME/.pub-cache/bin") at the end <br /> 
**4. Add Flutterfire to PATH**
```bash
nano ~/.zshrc
```
- Add the export path (e.g., export PATH="$PATH:$HOME/.pub-cache/bin") into the file
- Save and exit nano <br />

**5. Configure Firebase for Flutter**
```bash
source ~/.zshrc
flutterfire --version
flutterfire configure
```
- If encountering errors related to .xcodeproj during Firebase configuration, install the xcodeproj gem then rerun the previous flutterfire command:
  ```bash
  sudo gem install xcodeproj

- Select: tapin-uw (TapIn-UW)
- Select: web (for which configuration to configure with)
**6. Start the App**
```bash
flutter run
```
- Select: [3] Chrome

## Using the Software
### 1. Authentication
- Sign Up: Enter your UW email (@uw.edu), create a password, and choose a display name.
- Log In: Enter your UW email and password.
### 2. Profile Management
- Create or Edit Profile:
-   Tap Profile in the bottom navigation.
-   Add a photo, bio, major, courses, and personal interests (tags).
-   Tap Save to update your information.
### 3. Creating & Sharing Events
- Tap the + Post icon in Explore.
- Fill in event details:
-   Title & Description
-   Date & Time picker
### 4. Filters & Matchmaking
- Filters:
-   Navigate to Filters (in Explore).
-   Toggle categories and set date ranges.
- Friendship Matchmaking:
-   Tap Match in the bottom navigation bar
-   Swipe left (Ignore) or right (Add)
### 5. Chat & Messaging(Work in progress)
- Tap Messages in the bottom nav.
- Select a conversation or start a new chat from a matched friend.
- Send text messages; images and group chat coming soon.

## Reporting Bugs
All bugs should be reported through our GitHub Issues page: [Link Here](https://github.com/yonasnat/tapin-uw/issues) <br /> 
#### Bug reports should include the following information:
- Title – A short summary of the bug.
- Steps to Reproduce – A clear, step-by-step list of how to trigger the bug.
- Expected Behavior – What the user expected to happen.
- Actual Behavior – What actually happened.
- Screenshots/Logs – Any relevant visuals or error messages.
- Severity – Optional, but helps us prioritize (high, medium, low).

## Known Bugs
- There is a deployment issue with getting macOS running. Chrome is the only working version of the app so far.
- The explore(events) page and profile page are currently static.
- The matchmaking page displays a Firebase error when there is no more users that are potential matches
