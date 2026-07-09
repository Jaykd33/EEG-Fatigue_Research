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

## Block 4.2: Feature Statistics and Scaling Check

### What this block does

* ✅ Computes descriptive statistics of the raw EEG features before normalization, including feature means, standard deviations, and global value range.
* ✅ Verifies that the extracted EEG features are non-degenerate and contain meaningful numerical variation.
* ✅ Simulates one fold of the LOSO protocol to validate the feature normalization procedure.
* ✅ Fits a **StandardScaler using only the training subjects**, then applies it to the held-out test subject to prevent data leakage.
* ✅ Confirms that the training data becomes zero-mean and unit-variance after scaling.
* ✅ Compares the scaled feature distributions of the training and test subjects.
* ✅ Generates and saves feature distribution histograms for visual inspection.

### Findings / Conclusions

* ☑ The raw EEG features exhibited substantial variation, with an average absolute feature mean of **1,550,397.25**, an average feature standard deviation of **32,177,820.00**, and values ranging from **108.99** to **102,779,551,744.00**, confirming that the extracted features are non-degenerate.
* ☑ The StandardScaler successfully normalized the training data to **zero mean (0.000000)** and **unit variance (1.0000)**.
* ☑ The held-out test subject retained a comparable feature distribution after scaling, with a mean column standard deviation of **1.0236**, indicating that the normalization generalized appropriately to unseen subjects.
* ☑ Scaling was performed exclusively on the training data, confirming that the LOSO preprocessing pipeline avoids information leakage.
* ☑ The generated feature distribution plots further verified that both training and test feature distributions remain well-behaved after normalization.
* ☑ Overall, the feature extraction and normalization pipeline passed all scaling validation checks and is suitable for subject-independent evaluation.

## Block 4.3: Feature-Label Temporal Alignment

### What this block does

* ✅ Verifies whether EEG feature windows are temporally aligned with their corresponding fatigue labels.
* ✅ Selects the session containing the largest number of EEG windows to maximize statistical reliability.
* ✅ Identifies the feature with the highest variance as a representative probe signal.
* ✅ Computes the cross-correlation between the selected EEG feature and the corresponding label sequence across temporal lags of **±50 windows**.
* ✅ Determines the lag at which the absolute correlation is maximized.
* ✅ Visualizes the cross-correlation profile to inspect possible temporal shifts.
* ✅ Evaluates whether the strongest feature-label relationship occurs at **lag 0**, as expected for correctly aligned data.

### Findings / Conclusions

* ☑ The validation was performed on **Subject 10, Session 20151125_noon**, consisting of **885 EEG windows**.
* ☑ The highest absolute feature-label correlation occurred at a lag of **32 windows**, with a correlation coefficient of **−0.1878**.
* ☑ The correlation at the expected **lag 0** was only **0.0519**, substantially smaller than the peak correlation.
* ☑ The automated validation flagged this result as a **large temporal offset**, suggesting a possible mismatch between feature and label alignment.
* ☑ However, this analysis relies on a **single highest-variance EEG feature**, whereas fatigue labels are generated from the combined information of all extracted EEG features. Consequently, a shifted peak in one feature alone is **not sufficient evidence of a preprocessing error**.
* ☑ Since all previous integrity checks—including feature-label length matching, absence of NaN/Inf values, correct LOSO splitting, and proper scaling—passed successfully, this result should be interpreted as a **diagnostic observation requiring further investigation rather than definitive evidence of feature-label misalignment**.
* ☑ Additional validation using multivariate feature representations or model-based alignment analysis would be required before concluding that a systematic temporal offset exists.

## Block 4.4: LOSO Split Integrity (Leakage Check)

### What this block does

* ✅ Verifies that the **Leave-One-Subject-Out (LOSO)** evaluation protocol is correctly implemented.
* ✅ Confirms that the held-out test subject is never included in the corresponding training set for every LOSO fold.
* ✅ Checks all **21 LOSO folds** for any subject-level data leakage.
* ✅ Validates that every subject present in the dataset is represented in the evaluation results.
* ✅ Detects any missing or unexpected subjects in the final prediction outputs.
* ✅ Ensures that the reported classification performance is not artificially inflated due to improper train-test separation.

### Findings / Conclusions

* ☑ Successfully validated all **21 LOSO folds**, with each fold containing **20 training subjects** and **1 completely unseen test subject**.
* ☑ No instances of subject leakage were detected; every test subject remained fully excluded from its corresponding training set.
* ☑ The evaluation results covered **all 21 expected subjects**, with no missing or additional subject entries.
* ☑ The LOSO implementation correctly preserves strict subject independence throughout model training and evaluation.
* ☑ These results confirm that the reported BiLSTM performance is free from subject-level data leakage and represents a valid subject-independent evaluation.

## Block 4.5: Scaler Leakage Check

### What this block does

* ✅ Verifies that feature normalization is performed correctly under the LOSO evaluation protocol.
* ✅ Simulates one LOSO fold by fitting a **StandardScaler** on the training subjects only and compares it with a scaler fitted on all subjects.
* ✅ Measures the differences between the learned feature means and standard deviations of the two scalers.
* ✅ Evaluates whether excluding the test subject meaningfully changes the normalization statistics.
* ✅ Confirms that the held-out subject contributes unique information and is not inadvertently included during feature scaling.
* ✅ Provides an additional safeguard against train-test data leakage in the preprocessing pipeline.

### Findings / Conclusions

* ☑ The simulated LOSO fold used **19,470 training windows** and **885 held-out test windows**, for a total of **20,355 EEG windows**.
* ☑ The scaler fitted on the training subjects differed substantially from the scaler fitted on the entire dataset, with:

  * **Mean difference in learned feature means:** **76,302.183**
  * **Mean difference in learned feature scales:** **823,239.439**
* ☑ The held-out subject exhibited a raw average feature value of **1,075,328.625**, confirming that the test subject contributes noticeably to the global feature statistics.
* ☑ These non-zero differences demonstrate that excluding the test subject changes the normalization parameters, indicating that the training-only scaler is genuinely independent of the test data.
* ☑ The validation passed successfully, providing strong evidence that the feature normalization procedure is compatible with the LOSO protocol and does not inherently introduce data leakage.
* ☑ Together with the LOSO integrity checks, this confirms that preprocessing statistics are computed independently for each training fold, preserving a valid subject-independent evaluation pipeline.

## Block 4.6: Label Distribution Per Fold

### What this block does

* ✅ Analyzes the class distribution (Awake, Tired, Drowsy) for both ground-truth labels and model predictions in every LOSO test session.
* ✅ Computes per-session class percentages and corresponding classification accuracy.
* ✅ Detects **degenerate ground-truth sessions**, where one class dominates more than 95% of the labels.
* ✅ Detects **collapsed predictions**, where the model predicts only a single class throughout an entire session.
* ✅ Summarizes the pooled ground-truth and prediction label distributions across all sessions using visualization.
* ✅ Evaluates whether the classifier utilizes all three fatigue classes during inference.

### Findings / Conclusions

* ☑ All **23 sessions** contained valid and sufficiently diverse ground-truth labels.
* ☑ **No degenerate ground-truth sessions** (>95% of a single class) were detected, confirming that the dataset itself is well balanced for evaluation.
* ❌ The BiLSTM exhibited **prediction collapse in 5 sessions**, where only a single class was predicted:

  * Subject **15** – *20151126_night*
  * Subject **3** – *20151024_noon*
  * Subject **5** – *20141108_noon*
  * Subject **5** – *20151012_night*
  * Subject **9** – *20151017_night*
* ☑ Several additional sessions showed highly skewed prediction distributions (e.g., >95% predictions belonging to the **Tired** class), indicating a tendency toward dominant-class predictions even without complete collapse.
* ☑ Session accuracies varied substantially across subjects, ranging from approximately **0.086** to **0.821**, demonstrating considerable subject-specific variability.
* ❌ The validation check **"Model predicts more than one class in every fold" failed**, indicating that the BiLSTM occasionally converges to trivial single-class predictions on unseen subjects.
* ☑ Overall, the dataset label distribution is healthy, but the model's prediction behavior is unstable across certain LOSO folds, suggesting challenges in cross-subject generalization rather than issues with the dataset labels themselves.

## Block 4.7: Confusion Matrix Analysis

### What this block does

* ✅ Computes the **pooled confusion matrix** across all LOSO test sessions.
* ✅ Generates both **raw count** and **row-normalized** confusion matrices for detailed error analysis.
* ✅ Evaluates **diagonal dominance**, i.e., whether each class is most frequently predicted as itself.
* ✅ Quantifies the proportion of **adjacent-class errors** (Awake↔Tired, Tired↔Drowsy) versus **distant-class errors** (Awake↔Drowsy).
* ✅ Produces a complete **classification report** containing precision, recall, F1-score, and overall accuracy for each fatigue class.
* ✅ Assesses whether the model's mistakes follow the expected fatigue progression rather than occurring randomly.

### Findings / Conclusions

* ⚠ The confusion matrix was **not diagonally dominant**, indicating that at least one fatigue class was predicted incorrectly more often than correctly.
* ☑ A total of **12,340 classification errors** were observed across all LOSO predictions.
* ☑ **Adjacent-class errors dominated the mistakes**, accounting for:

  * **10,929 errors (88.6%)**
  * compared to only **1,411 distant-class errors (11.4%)**
* ☑ The adjacent-to-distant error ratio (**10,929 : 1,411**) suggests that prediction errors generally occur between neighboring fatigue states (Awake↔Tired or Tired↔Drowsy), which is consistent with the expected gradual progression of fatigue.
* ☑ Overall pooled classification performance was:

  * **Accuracy:** **39%**
  * **Macro Precision:** **0.36**
  * **Macro Recall:** **0.36**
  * **Macro F1-score:** **0.34**
* ☑ Per-class performance:

  * **Awake:** Precision **0.32**, Recall **0.14**, F1-score **0.20**
  * **Tired:** Precision **0.42**, Recall **0.64**, F1-score **0.51** *(best-performing class)*
  * **Drowsy:** Precision **0.35**, Recall **0.30**, F1-score **0.32**
* ⚠ The model demonstrates a strong tendency to recognize the **Tired** class while struggling to correctly distinguish **Awake** and **Drowsy** states.
* ☑ Although overall classification performance remains modest, the dominance of adjacent-state errors indicates that the BiLSTM captures the ordinal progression of fatigue rather than making arbitrary class predictions.

## Block 4.8: Chance-Level Comparison

### What this block does

* ✅ Compares the BiLSTM's LOSO classification accuracy against a **stratified chance baseline**, where predictions are randomly generated according to the ground-truth class distribution of each session.
* ✅ Performs a **one-sided Wilcoxon signed-rank test** to determine whether the model significantly outperforms the chance baseline.
* ✅ Compares model performance against the **uniform random chance level** (1/3 = 33.3% for three classes).
* ✅ Computes the accuracy difference between the model and chance for every test fold.
* ✅ Visualizes per-fold model accuracy versus chance accuracy and the distribution of accuracy improvements.

### Findings / Conclusions

* ⚠ The BiLSTM achieved a **mean LOSO accuracy of 39.38% ± 23.24%**.
* ⚠ The **stratified chance baseline achieved a higher mean accuracy of 52.52% ± 12.15%**, outperforming the trained model.
* ⚠ The average improvement over chance was **−13.14% ± 25.28%**, indicating that the model performed worse than the stratified baseline on average.
* ❌ The Wilcoxon signed-rank test showed **no statistically significant improvement over chance**:

  * **p = 0.9697** (one-sided test: model > chance)
* ☑ The **uniform random chance level** for three classes was **33.3%**.
* ☑ **12 out of 23 LOSO folds** achieved accuracy above the uniform chance baseline.
* ❌ The validation check **"Model significantly outperforms stratified chance" failed**, suggesting that the model does not consistently learn patterns that exceed a simple class-frequency-based predictor.
* ⚠ These results indicate that although the BiLSTM exceeds uniform random guessing in a slight majority of subjects, it **fails to outperform a stratified random baseline**, pointing toward either severe cross-subject generalization difficulties or potential issues elsewhere in the experimental pipeline that require further investigation.

## Block 4.9: Within-Subject Experiment

### What this block does

* ✅ Evaluates the BiLSTM using a **within-subject setting**, where training and testing are performed on the **same subject**.
* ✅ Splits each recording chronologically into **80% training** and **20% testing**, preserving the temporal order of EEG data.
* ✅ Fits a **StandardScaler using only the training portion** of each session to prevent data leakage.
* ✅ Trains a fresh BiLSTM model independently for every session using early stopping.
* ✅ Compares the resulting **within-subject accuracy** against the previously obtained **LOSO (cross-subject) accuracy**.
* ✅ Measures the performance gap to determine whether poor LOSO performance is caused by pipeline errors or by cross-subject variability.

### Findings / Conclusions

* ☑ The BiLSTM achieved a **mean within-subject accuracy of 83.71% ± 15.96%**, demonstrating that it can effectively learn subject-specific EEG patterns.
* ☑ The corresponding **mean LOSO accuracy was only 39.38% ± 23.24%**.
* ☑ The average performance gap between within-subject and LOSO evaluation was **44.34 percentage points**, indicating a substantial degradation when generalizing to unseen subjects.
* ☑ Multiple sessions achieved **perfect within-subject accuracy (100%)**, including Subjects **1, 17, 19, 2, 20, 3, and 7**, confirming that the model architecture and training pipeline are capable of fitting subject-specific data.
* ☑ Most remaining sessions also achieved strong within-subject performance, generally ranging between **70% and 95%**, with only a few difficult sessions falling below 60%.
* ⚠ The large discrepancy between within-subject and LOSO performance suggests that the primary limitation is **cross-subject generalization**, rather than an inability of the BiLSTM to learn meaningful EEG representations.
* ☑ These findings provide strong evidence that the training pipeline and implementation are fundamentally functional, while highlighting substantial inter-subject variability as the major challenge for subject-independent fatigue detection.

## Block 4.10: Pipeline Validation Summary

### What this block does

* ✅ Consolidates the results of all validation experiments (Blocks 4.1–4.9) into a single pipeline health assessment.
* ✅ Evaluates eight critical validation checks covering:

  * Dataset integrity
  * Feature scaling
  * LOSO data leakage
  * Prediction collapse
  * Confusion matrix quality
  * Performance against chance
  * Within-subject versus cross-subject performance
* ✅ Counts the number of validation checks passed.
* ✅ Produces an overall verdict indicating whether the observed model performance is more likely due to a valid pipeline or a potential implementation issue.

### Findings / Conclusions

* ☑ The pipeline successfully passed **5 out of 8 validation checks**.
* ☑ The following validation checks passed successfully:

  * Feature-label alignment (equal feature and label lengths)
  * No NaN or Inf values in the feature set
  * Proper zero-mean feature scaling on the training data
  * No data leakage in the LOSO evaluation protocol
  * Within-subject accuracy substantially higher than LOSO accuracy (**0.837 vs 0.394**, gap = **0.443**)
* ❌ Three important validation checks failed:

  * **Prediction collapse** was observed in multiple LOSO sessions, indicating that the model occasionally predicts only a single class.
  * The **confusion matrix lacked diagonal dominance**, suggesting poor class discrimination on unseen subjects.
  * The model **failed to outperform the stratified chance baseline** (Wilcoxon **p = 0.9697**).
* ⚠ Based on these validation results, the automated assessment concluded that the **pipeline may still contain an implementation issue** requiring further investigation.
* ⚠ However, the strong within-subject performance alongside the weak LOSO performance indicates that the BiLSTM is capable of learning meaningful subject-specific EEG representations, while struggling to generalize across unseen subjects.
* ⚠ The remaining concerns primarily relate to cross-subject prediction behavior (collapsed predictions, poor confusion matrix structure, and failure to exceed the stratified chance baseline), which should be investigated before drawing definitive conclusions regarding model performance.


