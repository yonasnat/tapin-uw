2. Write user documentation (30%)
Your public repository must contain a complete user manual. Anyone looking at your repository should be able to easily find the user manual. The user manual is focused solely on people who want to use your project.
The user manual should describe the functionality of your project as you expect it to be at the end of the quarter. For this assignment, indicate missing functionality as work in progress.
The user documentation should include at least the following information:
A high-level description. What does the system do and why would a user want to use it. -Nathnael
Tapin@UW is a mobile app tailored for University of Washington students, alumni, and faculty to make meaningful social and academic connections. The app supports: 
Discovering and posting campus events
Finding friends or study groups through matchmaking
Engaging in direct messaging
Browsing personalized content based on interests and courses
Tapin promotes community building by filtering content to match user interests, offering a safer and more purposeful networking space. Users would want to use it to find relevant events, make new friends, and share their own meetups or club gatherings in a verified, UW specific environment. 
How to install the software. If your system has prerequisites (e.g., tools, libraries, emulators, third-party applications, etc.), your instructions should list all of them and indicate how to install and configure them. Make sure to indicate what specific version requirements these prerequisites must satisfy. If running the system requires the installation of, e.g., a virtual machine, a database, or an emulator, make sure to provide clear step-by-step instructions. - Thomas
Download the project
If Flutter is not downloaded on Mac:
Determine the processor (Intel or Apple Silicon)
Follow the respective instructions on the Flutter Docs: https://docs.flutter.dev/get-started/install/macos/web
The Flutter Version/SDK: ^3.7.2
Open the project in an IDE (VS Code is best)
Open Terminal
Navigate to the main directory of the project (tapin-uw)
If Firebase is not downloaded on Mac:
Run: curl -sL https://firebase.tools | bash
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
