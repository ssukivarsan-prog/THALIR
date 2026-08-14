# 🤖 THALIR ML Engine — Standalone XGBoost Dropout Prediction Engine

This directory contains the machine learning pipeline for **THALIR (தளீர்)**.

## 📌 Architecture

- **`scripts/train_model.py`**: Python script for preprocessing raw student datasets, computing SHAP impact feature weights, training XGBoost classifier, and evaluating model accuracy.
- **`data/`**: Raw student performance CSV datasets & preprocessed feature datasets.
- **`models/`**: Serialized XGBoost model artifacts (`xgboost_dropout_v2.json`) and SHAP feature weight configurations.

## 🚀 How to Run Model Training

```bash
# 1. Install dependencies
pip install xgboost scikit-learn pandas numpy shap

# 2. Train XGBoost Dropout Prediction Model
python scripts/train_model.py
```

## 📊 SHAP Feature Impact Weights

1. **`attendance_rate`**: Overall attendance percentage (SHAP Weight ~2.8)
2. **`academic_avg` / `marks`**: Subject examination average (SHAP Weight ~2.4)
3. **`backlog_count`**: Failed subject arrear count (SHAP Weight ~1.6)
4. **`assignment_rate`**: Homework completion percentage (SHAP Weight ~0.6)
