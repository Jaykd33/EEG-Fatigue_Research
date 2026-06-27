Stage 0 — Dataset Audit & Validation

What was done?
1. Loaded all 23 SEED-VIG EEG sessions and their corresponding PERCLOS label files.
2. Converted the EEG data into a machine-learning friendly format:
   * 17 EEG channels
   * 5 frequency bands
   * Combined into 85 features per time window
3. Converted continuous PERCLOS values into 3 fatigue classes:
   * Awake (< 0.35)
   * Tired (0.35–0.70)
   * Drowsy (> 0.70)
4. Verified that every EEG sample had a matching fatigue label.
5. Measured how smooth the ground-truth fatigue trajectories are before training any model.
6. Saved all processed sessions for later stages.

Important Numbers:
* Sessions: 23
* Subjects: 21
* Total timesteps: 20,355
* Features per timestep: 85

Class distribution:
* Awake: 36.4%
* Tired: 43.7%
* Drowsy: 19.9%

Ground-truth decrease rate:
* 0.0078 (0.78%)
Ground-truth monotone deviation:
* 0.3420

Conclusions:
1. Dataset loading was successful with no missing files.
2. The class distribution is reasonably balanced and suitable for training.
3. Fatigue labels are naturally smooth over time.
4. Backward fatigue transitions are extremely rare (only 0.78%).
5. The dataset itself is not noisy enough to create fake temporal inconsistency.
6. If a model later behaves inconsistently, it is likely the model's fault rather than the dataset's fault.

Stage 1 — GRU Model Training (LOSO)
What was done?
1. Used Leave-One-Subject-Out (LOSO) evaluation.
2. For every fold:
   * One subject was completely removed.
   * Model trained on all remaining subjects.
   * Tested only on the unseen subject.
3. Features were normalized using only training subjects.
4. Trained a GRU network to predict fatigue class at every timestep.
5. Saved:
   * Predictions
   * Probabilities
   * Accuracy
   * Temporal prediction sequences
6. Repeated for all 21 subjects.

Important Numbers:
Overall LOSO Accuracy:
42.42%

Session Accuracy Range:
* Best: 87.57%
* Worst: 4.29%
  
Per-Class Recall:
* Awake: 47.3%
* Tired: 30.5%
* Drowsy: 59.7%

Conclusions:
1. GRU successfully learned fatigue-related patterns.
2. Performance varied heavily across subjects.
3. Drowsy class was detected best (59.7% recall).
4. Tired class was the hardest class to predict.
5. No class collapse occurred (all classes were predicted).
6. The main purpose of this stage was not accuracy but generating temporal prediction sequences for later analysis.

Stage 2 — Temporal Inconsistency Analysis
What was done?
1. Compared GRU prediction trajectories against ground-truth trajectories.
2. Measured temporal behaviour using:
   * Reversal Rate (RR)
   * Temporal Deviation Score (TDS)
   * Trajectory Correlation (TC)
   * Safety-Critical Reversals
3. Performed statistical tests (Wilcoxon Signed Rank Test).
4. Checked whether temporal inconsistency is different from normal classification error.
5. Examined whether more accurate sessions are automatically more temporally stable.
6. Saved all temporal metrics for every session.

Important Numbers:

Reversal Rate (RR)
Ground Truth: 0.0078
GRU: 0.0091
p-value: 0.1687
(Not Significant)

Temporal Deviation Score (TDS)
Ground Truth: 0.1874
GRU: 0.1412
p-value: 0.9288
(Not Significant)

Trajectory Correlation (TC)
Ground Truth: 0.2338
GRU: 0.1177
p-value: 0.1078
(Not Significant)

Safety-Critical Reversal Rate: 0.0051

Accuracy vs Reversal Rate:
Spearman Correlation:
r = 0.2324
p = 0.2860

Conclusions

1. GRU predictions were only slightly more inconsistent than ground truth.
2. The increase in inconsistency was not statistically significant.
3. GRU prediction trajectories were actually smoother than the true fatigue trajectories according to TDS.
4. GRU captured fatigue progression trends, but weaker than the actual labels.
5. Very few safety-critical reversals occurred.
6. Accuracy and temporal consistency appear to be mostly independent.
7. There is no strong evidence that GRU introduces serious temporal instability.

Stage 3 — Survivability Analysis
What was done?
1. Applied common post-processing methods to GRU predictions.
2. Tested:
   * Majority Vote
   * Moving Average
   * HMM Viterbi
3. Measured:
   * Accuracy
   * Reversal Rate
   * TDS
   * TC
4. Checked whether temporal inconsistency disappears after smoothing.
5. Evaluated whether improvements come at the cost of accuracy.
6. Determined whether the temporal inconsistency problem survives simple fixes.

Important Numbers
Raw GRU
Accuracy: 42.4%
Reversal Rate: 0.0091
Best Majority Vote Result
(Window = 9)

Accuracy: 42.3%
Reversal Rate: 0.0063
Reduction: 30.3%

Best Moving Average Result
(Window = 9)
Accuracy: 42.7%
Reversal Rate: 0.0074
Reduction: 18.4%

HMM Result
Accuracy: 30.2%
Reversal Rate: 0.3510

Conclusions

1. Simple smoothing can reduce temporal inconsistency.
2. Majority Voting was the most effective method.
3. Best reduction achieved was about 30%
4. Smoothing did not noticeably change classification accuracy.
5. Temporal inconsistency was reduced but not completely removed.
6. HMM performed extremely poorly and made predictions much worse.
7. For GRU predictions, simple smoothing methods are preferable to HMM.


Summary of the Entire GRU Study:
The GRU achieved 42.4% LOSO accuracy, produced prediction trajectories that were not significantly more inconsistent than the ground truth fatigue trajectories, 
and simple smoothing methods reduced inconsistency by about 30%, with Majority Vote being the most effective post-processing approach.
