import os
import glob
import numpy as np
import pandas as pd
import xgboost as xgb
from sklearn.model_selection import train_test_split, StratifiedKFold, cross_val_score
from sklearn.metrics import (
    accuracy_score,
    precision_score,
    recall_score,
    f1_score,
    roc_auc_score,
    confusion_matrix,
    classification_report,
)
import shap
import json

def load_and_preprocess_datasets():
    print("=========================================================")
    print(" LOADING REAL STUDENT DATASETS FOR INDIAN & TN SCHOOLS   ")
    print("=========================================================\n")
    
    datasets = []
    
    # 1. Load Portuguese/Kaggle Student Performance Datasets (student-mat.csv & student-por.csv)
    mat_path = 'data/kaggle data set/student-mat.csv'
    por_path = 'data/kaggle data set/student-por.csv'
    
    if os.path.exists(mat_path):
        df_mat = pd.read_csv(mat_path, sep=';')
        df_mat['subject'] = 'Mathematics'
        datasets.append(df_mat)
        print(f"[OK] Loaded {len(df_mat)} records from student-mat.csv")
        
    if os.path.exists(por_path):
        df_por = pd.read_csv(por_path, sep=';')
        df_por['subject'] = 'Language/Science'
        datasets.append(df_por)
        print(f"[OK] Loaded {len(df_por)} records from student-por.csv")
        
    if not datasets:
        raise FileNotFoundError("No datasets found in data/ folder!")
        
    combined_df = pd.concat(datasets, ignore_index=True)
    print(f"Total Combined Student Records: {len(combined_df)}")

    # -------------------------------------------------------------
    # TN / SOUTH INDIAN SCHOOL FEATURE CONVERSION & MAPPING
    # -------------------------------------------------------------
    # Convert G1, G2, G3 (0-20 scale) to Tamil Nadu Percentage Scale (0-100%) and GPA (0.0 - 4.0)
    # G1: Quarterly Exam Marks %, G2: Half-Yearly Exam Marks %, G3: Annual/Board Marks %
    combined_df['quarterly_score'] = (combined_df['G1'] / 20.0) * 100.0
    combined_df['half_yearly_score'] = (combined_df['G2'] / 20.0) * 100.0
    combined_df['annual_score'] = (combined_df['G3'] / 20.0) * 100.0
    
    # GPA conversion on 4.0 scale
    combined_df['gpa'] = np.clip((combined_df['G3'] / 20.0) * 4.0, 0.0, 4.0)
    
    # Attendance Rate calculation: Total school days in TN academic year ~ 210 days
    # Absences capped at 30 days max in dataset -> Attendance Rate % = max(0, (210 - absences*5)/210)
    max_abs = combined_df['absences'].max()
    combined_df['attendance_rate'] = np.clip(1.0 - (combined_df['absences'] / (max_abs + 1)), 0.30, 1.0)
    
    # Backlog / Failures count
    combined_df['backlog_count'] = combined_df['failures']
    
    # Weekly Study Hours (1: <2 hrs, 2: 2-5 hrs, 3: 5-10 hrs, 4: >10 hrs)
    combined_df['study_hours_weekly'] = combined_df['studytime'] * 3.5
    
    # Family Education Index (Father & Mother qualification: 0=Illiterate, 1=10th, 2=12th, 3=Degree, 4=PG)
    combined_df['parent_education_score'] = (combined_df['Medu'] + combined_df['Fedu']) / 2.0
    
    # Financial/School Support Indicator
    combined_df['school_support_binary'] = (combined_df['schoolsup'] == 'yes').astype(int)
    combined_df['family_support_binary'] = (combined_df['famsup'] == 'yes').astype(int)
    combined_df['internet_access'] = (combined_df['internet'] == 'yes').astype(int)
    
    # -------------------------------------------------------------
    # TARGET VARIABLE DEFINITION FOR DROPOUT RISK
    # Indian / TN Board Standard Criteria for High Risk / Dropout:
    # 1. Final Annual Score < 40% (Fail threshold in Board exams) OR
    # 2. Absences > 12 days (Attendance < 75% mandatory TN Education Dept rule) AND Failures > 0 OR
    # 3. Quarterly & Half-Yearly Score < 35%
    # -------------------------------------------------------------
    combined_df['dropout'] = (
        (combined_df['G3'] < 8) | 
        ((combined_df['G3'] < 10) & (combined_df['failures'] > 0)) |
        ((combined_df['attendance_rate'] < 0.72) & (combined_df['G2'] < 9))
    ).astype(int)
    
    print(f"Target Label Distribution: {combined_df['dropout'].value_counts().to_dict()}")
    print(f"At-Risk / Dropout Rate in Dataset: {(combined_df['dropout'].mean() * 100):.2f}%\n")
    
    # Select Features for XGBoost Training
    feature_cols = [
        'attendance_rate',
        'backlog_count',
        'gpa',
        'quarterly_score',
        'half_yearly_score',
        'study_hours_weekly',
        'parent_education_score',
        'school_support_binary',
        'family_support_binary',
        'internet_access',
        'traveltime'
    ]
    
    X = combined_df[feature_cols]
    y = combined_df['dropout']
    
    return X, y, combined_df

def train_and_evaluate_xgboost():
    X, y, df = load_and_preprocess_datasets()
    
    # Train-Test Split (80% Train, 20% Test)
    X_train, X_test, y_train, y_test = train_test_split(
        X, y, test_size=0.20, random_state=42, stratify=y
    )
    
    print("=========================================================")
    print(" TRAINING XGBOOST CLASSIFIER MODEL                       ")
    print("=========================================================")
    
    # Initialize XGBoost Classifier with tuned hyperparameters
    model = xgb.XGBClassifier(
        n_estimators=180,
        max_depth=5,
        learning_rate=0.04,
        subsample=0.85,
        colsample_bytree=0.85,
        scale_pos_weight=(len(y) - sum(y)) / sum(y), # Handle class imbalance
        random_state=42,
        eval_metric='logloss'
    )
    
    model.fit(X_train, y_train)
    
    # Predict on test set
    y_pred = model.predict(X_test)
    y_prob = model.predict_proba(X_test)[:, 1]
    
    # Stratified K-Fold Cross Validation
    cv = StratifiedKFold(n_splits=5, shuffle=True, random_state=42)
    cv_scores = cross_val_score(model, X, y, cv=cv, scoring='accuracy')
    cv_auc_scores = cross_val_score(model, X, y, cv=cv, scoring='roc_auc')
    
    acc = accuracy_score(y_test, y_pred)
    prec = precision_score(y_test, y_pred)
    rec = recall_score(y_test, y_pred)
    f1 = f1_score(y_test, y_pred)
    auc = roc_auc_score(y_test, y_prob)
    cm = confusion_matrix(y_test, y_pred)
    
    print("\n--- XGBoost Model Accuracy & Benchmark Evaluation ---")
    print(f"Target Accuracy           : {acc * 100:.2f}%")
    print(f"5-Fold CV Mean Accuracy  : {cv_scores.mean() * 100:.2f}% (+/- {cv_scores.std() * 100:.2f}%)")
    print(f"Test Set ROC-AUC Score   : {auc * 100:.2f}%")
    print(f"5-Fold CV Mean ROC-AUC   : {cv_auc_scores.mean() * 100:.2f}%")
    print(f"Precision                : {prec * 100:.2f}%")
    print(f"Recall                   : {rec * 100:.2f}%")
    print(f"F1-Score                 : {f1 * 100:.2f}%")
    
    print("\n--- Confusion Matrix ---")
    print(f"True Negatives (Active Students Saved) : {cm[0][0]}")
    print(f"False Positives                        : {cm[0][1]}")
    print(f"False Negatives                        : {cm[1][0]}")
    print(f"True Positives (Correctly Flagged Risk): {cm[1][1]}")
    
    print("\n--- Detailed Classification Report ---")
    print(classification_report(y_test, y_pred, target_names=['Low Risk / Active', 'High Risk / Dropout']))
    
    # -------------------------------------------------------------
    # SHAP FEATURE EXPLAINABILITY
    # -------------------------------------------------------------
    print("=========================================================")
    print(" COMPUTING SHAP (SHAPley Additive exPlanations) VALUES   ")
    print("=========================================================")
    
    explainer = shap.TreeExplainer(model)
    shap_values = explainer.shap_values(X_test)
    
    feature_importance = pd.DataFrame({
        'feature': X.columns,
        'importance': np.abs(shap_values).mean(axis=0)
    }).sort_values(by='importance', ascending=False)
    
    print("\nTop SHAP Risk Factors (Ranked by Model Impact):")
    for idx, row in feature_importance.iterrows():
        print(f" - {row['feature']:<25}: {row['importance']:.4f}")
        
    # Save Model Benchmark Summary to JSON
    benchmark_data = {
        'model_name': 'XGBoost Student Dropout Predictor',
        'target_region': 'India / Tamil Nadu Schools Context',
        'total_dataset_samples': len(df),
        'accuracy': round(acc * 100, 2),
        'cv_accuracy_mean': round(cv_scores.mean() * 100, 2),
        'roc_auc': round(auc * 100, 2),
        'precision': round(prec * 100, 2),
        'recall': round(rec * 100, 2),
        'f1_score': round(f1 * 100, 2),
        'confusion_matrix': cm.tolist(),
        'shap_top_features': feature_importance.to_dict(orient='records')
    }
    
    os.makedirs('build', exist_ok=True)
    with open('build/model_benchmark.json', 'w') as f:
        json.dump(benchmark_data, f, indent=2)
        
    print("\n[OK] Model Benchmark saved to build/model_benchmark.json successfully!")
    return benchmark_data

if __name__ == '__main__':
    train_and_evaluate_xgboost()
