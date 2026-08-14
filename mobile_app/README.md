# 📱 THALIR 360° Teacher Assistant Mobile Application

This directory is designated for the **360° Teacher Assistant Mobile App** codebase.

## 📲 Instructions for Mobile App Developer

1. **Firebase Connection**:
   - Connect your mobile app to Firebase Project ID: `dropout-prediction-af891`
   - Storage Bucket: `dropout-prediction-af891.firebasestorage.app`

2. **Firestore Collections**:
   - `students`: Read & write student profiles.
   - `dropout_predictions`: Read live XGBoost predictions & SHAP risk drivers (`riskDrivers` string, `riskScore` %, `riskLabel`).
   - `intervention_recommendations`: Read & write 4-pillar support requests.
   - `meetings`: Log parent-teacher meeting notes.
   - `ocr_history`: Log mark sheet OCR scan logs.

3. **Field Aliases**:
   - Always output multi-alias keys (`name`/`studentName`/`fullName`, `classId`/`class`/`grade`, `rollNumber`/`rollNo`, `fatherName`/`motherName`, `guardianContact`).

4. **Class Naming**:
   - Use standard class names (`Class VIII-A`, `Class IX-A`, `Class X-A`, `Class XI-A`, `Class XII-A`).
