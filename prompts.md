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

[ ] 