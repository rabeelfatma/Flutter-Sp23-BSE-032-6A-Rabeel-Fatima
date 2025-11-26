
<img width="300" height="700" alt="image" src="https://github.com/user-attachments/assets/d5d047cf-77cd-4661-9847-b145b029c343" />
<img width="300" height="700" alt="image" src="https://github.com/user-attachments/assets/22b71481-7eb0-4377-8c9e-099337c4c8d0" />
<img width="640" height="497" alt="image" src="https://github.com/user-attachments/assets/f8f197d1-0b30-446a-b007-1d3a274f2c08" />

                                                       
                                                        
                                                        
                                                        Data Flow:

1. User Input (InputPage)

Gender Selection

User taps male/female card → selectGender state updates.

Height Input

User moves Slider → sliderHeight state updates.

Weight & Age

Optional placeholders; user can input weight/age in future expansion.

Interaction: All input changes trigger setState() to update UI.

2. Data Processing (CalculatorBrain)

When user taps CALCULATE:

Create CalculatorBrain(height, weight) object.

calculator() → computes BMI: weight / (height/100)^2

getResult() → returns Underweight / Normal / Overweight

getInterpretation() → returns explanation text.

3. Output Display (ResultScreen)

Receives:

bmiResult → calculated BMI (string)

resultText → BMI category

interpretation → advice

UI shows:

Top: "Your Result"

Middle: BMI number + category + explanation

Bottom: RE-CALCULATE button → navigates back to InputPage.

4. UI Components (Reusable Widgets)

RepeatContainerCode: Generic colored container with optional child and tap handler.

RepeatTextandIconWidget: Column showing icon + label (used for gender cards).

5. State & Navigation Flow

InputPage holds user input state (selectGender, sliderHeight, etc.).

CalculatorBrain performs stateless computation.

ResultScreen is stateless; shows processed BMI result.

Navigation via Navigator.push() → ResultScreen and Navigator.pop() → back to InputPage.


# bmi_app

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
