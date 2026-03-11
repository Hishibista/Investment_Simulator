# Investment Strategy Simulator

Purpose:
Helps first-time investors plan diversified portfolios based on goals, risk, and timeline.

Core MVP:
1. User questionnaire
2. Risk profile calculation
3. Suggested portfolio breakdown

Gemini: When reading this file to implement a step, you MUST adhere to the following architectural rules:
1. State Management: Use flutter_riverpod exclusively. Do not use setState for complex logic.
2. Architecture: Maintain strict separation of concerns:
● /models: Pure Dart data classes (use json_serializable or freezed if helpful).
● /services: Backend/API communication only. No UI code.
● /providers: Riverpod providers linking services to the UI.
● /screens & /widgets: UI only. Keep files small. Extract complex widgets into their own files.
3. Local Storage: Use shared_preferences for local app state (e.g., theme toggles, onboarding
status).
4. Database: Use [Firebase Firestore OR PostgreSQL] for persistent cloud data.
5. Stepwise Execution: Only implement the specific step requested in the prompt. Do not jump ahead.

## App specific requirements ###

1. User Onboarding: The app must provide a welcome or home screen. The home screen must include a Get Started button. Selecting Get Started must navigate the user to create a account using valid email and password - email should be valid and password should me atleast 6 characters long with, atleast one number, one special character and one Capital letter. 

2. After the user successfully creates their account the user then follows a questionnaire flow. The app should include a brief explanation that the simulator is educational and does not provide real financial advice.

3. The app must collect user inputs through a multi-step questionnaire. Each question must appear on its own screen. The questionnaire must include a visible progress indicator, such as Step 1 of 5. The user must be able to move forward and backward through the questionnaire. The app must save answers as the user progresses.

4. The questionnaire should collect at minimum: Investment objective (growth, preservation, balanced) Financial goal (house, education, retirement, emergency fund, other) Risk tolerance (low, medium, high, no preference) Time horizon (short-term, medium-term, long-term) Financial profile or starting amount. Optional recurring contribution amount. Optional income range or budget range

5. The app must create a basic financial profile from questionnaire responses. It must store the user’s profile for future sessions. The app must allow the user to review and update their profile later.

6. The app should save past simulations for the user. The user should be able to revisit previous simulation results. Each saved simulation should include: Date created, User inputs, Suggested strategy and Projected result summary. 

7. The app should explain key concepts in simple language, such as: Risk tolerance, Diversification, Time horizon,, Conservative vs. growth investing. The app should include short tooltips or help text.

