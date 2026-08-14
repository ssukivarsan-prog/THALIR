
# 🌱 THALIR

## AI-Powered Student Dropout Prediction & Early Intervention Platform

> **Predict Risk. Understand the Student. Nurture Potential.**

**THALIR** is an AI-powered student dropout prediction and early-intervention platform designed to identify students who may be at risk of dropping out and help teachers take timely, informed action.

The core of THALIR is an **XGBoost-based machine learning model** that predicts dropout risk using **attendance and academic performance/marks** as primary indicators.

Unlike a conventional prediction system, THALIR connects the prediction with a **360° student profile**, combining academics, attendance, activities, achievements, talent recognition and teacher observations.

---

## 🎯 Problem

Student dropout is rarely caused by a single factor.

Early warning signals may include:

- Declining attendance
- Falling academic performance
- Repeated absence
- Learning difficulties
- Reduced participation
- Lack of academic support
- Lack of recognition for student strengths

However, school information is often fragmented across:

```text
Attendance Registers
        +
Mark Sheets
        +
Examination Records
        +
Teacher Observations
        +
Activity Records
````

This makes it difficult to identify students who need support at an early stage.

---

# 💡 Our Solution

THALIR follows:

```text
CAPTURE
   ↓
PREDICT
   ↓
EXPLAIN
   ↓
UNDERSTAND
   ↓
SUPPORT
   ↓
FOLLOW UP
```

The platform combines:

* XGBoost dropout prediction
* OCR-based school record digitization
* 360° student profiles
* Academic and attendance trend analysis
* Activity and talent recognition
* Achievement tracking
* AI meeting-ready summaries
* Speech-based teacher notes
* Follow-up and future intervention workflows

---

# 🤖 XGBoost Dropout Prediction

The **primary ML component** of THALIR is an XGBoost classifier.

### Primary Prediction Inputs

* Attendance percentage
* Attendance trends
* Assessment marks
* Examination marks
* Academic average
* Academic performance trends

### Prediction Flow

```text
Student Data
     ↓
Data Preprocessing
     ↓
Feature Engineering
     ↓
XGBoost
     ↓
Dropout Probability
     ↓
Risk Category
     ↓
Explainable Indicators
```

Example:

```text
Student: Arun Kumar

Dropout Risk
82% 🔴 HIGH

Attendance: 64%
Academic Average: 51%

Major Indicators:
• Attendance decline
• Academic performance decline
```

> The prediction is an early-warning signal and should support human decision-making rather than permanently label a student.

---

# 📊 Model Evaluation

The model should be evaluated using appropriate classification metrics:

* Accuracy
* Precision
* Recall
* F1-Score
* ROC-AUC
* Confusion Matrix

For an early-warning system, **Recall for the at-risk class** is particularly important because missing a genuinely at-risk student can result in a missed opportunity for intervention.

> Add the actual model metrics here after final evaluation. Do not use placeholder values in the final submission.

---

# 📸 OCR-Based School Record Capture

Teachers can digitize paper-based school records using OCR.

### Supported Records

#### Attendance

* Student name
* Roll number
* Student ID
* Date
* Present/Absent

#### Academic Marks

* Student
* Subject
* Assessment
* Marks
* Maximum marks

#### Examination Marks

* Examination
* Subject
* Marks
* Grade
* Maximum marks
* Date

---

## OCR Workflow

```text
Capture Image
      ↓
OCR Processing
      ↓
Extract Data
      ↓
Confidence Check
      ↓
Teacher Verification
      ↓
Correct / Confirm
      ↓
Student Database
```

THALIR does not blindly save OCR results.

Teachers can:

* Edit
* Confirm
* Reject
* Rescan

The system can identify:

* Low-confidence OCR
* Missing values
* Duplicate student IDs
* Unknown students
* Invalid attendance
* Marks above maximum
* Potential OCR errors

---

# 👨‍🎓 360° Student Profile

THALIR creates a complete student profile rather than focusing only on marks.

### 📚 Academics

* Subject-wise marks
* Unit tests
* Internal assessments
* Examination results
* Academic average
* Performance trends

### 📅 Attendance

* Daily attendance
* Monthly attendance
* Term attendance
* Overall attendance
* Attendance trends

### ⭐ Activities

* Sports
* Arts
* Debate
* Science exhibitions
* Cultural activities
* Leadership
* Volunteering
* Clubs
* Technology activities

### 🏆 Achievements

* Competition awards
* Sports achievements
* Academic achievements
* Certifications
* Cultural achievements
* Community contributions

### 🎯 Strengths & Interests

* Sports
* Creative arts
* Communication
* Leadership
* Technology
* Innovation
* Community participation

### 📝 Teacher Observations

* Positive observations
* Academic concerns
* Student interests
* Meeting notes
* Follow-up history

---

# 🌟 Talent & Recognition

> **Every student is more than their marks.**

THALIR records student participation and achievements to make strengths visible.

Example:

```text
Drawing Activity
       ↓
Poster Competition
       ↓
Art Exhibition
       ↓
District Competition
       ↓
Potential Strength:
Visual Arts
```

Possible recognition categories:

* 🎨 Creativity
* 🏃 Sports
* 🎤 Communication
* 🤝 Leadership
* 💻 Technology
* 🌱 Community Contribution
* 📈 Academic Improvement

The system should not label a student as talented based on a single activity. Repeated participation, achievements and teacher confirmation provide stronger evidence.

---

# 🧠 AI Meeting-Ready Student Summary

Teachers can generate a concise summary before meeting a student.

### Example

```text
STUDENT: Arun Kumar

Attendance: 68%
Academic Average: 57%

Recent Changes:
• Attendance declining
• Mathematics performance declining

Strengths:
• Science improving
• Strong sports participation

Suggested Discussion:
• Understand recent attendance changes
• Discuss Mathematics difficulties
• Explore suitable academic support
```

This helps teachers approach students with context rather than relying only on a prediction score.

---

# 🎤 Speech-Based Teacher Notes

Teachers can record observations using voice.

Example:

> "Arun is struggling with Mathematics and requested support from a senior student. Follow up next Friday."

The system can convert this into:

```text
Academic Concern:
Mathematics difficulty

Support Requested:
Peer academic support

Follow-up:
Next Friday
```

The teacher reviews and confirms the information before saving it.

---

# 🔊 Text-to-Speech

The AI meeting summary can optionally be read aloud.

Controls:

* ▶ Play
* ⏸ Pause
* ⏹ Stop

This helps teachers quickly review student information.

---

# 📈 Student Trend Analysis

THALIR focuses on changes over time.

Example:

```text
Mathematics

Test 1     72%
Test 2     61%
Test 3     43%

⚠ Declining Trend
```

Attendance:

```text
June       91%
July       82%
August     68%

⚠ Attendance Decline
```

These trends can contribute to early-warning analysis.

---

# 🏫 Teacher Dashboard

The teacher dashboard provides:

* Assigned classes
* Total students
* Students requiring attention
* Pending OCR verification
* Upcoming meetings
* Follow-ups
* Recent student activities

Example:

```text
VIII-A

Students       42
Stable         31
Monitor         6
Needs Attention 4
Critical        1
```

---

# 📅 Follow-Up Management

After interacting with a student, teachers can create follow-ups.

Options:

* Tomorrow
* 7 days
* 2 weeks
* Custom date

Each follow-up can contain:

* Student
* Concern
* Previous action
* Next action
* Due date
* Status

---

# 🚨 Future Intervention Framework

THALIR is designed to eventually connect identified needs with verified support resources.

```text
Academic Difficulty
        ↓
Remedial / Peer Support

Financial Difficulty
        ↓
Scholarship / Financial Assistance

Accommodation Difficulty
        ↓
Hostel / Transport Support

Skill Gap
        ↓
Mentor / Skill Development

Career Interest
        ↓
Career Guidance / Internship
```

These intervention modules are part of the future platform roadmap.

---

# 🏗️ Software Architecture

```text
                 TEACHER
                    │
                    ↓
          ┌──────────────────┐
          │ Flutter App      │
          └────────┬─────────┘
                   │
        ┌──────────┼──────────┐
        ↓          ↓          ↓
       OCR     Manual Input  Voice
        │          │          │
        └──────────┼──────────┘
                   ↓
          Data Verification
                   ↓
          Student Data Layer
                   ↓
       ┌───────────┴───────────┐
       ↓                       ↓
Attendance + Marks      Activities +
       ↓                 Achievements
       └───────────┬───────────┘
                   ↓
             XGBoost Model
                   ↓
          Dropout Risk Score
                   ↓
         Explainable Insights
                   ↓
          360° Student Profile
                   ↓
       Teacher Action & Follow-up
                   ↓
        Future Intervention Layer
```

---

# 🔄 End-to-End Workflow

```text
Teacher Login
     ↓
Select Class
     ↓
Scan Attendance
     ↓
OCR Extraction
     ↓
Teacher Verification
     ↓
Scan Marks / Exams
     ↓
Update Student Profile
     ↓
XGBoost Prediction
     ↓
Dropout Risk
     ↓
Explain Risk Indicators
     ↓
Open 360° Student Profile
     ↓
Generate Meeting Brief
     ↓
Meet Student
     ↓
Record Voice Note
     ↓
Teacher Confirmation
     ↓
Follow-up
     ↓
Support / Escalation
```

---

# 🛠️ Technology Stack

## Frontend

* Flutter
* Dart

## Backend & Database

* Firebase Authentication
* Cloud Firestore
* Firebase Storage
* REST APIs

## Machine Learning

* Python
* XGBoost
* Pandas
* NumPy
* Scikit-learn

## AI & Intelligent Input

* OCR
* Speech-to-Text
* Text-to-Speech
* SHAP / Explainability

## Development

* Git
* GitHub

> Update this section according to the technologies actually implemented in the final repository.

---

# 🔐 Privacy & Responsible AI

Student information is sensitive.

THALIR follows a human-centered approach:

* Secure authentication
* Role-based access
* Minimum necessary data access
* Protected student records
* Teacher verification of OCR results
* Explainable prediction outputs
* Human review before important interventions
* Aggregated/anonymized reporting where appropriate

### Core principle

> **AI identifies a signal. Humans understand the situation. Support follows.**

The system should never state:

> "This student will drop out."

Instead:

> "This student shows indicators associated with elevated dropout risk. Teacher review is recommended."

---

# 📱 Teacher App Navigation

```text
🏠 Home
│
├── My Classes
├── Attention Required
├── Pending OCR
└── Follow-ups

📸 Capture
│
├── Scan Attendance
├── Scan Marks
├── Scan Exams
├── Record Activity
└── Voice Note

👨‍🎓 Students
│
├── Student Profile
├── Academics
├── Attendance
├── Activities
├── Achievements
└── Timeline

⭐ Activities
│
├── Record Activity
├── Recognize Student
└── Activity History

📅 Meetings
│
├── Meeting Brief
├── Voice Notes
├── Meeting History
└── Follow-ups
```

---

# 📊 Dataset Strategy

The prediction model should use a validated student dataset containing relevant academic and attendance information.

### Example Features

| Category    | Example                             |
| ----------- | ----------------------------------- |
| Attendance  | Attendance %, absence trend         |
| Academics   | Test marks, exam marks              |
| Performance | Academic average, performance trend |
| Engagement  | Validated activity information      |
| Target      | Dropout / Retained                  |

The final project should document:

* Dataset source
* Number of records
* Features
* Target variable
* Class distribution
* Preprocessing
* Train/test split
* Feature engineering

---

# 🧪 Testing

Run Flutter analysis:

```bash
flutter analyze
```

Run tests:

```bash
flutter test
```

Build Android application:

```bash
flutter build apk
```

Test ML pipeline independently before connecting it to the mobile application.

---

# 📁 Suggested Project Structure

```text
thalir/
│
├── lib/
│   ├── core/
│   │   ├── constants/
│   │   ├── theme/
│   │   ├── routes/
│   │   └── utils/
│   │
│   ├── features/
│   │   ├── auth/
│   │   ├── dashboard/
│   │   ├── ocr/
│   │   ├── students/
│   │   ├── attendance/
│   │   ├── academics/
│   │   ├── activities/
│   │   ├── achievements/
│   │   ├── meetings/
│   │   └── voice/
│   │
│   ├── data/
│   │   ├── models/
│   │   ├── repositories/
│   │   └── services/
│   │
│   └── main.dart
│
├── assets/
├── test/
├── README.md
└── pubspec.yaml
```

---

# 🚀 Getting Started

## Prerequisites

* Flutter SDK
* Dart SDK
* Android Studio / VS Code
* Firebase project
* Python environment for ML service
* Git

## Clone Repository

```bash
git clone https://github.com/<YOUR-USERNAME>/<YOUR-REPOSITORY>.git
cd <YOUR-REPOSITORY>
```

## Install Dependencies

```bash
flutter pub get
```

## Configure Firebase

Add your Firebase configuration according to the target platform.

## Run Application

```bash
flutter run
```

---

# 🗺️ Roadmap

### Phase 1 — Prediction Core

* XGBoost
* Attendance + marks prediction
* Dataset improvement
* Model evaluation
* Explainability

### Phase 2 — Teacher Intelligence

* OCR
* Student profiles
* Academic trends
* Attendance trends
* Meeting assistant
* Speech notes

### Phase 3 — Student Growth

* Activity tracking
* Talent recognition
* Achievements
* Recognition system

### Phase 4 — Intervention

* Scholarship matching
* Hostel support
* Transport support
* Peer mentoring
* Skill development
* Career guidance

### Phase 5 — School Ecosystem

```text
Teacher
   ↓
HM
   ↓
Principal
   ↓
Municipality / Education Department
```

Future capabilities:

* School-level dropout monitoring
* Resource allocation
* Regional risk analysis
* Intervention tracking
* Education planning

---

# 👥 Team BITZAPP

### Prasanna G G

**Team Lead | Flutter & Product Development**

Key focus:

* Flutter application
* Product architecture
* OCR workflow
* 360° student profile
* Teacher experience
* Activity and talent recognition
* Meeting assistant
* Speech-based notes
* Product integration

### Sukivarsan S

**Machine Learning & AI**

Key focus:

* XGBoost dropout prediction
* Dataset preparation
* Feature engineering
* Model training
* Model evaluation
* Prediction analysis
* Explainability
* ML integration

---

# 🏆 Why THALIR?

| Traditional Approach       | THALIR                    |
| -------------------------- | ------------------------- |
| Manual record entry        | OCR-assisted capture      |
| Marks-focused              | 360° student profile      |
| Prediction only            | Prediction + intervention |
| Static records             | Longitudinal trends       |
| Risk-only approach         | Risk + strengths          |
| Talent often undocumented  | Talent recognition        |
| Manual meeting preparation | AI meeting brief          |
| Manual notes               | Speech-based notes        |
| Fragmented information     | Unified student profile   |

---

# 🌱 Vision

THALIR is built around a simple belief:

> **Every student is more than their marks.**

The goal is not only to predict:

> **“Who is at risk?”**

but also to understand:

> **“Why might they be at risk?”**

and recognize:

> **“What strengths can help them continue and grow?”**

Ultimately:

```text
Predict Risk
     ↓
Understand the Student
     ↓
Recognize Potential
     ↓
Support Early
     ↓
Prevent Dropout
```

---

# 📌 Project Status

Update these according to your actual implementation:

* [ ] XGBoost model trained
* [ ] Model evaluation completed
* [ ] Explainability implemented
* [ ] Flutter teacher app
* [ ] Firebase integration
* [ ] OCR integration
* [ ] OCR verification
* [ ] Student profile
* [ ] Attendance module
* [ ] Academic module
* [ ] Activity recognition
* [ ] Achievement tracking
* [ ] Meeting assistant
* [ ] Speech-to-text
* [ ] Text-to-speech
* [ ] Follow-up system
* [ ] ML API integration
* [ ] Offline synchronization

---

# 📄 Evidence & Documentation

The repository should contain:

* Dataset documentation
* Model training code
* Evaluation metrics
* Confusion matrix
* Feature importance / SHAP results
* OCR screenshots
* Flutter application screenshots
* Student profile screenshots
* Architecture diagram
* Project report
* Presentation

---

# ⚠️ Important

Do not commit:

* API keys
* Firebase private credentials
* Service-account files
* Passwords
* Real student personal information
* Confidential school records

Use synthetic/demo student data for public demonstrations.

---

# 📜 License

This project is developed for educational, research and hackathon purposes.

Add an appropriate open-source license before public distribution.

---

# 🌱 THALIR

### **AI-Powered Student Dropout Prediction & Early Intervention**

> **Predict Risk. Understand the Student. Nurture Potential.**

**HACKORBIT 2K26 • BITZAPP • Bannari Amman Institute of Technology**

```
```
