## How to Obtain the Source Code
The source code can be all obtained from the GitHub repository: [Click Here](https://github.com/yonasnat/tapin-uw) <br /> 
The backend source code is in tapin-uw/firebase_backend/functions, and the frontend source code is in tapin-uw/flutter_frontend/lib.

## Layout of Directory Structure
From the root we have a assets/images folder which contains our logo, our  README.md  file that contains our documentation for the project, flutter_frontend and firebase_backend, a github/workflows folder which contains our TapinWorkFlow.yml and a gitignore file that contains the files we want git to ignore in commits/pushes <br /> 
The flutter_frontend directory contains all of the platform configuration files(ios, android…), lib folder that contains the source code, our data files  and test folder that contains our tests. <br /> 
The firebase_backend directory contains a functions folder that has our source code for all the firebase cloud functions(index.js, matchMakingFilters.js…), firestore.rules which are the security rules and other configuration files.

## How to Build the Software
**1. Clone the Repository**
```bash
git clone https://github.com/yonasnat/tapin-uw.git
cd tapin-uw
```

### Frontend (Flutter)
**1. Build the Flutter Frontend**
```bash
https://docs.flutter.dev/get-started/install/macos/web
```
**2. Fetch Dependencies**
```bash
cd flutter_frontend
flutter pub get
```
**3. Run/Debug Locally**
```bash
flutter run
```

### Build/Deploy the Backend (CLoud Functions)
**1. Install Node.js (v16+)**
```bash
https://nodejs.org/en/download
```
**2. Install Firebase CLI**
```bash
npm install -g firebase-tools
```
**3. Authenticate & Select Project**
```bash
firebase login
firebase use --add
```
**4. Fetch Function's Dependencies**
```bash
cd functions
npm ci
```

## How to Test the Software
### Frontend Testing
**1. Navigate to Frontend Directory**
```bash
cd flutter_frontend
```
**To Run All Tests**
```bash
flutter test
```
**To Run Specific Unit Test(s)**
```bash
Flutter test [FILENAME]
```
Example: flutter test test/widget_test.dart

### Backend Testing
**1. Navigate to Backend Directory**
```bash
cd flutter_backend
cd functions
```
**To Run All Tests**
```bash
npm test
```

## How to Add Tests
### Navigate



Navigate to flutter_frontend folder -> test subfolder
If file has not been created for the screen or function:
Naming conventions: {screen name or function description}_test.dart
Declare imports, such as the path of the file being tested
Create a void main() method {}
Add tests to target each element or function
An example test file may look like this: 
import 'package:flutter_test/flutter_test.dart';
void main() {
  test('sample test', () {
    expect(3 + 5, equals(8));
  });
}

## How to Build a Release
### Frontend(Flutter)
**1. Install dependencies**
```bash
flutter pub get
flutter pub upgrade --major-versions 
```

**2. Build for web**
```bash
flutter build web
```

**3. Run static analysis**
```bash
flutter analyze
```
- Confirm version increment in pubspec.yaml
- Manually test: login, signup, explore, profile, match, messaging 

### Backend(Firebase Functions)
Login & configure project
```bash
firebase login
firebase use --add
```

Deploy cloud functions
```bash
cd firebase_backend/functions
npm install
firebase deploy --only functions
```

Post-deployment, check logs for issues
```bash
firebase functions:log     
```

### Production Readiness Check
- Confirm Firestore security rules are enforced
- Restrict write access to verified users only


