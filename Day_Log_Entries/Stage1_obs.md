# Stage 1

## Block 1.1: 
Load Stage 0 Output

What this block does?

Loads the processed dataset generated in Stage 0.<br>
Retrieves EEG features, PERCLOS labels, and metadata for all sessions.<br>
Verifies that every EEG feature vector has a corresponding fatigue label.<br>
Ensures the data is ready for baseline model training.<br>


Conclusions<br>
✅ Successfully loaded 23 recording sessions from Stage 0.<br>
✅ Each EEG sample contains 85 features (17 channels × 5 frequency bands).<br>
✅ Labels are continuous PERCLOS values (discrete labels are also available for classification).<br>
✅ Data integrity check passed, confirming no mismatch between features and labels.<br>
✅ The dataset is correctly prepared for LOSO baseline model training.<br>
<br>

## Block 1.2: Feature Normalization Strategy

What this block does?

Groups all recording sessions according to their subject IDs.<br>
Prepares the dataset for Leave-One-Subject-Out (LOSO) evaluation.<br>
Identifies how many sessions belong to each subject.<br>
Ensures feature normalization will later use only the training subjects, preventing data leakage.<br>

Conclusions<br>
✅ Identified 21 unique subjects for LOSO evaluation.<br>
✅ Total dataset contains 23 sessions, as Subjects 4 and 5 each have two sessions.<br>
✅ Every session contains 885 EEG time steps.<br>
✅ Subjects with two sessions contribute 1770 time steps, while the remaining subjects contribute 885 time steps each.<br>
✅ Dataset is correctly organized for subject-wise LOSO cross-validation without information leakage.<br>

Research Note (worth adding to your notebook)

This is actually a good sign. Since Subjects 4 and 5 have multiple sessions, your future temporal consistency analysis can also examine whether a model behaves consistently across different sessions of the same subject, which could become an interesting secondary observation in your paper. It's not your main contribution, but it's a useful point to keep in mind.

## Block 1.3: LOSO Baseline Training

What this block does?

Performs Leave-One-Subject-Out (LOSO) cross-validation.

In each fold, one subject is kept completely unseen as the test subject while all remaining subjects are used for training.<br>
Fits a StandardScaler only on the training data to prevent data leakage.<br>
Trains an MLP classifier using the normalized DE-LDS EEG features.<br>
Predicts fatigue labels for every time window of the left-out subject.<br>
Stores the complete prediction sequence, prediction probabilities, and session accuracy for later temporal analysis in Stage 2.<br>
Calculates the overall LOSO classification accuracy across all sessions.<br>

Output Summary<br>
Total LOSO folds: 21<br>
Test sessions evaluated: 23<br>
Mean LOSO Accuracy: 41.2% ± 19.6%<br>
Minimum session accuracy: 10.3%<br>
Maximum session accuracy: 85.3%<br>

Conclusions

☑ Successfully trained an MLP baseline under the LOSO evaluation protocol.

☑ Generated complete per-session prediction sequences required for Stage 2.

☑ No data leakage occurred because normalization was performed using only training data.

☑ Large variation in session accuracies indicates strong inter-subject variability in EEG signals.

☑ Although the overall accuracy is modest, the baseline successfully learned all fatigue classes rather than collapsing into a single class.

## Block 1.4 : Classification Performance Evaluation

(Assuming this is the block where you generated the classification report and confusion matrix.)

What this block does?
Evaluates the predictions produced by the trained MLP.<br>
Computes overall classification metrics including precision, recall and F1-score.<br>
Generates the confusion matrix to analyze class-wise prediction behavior.<br>
Checks whether the classifier predicts all fatigue classes or is biased toward a single class.<br>

Output Summary

Overall Accuracy:

41.2%

Class	Precision	Recall	F1<br>
Awake	0.390	0.365	0.377<br>
Tired	0.468	0.452	0.460<br>
Drowsy	0.345	0.411	0.375<br>

Conclusions

☑ The classifier predicts all three fatigue classes.

☑ No evidence of mode collapse toward a single class.

☑ Recall values are relatively balanced across all classes.

☑ Drowsy samples remain reasonably detectable despite being the smallest class.

☑ The baseline provides meaningful prediction sequences suitable for temporal inconsistency analysis.

## Important Discussion Regarding the Lower Accuracy (Keep this in your notes)

This section is probably the most important documentation of Stage 1 because reviewers, supervisors, or interviewers may ask exactly this question:

"If your MLP only achieved 41%, how do you know the temporal inconsistencies aren't simply because your model is poor?"

Below are the key facts supporting your methodology.

1. The entire pipeline was verified

The following potential implementation errors were systematically ruled out.

☑ EEG features and labels were correctly paired from separate .mat files.

☑ EEG tensors were correctly reshaped from

(17, 885, 5)

to

(885, 85)

☑ Labels were correctly aligned with feature windows.

☑ LOSO splitting was implemented correctly.

☑ StandardScaler was fitted only on training data.

☑ No train-test leakage exists.

2. Ground truth labels are extremely smooth

Stage 0 showed:

Average decrease rate = 0.008
Local consistency = 0.999
Monotone deviation = 0.251

Therefore,

The dataset itself contains almost no temporal inconsistency.

Any inconsistency observed later primarily originates from the model rather than noisy ground truth.

This strengthens the motivation of the project.

3. The class distribution is acceptable

Using the literature-based thresholds (0.35, 0.70):

Awake = 36.4%
Tired = 43.7%
Drowsy = 19.9%

The smallest class still contains approximately 4,000 samples, which is sufficient for training a baseline classifier.

Thus,

Poor accuracy cannot be attributed to severe class imbalance.

4. The model did not collapse

A common failure mode in EEG classification is predicting only the majority class.

Your classification report shows:

Class	Recall
Awake	0.365
Tired	0.452
Drowsy	0.411

These values indicate that the classifier learned to predict all three fatigue states.

Therefore,

The model exhibits genuine multi-class learning rather than trivial majority-class prediction.

5. Threshold investigation

Different discretization thresholds were evaluated.

Threshold	Awake	Tired	Drowsy
0.35 / 0.70	36.4%	43.7%	19.9%
0.30 / 0.60	28.3%	46.7%	25.0%
0.25 / 0.50	22.5%	42.8%	34.7%

The adopted 0.35 / 0.70 thresholds were retained because:

They produce a reasonable class distribution.
They are commonly associated with SEED-VIG literature.
They provide better comparability with previous work.
6. Why is 41.2% still acceptable?

The objective of this research is not to propose a better classifier.

The objective is to study temporal consistency of model predictions.

For this purpose, the baseline only needs to satisfy three conditions:

✅ It is methodologically correct.

✅ It predicts all fatigue classes.

✅ It produces complete prediction trajectories.

Your baseline satisfies all three.

7. Response if questioned in the future

The MLP baseline was intentionally chosen as a simple, reproducible classifier rather than a state-of-the-art architecture. The entire preprocessing and LOSO evaluation pipeline was verified to be methodologically correct, with no evidence of data leakage or implementation errors. Although the overall classification accuracy was 41.2%, the model successfully learned all three fatigue classes with balanced recall and generated meaningful per-window prediction sequences. Since the objective of this work is to evaluate temporal consistency rather than maximize classification accuracy, this baseline is sufficient for investigating temporal behavior. Future work can validate whether the same temporal inconsistency patterns persist across stronger architectures such as AMD-GCN.

## Block 1.5
✅ Stage 1 outputs were successfully saved to stage1_output.pkl for use in Stage 2.<br>
✅ Prediction sequences for all 23 sessions were preserved, enabling temporal inconsistency analysis.<br>
✅ Overall LOSO baseline accuracy is 41.2%.<br>
✅ Per-class recall values are available for Awake, Tired, and Drowsy and will serve as baseline performance metrics.<br>
✅ Sessions with accuracy below 35% have been identified for later inspection to determine whether poor performance correlates with higher temporal inconsistency.<br>
✅ Stage 1 is complete, and the project is ready to proceed to Stage 2 (Temporal Prediction Analysis).<br>

