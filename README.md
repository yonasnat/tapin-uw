# tapin-uw

TapIn@UW is an innovative social network designed specifically for UW students, alumni and faculty. Its
main goal and mission is to connect students on campus events, sports, and meetups while offering a
unique matchmaking system for academic, social and extracurricular activities. TapIn also features a
proprietary filtering algorithm that allows students to discover personalized events, new people, and
resources tailored to their interests and majors. Users will create their profile that will highlight their
interests which helps the app find their best fit with students. With a focus on security, TapIn ensures that
students are verified and connected within a safe environment. The platform aims to expand beyond UW,
with future plans to adapt it for other universities.


Layout:

/public – This folder holds static files like app icon, images, and the base HTML file. 

/src – This is the main folder where all app logic and UI live.

components/ – Reusable UI parts like buttons, navigation bars, cards, and modals that are shared across multiple pages.

Pages: 

  Profiles.tsx – Handles displaying and editing user profiles.
  
  Explore.tsx – Allows users to browse events, opportunities, and resources.
  
  Matchmaking.tsx – The friendship matching feature based on shared interests.

features/ – Organizes business logic and state management by feature. Contains things like data fetching, reducers, or custom hooks for that specific part of the app (Explore, Matchmaking, Profiles).

App.tsx – The root React component that ties everything together. It includes routing between pages and any global layout.

/backend – (e.g., with Node.js or Firebase functions), this folder would include our server-side logic like API routes, database connections, or authentication logic.

/docs – Planning materials like design wireframes, product specs, or meeting notes.

Weekly Reports: https://docs.google.com/document/d/1iC9KicQdTowXv4BmYF74I4orOGh5hEf4HAeVGV9t0pc/edit?usp=sharing

Set Up Instructions:
1. Download the project
2. Open Terminal
3. If Firebase is not downloaded on Mac:

   a. Run: curl -sL https://firebase.tools | bash

   b. Follow instructions to create an account and setup Firebase 

5. Run: cd flutter_frontend
6. Run: flutter pub get
7. Run: firebase login
8. Run: dart pub global activate flutterfire_cli
9. Note the export path (e.g., export PATH="$PATH:$HOME/.pub-cache/bin") at the end
10. Run: nano ~/.zshrc
11. Add the export path (e.g., export PATH="$PATH:$HOME/.pub-cache/bin") in the file
12. Save and exit nano
13. Run: source ~/.zshrc
14. Run: flutterfire --version
15. Run: flutterfire configure
16. Select: tapin-uw (TapIn-UW)
17. Select: web (for which configuration to configure with)
18. Run: flutter run
19. Select: [3] Chrome
