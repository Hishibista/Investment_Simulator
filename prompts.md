### Prompts ####

[x] 1. Create theme.dart in lib. Make a theme for my app it should be professional I want to mostly use colors, like black, grey and a littl a bit of green. I want the background to be black. Mark as done after finished. 

[x] 2. Create a new file in lib/screens/questionnaire_screen.dart. This screen should display a list of questions using clean UI components (cards or list sections).
Questions to include:
1. Investment Objective
- Grow wealth
- Preserve wealth
2. Financial Goals
- Buy a house
- Pay for education
- Retirement
- Other
3. Risk Tolerance
- High risk / High return
- Medium risk / Medium return
- Low risk / Low return
- No preference
4. Time Horizon
- Less than 3 years
- 3–7 years
- 7–15 years
- 15+ years
5. Financial Profile
- Student
- Early career
- Mid-career
- Near retirement
Mark complete after finished 

[x] 3. Place each question on a separate screen. Add a progress indicator at the top showing the user’s progress (e.g., Step 1 of 5). Include Next and Back buttons to allow navigation between questions.

[x] 4. After Selecting Get Started instead of going directly to the questionnaire the user should first navigate to create a account using valid email and password - email should be valid and password should me atleast 6 characters long with, atleast one number, one special character and one Capital letter. 
 
[x] 5. For the view samples button, make 4 samples for high risk/high return, medium risk/ medium return, low risk/ low return. 
Start with high risk/high return
Best for: Long time horizons (10–20+ years)
Allocation Example:
80% Stocks (growth / tech / global equities)
10% Emerging Markets
5% Corporate Bonds
5% Cash
Expected Return (example)
~9–12% annual return (long-term estimate)
Risk Level: High volatility,Large short-term swings possible. 
Include a pie chart showing the portfolio allocation percentages. Clearly label each asset category in the chart or legend. The UI should be clean, professional, and easy to understand.

[x] 6. Make a option screen for 4 sample portfolios with option for high risk/high return, medium risk/ medium return, low risk/ low return. 

[x] 7. For high risk/ high return option in view samples make a portfolio with following allocations: 
80% Stocks (growth / tech / global equities)
10% Emerging Markets
5% Corporate Bonds
5% Cash
Include a pie chart showing the portfolio allocation percentages. Clearly label each asset category in the chart or legend. The UI should be clean, professional, and easy to understand.

[x] 8. Implement account creation using Firebase Authentication. After a user successfully registers, store their associated data in Firebase, including their profile and any app-related information, so their data persists across sessions and devices.

[x] 9. After account creation and completion of the questionnaire, prompt the user to input their initial investment amount. Using their responses, generate a personalized portfolio allocation and demonstrate how their funds would be distributed across various asset classes.

[x] 10. Use the icon in the top-right corner of the dashboard as the user profile/sign-in button. Tapping it should navigate the user to a screen displaying their saved portfolio, account details, and previously stored investment data.

[x] 11. The app is currently using a dummy API key, so newly created user accounts are not being stored in Firebase. Update the configuration to connect the app to my Firebase project, SYE26-Investment, so that all newly created accounts are properly saved and visible in Firebase Authentication.

[x] 12. Currently, the user’s email and password are successfully creating an account in Firebase Authentication, but the questionnaire responses and selected investment preferences are not being stored. Save all user-selected options under the associated Firebase user account (linked by UID, email, and username) in Firestore. When the user logs in again, retrieve this saved data and route them directly to their personalized portfolio dashboard.

[x] 13. Enhance the User Profile screen by adding an Edit button beside the investment preferences and initial investment fields. Tapping the button should allow the user to update their selected preferences and initial investment amount, with all changes persisted to Firebase and immediately reflected in the portfolio dashboard.

[x] 14. The dashboard and the user screen both show the pie chart so change it that, the Dashboard screen should be redesigned as a Portfolio Growth Tracker that visually displays the performance of the user’s investment over time.
Dashboard Requirements – Growth Tracker
Create a dedicated Dashboard screen separate from the profile page. Replace the current duplicated profile-style layout with a growth tracking interface: 
Display the user’s initial investment amount
Show the current projected portfolio value
Include a line chart / growth graph that tracks portfolio growth over time
The graph should display values across time intervals such as:
1 month
6 months
1 year
5 years
10 years
Use the user’s selected portfolio type (high, medium, or low risk) to determine the expected growth rate
Simulate growth using a simple annual return assumption, for example:
High risk: 10–12%
Medium risk: 6–8%
Low risk: 3–5%

[x] 15. Update the portfolio growth tracker so that growth is no longer based on a fixed annual return. Instead, simulate yearly portfolio performance using randomized returns within a realistic range based on the user’s selected risk profile. Include both positive and negative growth to better reflect real market behavior.

[x] 16. Growth Logic Requirements: Replace fixed growth assumptions with randomized annual returns. Support both positive and negative yearly performance.
Use different return ranges depending on risk level:
High Risk:   -20% to +25%
Medium Risk: -10% to +15%
Low Risk:    -5% to +8% 
Ensure the line graph can show dips, recoveries, and volatility

[x] 17. When the portfolio tracker has negative growth, show it as being marked red. Change the outline and the area under it red. 

[x] 18. Update the main (home) UI layout while keeping the existing design intact. Replace the bottom action buttons with “Login” and “Sign Up.” In the top navigation bar, add options for “View Samples,” “Portfolio Tracker,” and “User Profile.” Each option should navigate to its corresponding screen—for example, selecting “View Samples” should open the sample portfolios screen.

[x] 19. When a user is already logged in, hide the “Login” and “Sign Up” action buttons on the main screen. Instead, update the UI to display a personalized greeting such as “Hello, [User Name]” to indicate the currently authenticated user.

[x] 20. Have the hello [User Name] be displayed before the "Build Your Future Portfolio Today" text. 

[x] 21. Have the menu bar be on the row below the main bar, so have samples, tracker and profile be below the investment simulator bar. 

[x] 22. For selecting the financialGoal have the option to select up to 3 financial goals.

[x] 23. In the homescreen when user is not signed in and is given the options of 'sign up' and 'log in' hide the menu bar that has profile, tracker and sample option. We should only being seeing that menu bar once the user is signed in. 