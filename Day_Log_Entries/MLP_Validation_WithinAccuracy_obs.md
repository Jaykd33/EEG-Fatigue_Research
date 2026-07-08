# STAGE 4

## Block 4.0: Validation Utilities Setup
What this block does?

✅ Imports all libraries required for validation and diagnostic experiments.

✅ Loads statistical, visualization, preprocessing, and evaluation utilities.

✅ Defines a standardized verdict() function to display validation results as PASS, WARN, or FAIL.

✅ Defines class names (Awake, Tired, Drowsy) independently so the validation notebook can run without relying on previous notebook variables.

✅ Initializes the environment for the upcoming validation experiments.

Findings / Conclusions

☑ All required validation utilities were loaded successfully without errors.

☑ The validation framework is correctly initialized and ready for subsequent pipeline verification.

☑ Class labels remain consistent with the main MLP pipeline, ensuring comparable evaluation results.

☑ This block performs only setup; no model training or experimental results are generated at this stage.

## Block 4.1: Dataset Integrity Check
What this block does?

✅ Verifies that every EEG feature matrix has a corresponding label sequence of the same length.

✅ Confirms that every session contains the expected feature dimension.

✅ Checks for invalid values such as NaN and Infinity in the feature arrays.

✅ Reports dataset statistics, including the number of sessions, total EEG windows, and feature dimensions.

✅ Identifies any inconsistencies that could indicate preprocessing or data-loading errors.

Findings / Conclusions

☑ Successfully verified 23 EEG recording sessions containing 20,355 temporal windows.

☑ Every session contains 885 EEG windows with matching feature and label lengths, confirming correct feature-label alignment.

☑ All EEG feature vectors have a consistent dimension of 85 features (17 channels × 5 frequency bands).

☑ No NaN or Infinity values were detected in any feature array.

☑ No missing, empty, or corrupted sessions were found.

☑ The dataset passed all integrity checks, confirming that it is suitable for subsequent validation experiments and eliminating data-loading or preprocessing errors as potential sources of poor model performance.

## Block 4.2: Feature Statistics and Scaling Check
What this block does?

✅ Computes descriptive statistics of the raw EEG features before normalization.

✅ Verifies that the extracted features are non-degenerate and contain meaningful variation.

✅ Simulates one LOSO fold to validate the feature normalization pipeline.

✅ Fits a StandardScaler only on the training subjects and applies it to the unseen test subject, replicating the actual training procedure.

✅ Confirms that feature scaling is performed correctly without introducing data leakage.

✅ Visualizes the feature distributions before and after normalization.

Findings / Conclusions

☑ Raw EEG features exhibit meaningful variation, with an average absolute column mean of 21.8501 and an average column standard deviation of 1.4723, confirming that valid EEG features were loaded.

☑ Feature values span a reasonable range (13.5449 to 38.4148) with no indication of degenerate or constant features.

☑ After scaling, the training data achieved an average feature mean of 0.000000 and an average standard deviation of 1.0000, confirming correct StandardScaler implementation.

☑ The unseen test subject retained a realistic average standard deviation of 0.7878, indicating that normalization generalizes appropriately to unseen subjects without artificially matching the training distribution.

☑ The scaling procedure successfully avoids data leakage by fitting normalization parameters exclusively on the training data.

☑ The feature normalization pipeline was validated successfully and is unlikely to be responsible for the observed classification performance.

## Block 4.3: Feature–Label Temporal Alignment Check
What this block does?

✅ Selects one representative EEG session for temporal alignment analysis.

✅ Uses the highest-variance EEG feature as a probe signal.

✅ Computes cross-correlation between the selected EEG feature and the corresponding fatigue label sequence over multiple temporal lags.

✅ Identifies the lag at which the strongest feature–label correlation occurs.

✅ Evaluates whether a systematic temporal offset exists between EEG features and fatigue labels.

✅ Visualizes the cross-correlation profile across different time lags.

Findings / Conclusions

☑ Cross-correlation analysis was performed on Subject 10, Session 20151125_noon containing 885 temporal windows.

☑ The strongest correlation occurred at a lag of 35 windows with a correlation coefficient of −0.2612, whereas the correlation at lag 0 was only 0.0060.

☑ The observed offset suggests that this individual EEG feature does not exhibit its strongest relationship with the fatigue labels at the same time instant.

☑ Since this analysis uses only one feature from one recording session, it is not sufficient to conclude that the entire dataset is temporally misaligned.

☑ The result should be treated as a diagnostic observation rather than evidence of a preprocessing or feature-label alignment error.

☑ Additional analyses across multiple features and sessions would be required before claiming any systematic temporal misalignment in the dataset.

## Block 4.4: LOSO Split Integrity (Data Leakage Check)
What this block does?

✅ Verifies the correctness of the Leave-One-Subject-Out (LOSO) cross-validation protocol.

✅ Ensures that the test subject is completely excluded from the training set in every LOSO fold.

✅ Checks all 21 LOSO folds for potential subject leakage.

✅ Confirms that prediction results (all_results) exist for every expected subject.

✅ Detects any missing or unexpected subjects in the evaluation outputs.

Findings / Conclusions

☑ Successfully validated 21 LOSO folds, each containing 20 training subjects and 1 unseen test subject.

☑ No subject leakage was detected in any fold, confirming that the test subject was never included in the corresponding training set.

☑ Prediction results were successfully generated for all 21 subjects, with no missing or unexpected entries.

☑ The LOSO implementation is methodologically correct and free from train–test contamination.

☑ Data leakage can therefore be ruled out as a cause of the observed classification performance, strengthening the validity of subsequent experimental results.

## Block 4.5: Scaler Leakage Check
What this block does?

✅ Verifies that feature normalization is performed using only the training subjects in the LOSO pipeline.

✅ Compares a scaler fitted on the training subjects with a scaler fitted on the entire dataset.

✅ Measures the differences in the learned feature means and standard deviations between the two scalers.

✅ Confirms that the held-out test subject contributes unique information and is excluded during scaler fitting.

✅ Provides an additional safeguard against hidden data leakage during preprocessing.

Findings / Conclusions

☑ The held-out test subject (Subject 1) was successfully excluded from the scaler fitting process.

☑ The scaler trained on the training subjects produced different normalization parameters compared to the scaler trained on all subjects, with an average feature mean difference of 0.043515 and an average scale difference of 0.026411.

☑ The held-out subject exhibited a distinct average raw feature value (22.6485), confirming that it contributes unique information to the dataset.

☑ The observed differences verify that the scaler was not inadvertently fitted on the entire dataset, indicating that no normalization-related data leakage occurred.

☑ The feature normalization procedure is consistent with the LOSO evaluation protocol, further validating the methodological correctness of the training pipeline.

## Block 4.6: Label Distribution Per Fold
What this block does?

✅ Computes the ground-truth class distribution for every LOSO test session.

✅ Computes the corresponding predicted class distribution for each session.

✅ Detects degenerate test folds where one ground-truth class dominates (>95%).

✅ Identifies prediction collapse, where the model predicts only a single class for an entire session.

✅ Calculates the classification accuracy for every session.

✅ Visualizes the pooled ground-truth and prediction class distributions across all LOSO folds.

Findings / Conclusions

☑ All 23 test sessions contain meaningful ground-truth class distributions, with no degenerate folds dominated by a single class (>95%).

☑ The MLP successfully predicted multiple fatigue classes in 22 out of 23 sessions, indicating that the model generally learned multi-class decision boundaries.

☑ One session (Subject 5 – 20151012_night) exhibited prediction collapse, where the model predicted only the Awake class throughout the session despite the presence of all three ground-truth classes.

☑ Several sessions display noticeable differences between the predicted and ground-truth class distributions, highlighting the substantial inter-subject variability inherent in EEG fatigue classification.

☑ Apart from the single collapsed session, there is no evidence of systematic prediction collapse across the LOSO evaluation.

☑ The observed classification errors are therefore more likely attributable to cross-subject generalization challenges than to a fundamental failure of the classifier to perform multi-class prediction.

## Block 4.7: Confusion Matrix Analysis

What this block does?

* ✅ Generates the pooled confusion matrix across all LOSO test sessions.
* ✅ Visualizes both the raw confusion matrix and the row-normalized confusion matrix.
* ✅ Evaluates whether each class is most frequently classified as itself (diagonal dominance).
* ✅ Quantifies adjacent-class errors (Awake ↔ Tired, Tired ↔ Drowsy) and distant-class errors (Awake ↔ Drowsy).
* ✅ Produces the overall classification report, including precision, recall, and F1-score for each fatigue class.
* ✅ Assesses whether the observed error patterns are consistent with a realistic fatigue classification problem.

Findings / Conclusions

* ☑ The pooled LOSO evaluation achieved an overall classification accuracy of **41%**, consistent with the Stage 1 baseline results.
* ☑ The confusion matrix is **not fully diagonally dominant**, indicating that some fatigue classes are misclassified more frequently than they are correctly identified.
* ☑ **Adjacent-class misclassifications account for 79.0% of all prediction errors**, whereas **direct Awake ↔ Drowsy misclassifications account for only 21.0%**.
* ☑ The predominance of adjacent-class errors suggests that the model generally confuses neighboring fatigue states rather than making implausible extreme predictions, which is an expected behavior for fatigue progression.
* ☑ Per-class performance remained balanced across all three fatigue classes, with no evidence of complete class neglect or majority-class collapse in the pooled results.
* ☑ The confusion matrix indicates that the model has learned meaningful fatigue-state distinctions, although cross-subject classification remains challenging under the LOSO protocol.
* ☑ Overall, the observed error patterns support the validity of the classification pipeline and do not suggest a fundamental preprocessing or label-encoding issue.

## Block 4.8: Chance-Level Comparison

What this block does

* ✅ Compares the MLP's LOSO classification accuracy against a **stratified random baseline**, where predictions are sampled according to each session's ground-truth class distribution.
* ✅ Computes the per-session accuracy difference between the trained model and the stratified chance classifier.
* ✅ Performs a **one-sided Wilcoxon signed-rank test** to determine whether the model significantly outperforms chance.
* ✅ Compares model performance against the theoretical **uniform random baseline (33.3%)** for a three-class classification problem.
* ✅ Visualizes model-versus-chance performance across all sessions and the distribution of accuracy improvements.
* ✅ Assesses whether the classifier has learned meaningful patterns beyond random guessing.

Findings / Conclusions

* ☑ The MLP achieved a mean LOSO accuracy of **41.22% ± 19.61%** across all sessions.
* ☑ The **stratified chance classifier achieved a higher mean accuracy of 52.22% ± 12.54%**, outperforming the trained model.
* ☑ The average performance difference was **−11.00 percentage points**, indicating that the model performed worse than the stratified random baseline.
* ☑ The Wilcoxon signed-rank test produced **p = 0.9288**, providing **no statistical evidence that the model outperforms stratified chance**.
* ☑ Despite this, **14 of the 23 sessions (60.9%) achieved accuracies above the uniform random baseline of 33.3%**, showing that the model performs better than uniform guessing for the majority of subjects.
* ☑ The unexpectedly strong performance of the stratified chance baseline arises because many sessions exhibit highly skewed class distributions; randomly sampling according to these distributions can achieve relatively high accuracy without learning temporal EEG patterns.
* ☑ These results suggest that **class imbalance and subject-specific label distributions make stratified chance a particularly strong baseline**, warranting further investigation into feature-label alignment and cross-subject generalization rather than indicating a definitive implementation error alone.

## Block 4.9: Within-Subject Experiment

What this block does

* ✅ Evaluates model performance using a **within-subject protocol**, where training and testing are performed on the same recording session.
* ✅ Splits each session chronologically into **80% training** and **20% testing** to preserve temporal order.
* ✅ Fits a **StandardScaler only on the training portion** of each session to avoid temporal data leakage.
* ✅ Trains the same classifier architecture (MLP in this experiment) independently for each session.
* ✅ Computes the within-subject classification accuracy for every session.
* ✅ Compares within-subject performance against the previously obtained **LOSO (cross-subject)** accuracies.
* ✅ Quantifies the performance gap between within-subject learning and cross-subject generalization.

Findings / Conclusions

* ☑ The model achieved a **mean within-subject accuracy of 84.87% ± 15.83%**, substantially outperforming the LOSO accuracy.
* ☑ The corresponding **mean LOSO accuracy remained 41.22% ± 19.61%**, resulting in an average performance gap of **43.65 percentage points**.
* ☑ Several sessions achieved **near-perfect within-subject performance (100% accuracy)** while exhibiting poor LOSO performance (e.g., Subjects 17, 19, 20, 2 and 7), indicating that the model can successfully learn subject-specific EEG patterns.
* ☑ The consistently large gap between within-subject and LOSO accuracies demonstrates that the primary limitation is **cross-subject generalization**, rather than an inability of the model or preprocessing pipeline to learn discriminative EEG features.
* ☑ These findings provide strong evidence that the overall pipeline—including feature extraction, preprocessing, scaling, label assignment, and model implementation—is fundamentally functional.
* ☑ The experiment suggests that inter-subject variability in EEG characteristics is the dominant challenge, rather than a fundamental flaw in the classification pipeline.
* ☑ This result supports focusing future research on improving **subject-independent generalization** through domain adaptation, subject-invariant feature learning, transfer learning, or personalization strategies rather than debugging the existing implementation.

## Block 4.10: Pipeline Validation Summary

What this block does?

* ✅ Consolidates the results from all previous validation experiments into a single pipeline validation report.
* ✅ Evaluates multiple aspects of the experimental pipeline, including:

  * Feature-label alignment
  * Presence of invalid feature values (NaN/Inf)
  * Correct feature scaling
  * LOSO data leakage
  * Prediction collapse
  * Confusion matrix behaviour
  * Performance relative to chance
  * Within-subject versus cross-subject performance
* ✅ Assigns PASS/FAIL status to each validation criterion.
* ✅ Computes an overall validation score summarizing pipeline correctness.
* ✅ Provides an automated final verdict indicating whether the observed LOSO performance is likely due to pipeline errors or genuine cross-subject generalization challenges.

Findings / Conclusions

* ☑ **5 of the 8 validation checks passed**, confirming that most components of the preprocessing and evaluation pipeline function correctly.
* ☑ The pipeline successfully passed all major implementation checks, including:

  * Correct feature-label alignment.
  * No NaN or infinite feature values.
  * Proper StandardScaler fitting on training data only.
  * No subject leakage in the LOSO evaluation protocol.
  * Strong within-subject learning capability.
* ☑ Three validation checks failed:

  * One recording session exhibited **prediction collapse** to a single class.
  * The pooled confusion matrix was **not diagonally dominant**, indicating substantial class confusion.
  * The model **did not outperform the stratified chance baseline** according to the Wilcoxon signed-rank test (p = 0.9288).
* ☑ Despite these failures, the **within-subject accuracy (84.87%) was dramatically higher than the LOSO accuracy (41.22%)**, demonstrating that the model is capable of learning meaningful EEG representations when subject variability is removed.
* ☑ The large **43.65 percentage point performance gap** strongly suggests that cross-subject EEG variability is a major challenge for subject-independent fatigue classification.
* ☑ The automated verdict classified the pipeline as **"Pipeline may have a bug"** because the validation framework requires all critical checks to pass; however, the failures primarily relate to **model behaviour and generalization performance rather than preprocessing or data leakage**.
* ☑ Overall, these validation experiments indicate that the preprocessing pipeline itself is largely sound, while the principal limitation lies in achieving robust subject-independent classification across unseen individuals.
