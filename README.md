# 🌱 THALIR (தளீர்) — AI-Powered Student Retention & Support Platform

> **"தளிர்கள் வளரட்டும், கல்வி ஒளிரட்டும்"**  
> *"Let the young sprouts grow, let education shine bright!"*  
> **Official Tamil Nadu Municipal Education Board Initiative** | **Version 1.0.0**

---

## 📌 Executive Summary

**THALIR (தளீர்)** is an early-warning student retention platform built for school headmasters, teachers, and municipal education directors. It uses a trained **XGBoost Machine Learning model** to process student attendance, academic marks, and subject arrear indicators, identifying dropout risks early and mapping students to targeted **4-Pillar Support Interventions** (Financial Scholarships, Hostel Placements, Nutrition, and Remedial Counseling).

---

## 🏗️ Monorepo Directory Architecture

This repository is structured as a **modular monorepo** separating the Web Portal, Mobile Teacher App, and Machine Learning Engine:

```
THALIR/
├── README.md                          <-- Master Architecture & System Documentation
├── FIRESTORE_DATA_SCHEMA.md           <-- Universal Cloud Firestore Data Contract & Schemas
├── firestore.rules                    <-- Cloud Firestore Security Rules
│
├── web_app/ (or Root Web App)         <-- Headmaster & Municipality Executive Web Portal (Flutter Web)
│   ├── lib/                           <-- Dashboard Providers, Screens, Models, Services
│   │   ├── models/                    <-- Student, Prediction, Recommendation, School Models
│   │   ├── providers/                 <-- Dashboard State Management & Live Firestore Streams
│   │   ├── screens/                   <-- Executive Overview, Class Breakdown, Support Hub
│   │   ├── services/                  <-- Firestore Realtime Sync & XGBoost Engine
│   │   └── widgets/                   <-- HeaderBar, AppDrawer, AddStudentModal, StatCards
│   └── web/                           <-- Web Entrypoint, Index HTML, Favicons & Manifest
│
├── mobile_app/                        <-- 360° Teacher Assistant Mobile Application (Mobile Dev Area)
│   ├── android/ / ios/ / lib/         <-- Mobile App Source Code (Pushed by Mobile Developer)
│   └── pubspec.yaml
│
└── ml_engine/                         <-- Standalone Machine Learning Engine & Pipeline
    ├── scripts/
    │   └── train_model.py             <-- XGBoost Training, Preprocessing & Feature Engineering
    ├── models/
    │   └── xgboost_dropout_v2.json    <-- Serialized Model Weights & SHAP Explainer Config
    └── data/
        ├── raw_student_data.csv       <-- Academic & Attendance Historical Training Dataset
        └── processed_features.parquet
```

---

## 🤖 XGBoost Machine Learning Engine (`ml_engine/`)

The **XGBoost Inference Engine** operates independently and evaluates student retention indicators using SHAP (SHapley Additive exPlanations) feature impact weights:

### 1. Model Input Features:
- **`attendanceRate`**: Overall school attendance percentage (0.0% – 100.0%)
- **`academicAvg`**: Term examination score average (0.0% – 100.0%)
- **`backlogs`**: Active failed subject arrears count (0 – 10)
- **`assignmentRate`**: Homework completion percentage (0.0% – 100.0%)

### 2. Model Output Payload:
- **`riskScore`**: Probability score between `0.0` (0%) and `1.0` (100%)
- **`riskLabel`**: `"high"` (≥70%) | `"medium"` (35%–69%) | `"low"` (<35%)
- **`riskDrivers` / `topFactors`**: Human-readable SHAP impact explanations:
  - e.g. `"Attendance rate dropped to 64.0%."`
  - e.g. `"Failed Mathematics with 52.0% average."`

### 3. Fresh Student Enrollment Rule:
- When a student is **newly enrolled** by the Headmaster, their baseline risk score is set to **`0.0%` (NOT AT RISK)** with initial attendance at `0%` starting from scratch until the Class Teacher logs daily attendance and test marks in the Teacher App.

---

## 🔥 Cloud Firestore Database Contract (`dropout-prediction-af891`)

Both **Web Portal** and **Mobile App** connect to the exact same Firebase project:

- **Firebase Project ID**: `dropout-prediction-af891`
- **Project Number**: `775748763322`
- **Storage Bucket**: `dropout-prediction-af891.firebasestorage.app`

### Real-Time Firestore Collections:

| Collection Name | Document Key | Key Field Aliases Serialized | Description |
| :--- | :--- | :--- | :--- |
| **`students`** | `{studentId}` | `name`, `studentName`, `fullName`, `classId`, `class`, `rollNumber`, `rollNo`, `fatherName`, `motherName`, `guardianContact` | Student Profile Master Directory |
| **`dropout_predictions`** | `{studentId}` | `riskScore`, `score`, `riskPercentage`, `riskLabel`, `label`, `riskLevel`, `riskDrivers`, `drivers`, `topFactors`, `modelVersion` | AI Dropout Risk & SHAP Explanations Payload |
| **`intervention_recommendations`** | `{recommendationId}` | `recommendationId`, `studentId`, `studentName`, `pillarType`, `targetEntity`, `reasonNotes`, `status`, `principalNotes` | 4-Pillar Support Recommendations |
| **`meetings`** | `{meetingId}` | `meetingId`, `studentId`, `date`, `notes`, `participants` | Parent-Teacher & Officer Counseling Logs |
| **`ocr_history`** | `{scanId}` | `scanId`, `timestamp`, `scannedText`, `parsedMarks` | Digitized Mark Sheet Scan History |

---

## 📲 Guidelines for Mobile App Developer

1. **Firestore Field Aliases**:
   - Always read and write multi-alias keys (`name` / `studentName` / `fullName`, `classId` / `class` / `grade`, `rollNumber` / `rollNo`).
2. **Roman Numeral Class Matching**:
   - Use standard class names (`Class VIII-A`, `Class IX-A`, `Class X-A`). The Web Portal uses automated Roman numeral normalization (`VIII` = `8`, `IX` = `9`, `X` = `10`) to match roster selections automatically.
3. **Pushing Mobile Code**:
   - Push all mobile Flutter code into the **`mobile_app/`** directory in this repository.

---

## 🚀 How to Push Code to GitHub (`ssukivarsan-prog/THALIR`)

Run the following terminal commands to link your workspace to the remote repository and push all updates:

```bash
# 1. Initialize Git repository
git init

# 2. Add remote repository URL
git remote add origin https://github.com/ssukivarsan-prog/THALIR.git

# 3. Stage all files
git add .

# 4. Commit changes
git commit -m "Initial commit: THALIR Student Retention Web Portal, ML Engine & Firestore Schema"

# 5. Set main branch and push
git branch -M main
git push -u origin main --force
```

---
