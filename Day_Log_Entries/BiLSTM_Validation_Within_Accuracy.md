# STAGE 4 : VALIDATION  
## Block 4.0: Validation Framework Initialization

### What this block does?

* ✅ Imports all libraries required for the validation experiments, including statistical testing, visualization, preprocessing, and evaluation metrics.
* ✅ Defines a reusable `verdict()` utility to standardize PASS/WARN/FAIL messages throughout the validation stage.
* ✅ Re-defines the fatigue class labels (`Awake`, `Tired`, `Drowsy`) to make the validation notebook self-contained and independent of previous notebooks.
* ✅ Initializes constants required for subsequent validation experiments.
* ✅ Prepares the notebook environment for systematic pipeline verification.

### Findings / Conclusions

* ☑ All required validation libraries were successfully imported.
* ☑ The validation utilities and reporting framework were initialized without errors.
* ☑ Fatigue class definitions were successfully configured for the validation stage.
* ☑ The notebook is correctly prepared to perform pipeline verification and diagnostic experiments in the following blocks.

## Block 4.1: Dataset Integrity Check

### What this block does

* ✅ Verifies that every EEG feature sequence has a corresponding label sequence of identical length.
* ✅ Checks every session for invalid numerical values, including **NaN** and **Infinity**.
* ✅ Confirms that all sessions contain the expected number of EEG windows.
* ✅ Verifies that every feature vector has the same dimensionality across the entire dataset.
* ✅ Summarizes the total number of sessions, total EEG windows, and feature dimensions before model validation.
* ✅ Performs basic data integrity checks to ensure the dataset is suitable for subsequent experiments.

### Findings / Conclusions

* ☑ Successfully validated **23 recording sessions** containing **20,355 EEG windows** in total.
* ☑ Every session contained **885 EEG windows**, with perfect alignment between feature matrices and label vectors.
* ☑ All EEG feature vectors consistently contained **85 extracted features** across every session.
* ☑ No **NaN** or **Infinity** values were detected in any feature array.
* ☑ No feature-label mismatches or empty sessions were found.
* ☑ The dataset passed all integrity checks, confirming that the preprocessing pipeline produced a clean and internally consistent dataset suitable for model validation.

