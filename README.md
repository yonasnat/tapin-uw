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

User Documentation: [User Documentation](https://github.com/yonasnat/tapin-uw/blob/main/User_Manual.md)
Developer Documentation: [Developer Documentation](https://github.com/yonasnat/tapin-uw/blob/main/Developer_Guide.md) <br /> 
*An invitation is required to access the Firebase (Users and Developers), Melanie (Our TA) has been invited.

Operation Use Case(s):
1. User account creation with UW credentials
2. User account log in (after account creation)

