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
### 4. If Firebase is not downloaded on Mac:
**Run this command in the terminal**
```bash
curl -sL https://firebase.tools | bash
```





curl -sL https://firebase.tools | bash
Follow instructions to create an account and setup Firebase: https://firebase.google.com/docs/flutter/setup?platform=ios
The Firebase Packages/Versions: 
firebase_core: ^2.27.0
firebase_auth: ^4.17.4
cloud_firestore: ^4.15.5
cloud_functions: ^4.6.5
How to run the software. How to start up the system? - Cory
Once the software has all been installed:
Navigate to the project directory
cd tapin-uw
cd flutter_frontend
Login to firebase
firebase login
Get the flutterfire CLI
dart pub global activate flutterfire_cli
Add flutterfire to PATH 
echo 'export PATH="$PATH:$HOME/.pub-cache/bin"' >> ~/.zshrc
source ~/.zshrc
Configure firebase for flutter
flutterfire configure
Start the app
flutter run
How to use the software. You can assume that your user is familiar with your particular platform (e.g., use of a Web browser, desktop applications, or mobile applications). For missing functionality, your documentation should simply indicate that this functionality is work in progress. - Amrit
Authentication:
Sign Up:
Enter your UW email (@uw.edu), create a password, and choose a display name.
Log In:
Enter your UW email and password.
Profile Management
Create or Edit Profile:
Tap Profile in the bottom navigation.
Add a photo, bio, major, courses, and personal interests (tags).
Tap Save to update your information.
Creating & Sharing Events
Tap the + Post icon in Explore.
Fill in event details:
Title & Description
Date & Time picker
4.Filters & Matchmaking
Filters:
Navigate to Filters (in Explore).
Toggle categories and set date ranges.
Friendship Matchmaking:
Tap Match in the bottom nav.
Swipe left (Ignore) or right (Add)
5. Chat & Messaging(Work in progress)
Tap Messages in the bottom nav.
Select a conversation or start a new chat from a matched friend.
Send text messages; images and group chat coming soon.




How to report a bug. This should include not just the mechanics (a pointer to your issue tracker), but also what information is needed. You can set up a bug-report template in your issue tracker, or you can reference a resource about how to write a good bug report. Here is an example for bug reporting guidelines. - Adam
Known bugs. Known bugs or limitations should be documented in the bug tracker. A user testing the implemented use case(s) should not encounter trivial bugs (e.g., NPEs) or a large number of bugs that are unlisted in your bug tracker. - Yantong
There is a deployment issue with getting macOS running. Chrome is the only working version of the app so far.
The filter page, explore(events) page, matchmaking page, and profile page are currently static.

Complete this in the main branch of your repository by the stated deadline.
