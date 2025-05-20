3. Developer documentation (30%)
Your public repository must contain developer guidelines. Anyone looking at your repository should be able to easily find these guidelines. The developer guidelines are focused solely on people who want to contribute to your project.
The developer documentation should include at least the following information:
How to obtain the source code. If your system uses multiple repositories or submodules, provide clear instructions for how to obtain all relevant sources. - Yantong
The source code can be obtained from the GitHub repository https://github.com/yonasnat/tapin-uw
The backend source code is in tapin-uw/firebase_backend/functions, and the frontend source code is in tapin-uw/flutter_frontend/lib.
The layout of your directory structure. What do the various directories (folders) contain, and where to find source files, tests, documentation, data files, etc. - Adam
How to build the software. Provide clear instructions for how to use your project’s build system to build all system components. - Amrit
1. Clone the Repository
git clone https://github.com/yonasnat/tapin-uw.git
cd tapin-uw
2. Build the Flutter Frontend
Install Flutter SDK



     2. Fetch dependencies
Run:  cd flutter_frontend
Run: flutter pub get
      3.Run/debug locally
	Use: flutter run
3. Build & Deploy the Backend (Cloud Functions)
Install Node.js (v16+)
 Ensure node and npm are installed.
Install Firebase CLI	
Run: npm install -g firebase-tools
     3. Authenticate & select project
Run: firebase login
         firebase use --add	
                4. Fetch functions dependencies
Run:  cd functions
npm ci
How to test the software. Provide clear instructions for how to run the system’s test cases. In some cases, the instructions may need to include information such as how to access data sources or how to interact with external systems. You may reference the user documentation (e.g., prerequisites) to avoid duplication. -Cory
Frontend Testing: 
Navigate to frontend directory
cd flutter_frontend
To run all tests
flutter test
To run a specific unit test file
Flutter test [FILENAME]
Ex. flutter test test/widget_test.dart
Backend Testing:
Navigate to backend directory
cd flutter_backend
cd functions
To run all tests
npm test
How to add new tests. Are there any naming conventions/patterns to follow when naming test files? Is there a particular test harness to use? - Thomas
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
Confirm version increment in pubspec.yaml
Manually test: login, signup, explore, profile, match, messaging (if complete)

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
Confirm Firestore security rules are enforced
Restrict write access to verified users only


