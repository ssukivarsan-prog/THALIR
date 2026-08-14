# Dataset Directory

Paste your dataset files (CSV, XLSX, JSON, etc.) in this folder (`data/`).

### Expected CSV Format (Optional Reference):
- `student_id` (or `roll_number`)
- `name`
- `class_id` / `standard` / `division`
- `attendance_rate` (0.0 to 1.0 or 0 to 100%)
- `backlog_count` (0, 1, 2, ...)
- `gpa` (0.0 to 4.0)
- `assignment_completion_rate` (0.0 to 1.0)
- `study_hours_weekly`
- `dropout` (0 for active, 1 for dropout)

Once you paste your datasets here, let me know and I will update [scripts/train_model.py](file:///d:/WEB%20PROJECTS/aistudentdropoutprediction/scripts/train_model.py) to load and train the XGBoost model on your real datasets!
