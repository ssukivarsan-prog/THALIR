# 📲 Firebase & Cloud Firestore Data Schema Specification

This document contains the exact Firebase configuration, collection names, field entity schemas, data types, and JSON examples for developer integration between the **Teacher Mobile App** and the **Headmaster & Municipality Web Portal**.

---

## 🔑 1. Firebase Project Details

- **Firebase Project ID**: `dropout-prediction-af891`
- **Project Number**: `775748763322`
- **Database Location**: `asia-south1`
- **Database Engine**: Cloud Firestore `(default)`

---

## 📁 2. Cloud Firestore Collections

The database uses the following **5 exact lowercase collection names**:

1. `students`
2. `dropout_predictions`
3. `intervention_recommendations`
4. `meetings`
5. `ocr_history`

---

## 📋 3. Entity Schemas & Field Names

### Collection 1: `students`
> **Document ID**: `studentId` (e.g. `"std-8A-101"`)

| Primary Field Name | Supported Field Aliases | Data Type | Description / Example |
| :--- | :--- | :--- | :--- |
| `studentId` | `id` | String | Unique Student ID (e.g. `"std-8A-101"`) |
| `schoolId` | `school` | String | School ID (e.g. `"school-greenwood-01"`) |
| `name` | `studentName`, `fullName` | String | Full name of student (e.g. `"Karthik Subramanian"`) |
| `rollNumber` | `rollNo`, `roll_no` | String | Roll number (e.g. `"8A-15"`) |
| `classId` | `class`, `grade`, `standard` | String | Class & Division (e.g. `"Grade 8-A"`, `"8 A"`) |
| `gender` | - | String | `"Male"`, `"Female"`, or `"Other"` |
| `fatherName` | `father`, `father_name` | String | Father's Name (e.g. `"Ramesh Subramanian"`) |
| `motherName` | `mother`, `mother_name` | String | Mother's Name (e.g. `"Lakshmi Subramanian"`) |
| `guardianContact` | `phone`, `parentContact` | String | Parent Phone Number (e.g. `"+91 98765 12345"`) |

#### JSON Example (`students/{studentId}`):
```json
{
  "studentId": "std-8A-101",
  "id": "std-8A-101",
  "schoolId": "school-greenwood-01",
  "name": "Karthik Subramanian",
  "studentName": "Karthik Subramanian",
  "fullName": "Karthik Subramanian",
  "rollNumber": "8A-15",
  "rollNo": "8A-15",
  "classId": "Grade 8-A",
  "class": "Grade 8-A",
  "grade": "Grade 8-A",
  "standard": "Grade 8-A",
  "gender": "Male",
  "fatherName": "Ramesh Subramanian",
  "father": "Ramesh Subramanian",
  "motherName": "Lakshmi Subramanian",
  "mother": "Lakshmi Subramanian",
  "guardianContact": "+91 98765 12345",
  "phone": "+91 98765 12345",
  "parentContact": "+91 98765 12345"
}
```

---

### Collection 2: `dropout_predictions`
> **Document ID**: Matches `studentId` (e.g. `"std-8A-101"`)

| Field Name | Data Type | Description / Example |
| :--- | :--- | :--- |
| `studentId` | String | Target student ID (e.g. `"std-8A-101"`) |
| `riskScore` | double | Value from `0.0` to `1.0` (e.g. `0.85` = 85% risk) |
| `riskLabel` | String | `"high"`, `"medium"`, or `"low"` |
| `modelVersion` | String | XGBoost model version (e.g. `"v2.1-XGBoost"`) |
| `principalNotes` | String | Verification notes by Headmaster |
| `interventionStatus` | String | `"Pending Review"`, `"Counseling Scheduled"`, `"Resolved"` |
| `topFactors` | Array of Maps | SHAP factor analysis objects |

#### `topFactors` Item Structure:
```json
{
  "factorName": "Attendance Deficit",
  "impactLevel": "high_negative",
  "plainTextDescription": "Critical attendance drop (65% attendance rate vs 85% requirement).",
  "weight": 0.85
}
```

#### JSON Example (`dropout_predictions/{studentId}`):
```json
{
  "studentId": "std-8A-101",
  "riskScore": 0.85,
  "riskLabel": "high",
  "modelVersion": "v2.1-XGBoost",
  "principalNotes": "Verified by Headmaster. Recommended for Agaram Scholarship.",
  "interventionStatus": "Pending Review",
  "topFactors": [
    {
      "factorName": "Attendance Deficit",
      "impactLevel": "high_negative",
      "plainTextDescription": "Critical attendance drop (65% attendance rate vs 85% requirement).",
      "weight": 0.85
    },
    {
      "factorName": "Failed Subject Arrears",
      "impactLevel": "high_negative",
      "plainTextDescription": "Student has 2 active subject arrear(s) requiring remedial coaching.",
      "weight": 0.75
    }
  ]
}
```

---

### Collection 3: `intervention_recommendations` (4-Pillar Support System)
> **Document ID**: `recommendationId` (e.g. `"rec-101"`)

| Field Name | Data Type | Description / Example |
| :--- | :--- | :--- |
| `recommendationId` | String | Unique Recommendation ID (e.g. `"rec-101"`) |
| `studentId` | String | Target student ID |
| `studentName` | String | Student's full name |
| `schoolId` | String | School ID |
| `schoolName` | String | School name |
| `classId` | String | Class (e.g. `"Grade 8-A"`) |
| `teacherName` | String | Name of teacher submitting request |
| `pillarType` | String | `"scholarship"`, `"hostel"`, `"subject_coaching"`, `"extracurricular_talent"` |
| `targetEntity` | String | Target organization (e.g. `"Agaram Foundation Educational Scholarship"`, `"Govt BC Welfare Hostel"`, `"SDAT Sports Quota"`) |
| `reasonNotes` | String | Teacher's situation notes on the student |
| `status` | String | Pipeline Status: <br>1. `"Pending Principal Review"` (Submitted by Teacher)<br>2. `"Approved by Principal (Sent to Municipality)"` (Approved by HM)<br>3. `"Municipality Endorsed & Dispatched"` (Endorsed by Municipality CEO) |
| `principalNotes` | String | Verification notes by Principal |
| `municipalityNotes` | String | Approval notes by Municipality CEO |
| `createdAt` | Timestamp | Creation timestamp |
| `updatedAt` | Timestamp | Last updated timestamp |

---

### Collection 4: `meetings`
> **Document ID**: `meetingId` (e.g. `"mtg-101"`)

| Field Name | Data Type | Description / Example |
| :--- | :--- | :--- |
| `meetingId` | String | Unique Meeting ID |
| `title` | String | Meeting title |
| `studentId` | String | Target student ID |
| `studentName` | String | Student's full name |
| `scheduledDate` | Timestamp | Scheduled date and time |
| `notes` | String | Meeting agenda or notes |
| `status` | String | `"Scheduled"`, `"Completed"`, `"Cancelled"` |

---

### Collection 5: `ocr_history`
> **Document ID**: `ocrId` (e.g. `"ocr-101"`)

| Field Name | Data Type | Description / Example |
| :--- | :--- | :--- |
| `ocrId` | String | Unique OCR Scan ID |
| `teacherName` | String | Teacher who scanned document |
| `className` | String | Class section |
| `rawText` | String | Extracted text from attendance / marksheet scan |
| `scannedDate` | Timestamp | Scan timestamp |
