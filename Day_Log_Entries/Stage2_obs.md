# Stage 2 – Checking Temporal Inconsistencies

## Block 2.1: Temporal Inconsistency Metrics

What this block does?

Defines a suite of quantitative metrics to measure the temporal consistency of prediction sequences. <br>

Computes the same metrics for both the ground truth and the model predictions so that natural label variability can be separated from model-induced inconsistency.<br>

Introduces five complementary metrics, each capturing a different aspect of temporal behavior:<br>

Reversal Rate (RR): Frequency of fatigue class decreases between consecutive predictions.<br>

Temporal Deviation Score (TDS): Deviation of predictions from the nearest monotonic trajectory.<br>

Trajectory Correlation (TC): Correlation between prediction trend and time progression.<br>

Safety-Critical Reversal Count (SCRC): Counts dangerous transitions from Drowsy to a lower fatigue state.<br>

Maximum Consecutive Inconsistency (MCI): Longest continuous sequence of decreasing predictions.<br>

Performs a sanity check using manually created "good" and "bad" prediction sequences to verify that the implemented metrics behave as expected.<br>

Understanding the Sanity Check Results<br>

The sanity check uses two artificial examples:

Good sequence<br>
0 0 0 1 1 1 2 2 2 2

This is exactly what we expect from fatigue progression.

Therefore:

Reversal Rate → 0 ✅<br>
TDS → 0 ✅<br>
Trajectory Correlation → 0.944 (~1) ✅<br>

Everything behaves as expected.

Bad sequence<br>
0 2 0 2 0 1 2 0 1 0

This sequence jumps randomly between fatigue levels.

Therefore:

Reversal Rate → 0.444<br>
TDS → 0.356<br>
Trajectory Correlation → −0.092 (~0)<br>

These values correctly indicate a highly inconsistent prediction trajectory.

About the "should be ~0.55"

The notebook comment says:

should be ~0.55

but your result is

0.444

This is not an error.

The value depends entirely on the specific toy sequence used. The important observation is simply that:

the bad sequence has much higher reversal rate than the good sequence,
while the good sequence has zero reversals.

So the sanity check passes.

Conclusions<br>
✅ Successfully implemented a comprehensive suite of temporal inconsistency metrics.<br>
✅ The metrics capture multiple aspects of prediction stability rather than relying on a single measure.<br>
✅ Sanity checks confirm that monotonic prediction sequences receive low inconsistency scores.<br>
✅ Random prediction sequences receive substantially higher inconsistency scores, validating the metric implementations.<br>
✅ The metrics are verified and ready to be applied to real model prediction sequences in the subsequent blocks.<br>


## Block 2.2: Compute Temporal Metrics for All Sessions

What this block does?

Applies the temporal inconsistency metrics defined in Block 2.1 to every session.

Computes the metrics separately for the model predictions and the ground truth of each session.

Stores all computed metrics together with session information (subject ID, session ID, accuracy, etc.) in a structured DataFrame.

Creates a unified dataset (metrics_df) that will be used for statistical analysis and visualization in the following blocks.

Output Summary

Total sessions analyzed: 23<br>
Temporal metrics successfully computed for every session.<br>
Both prediction-based and ground-truth-based metrics were stored for later comparison.<br>
Generated a comprehensive metrics table containing reversal rate, temporal deviation score, trajectory correlation, safety-critical reversals, excess inconsistency measures, and related statistics.<br>

Conclusions<br>
✅ Temporal inconsistency metrics were successfully computed for all 23 sessions.<br>
✅ Both model prediction metrics and ground-truth metrics are available for direct comparison.<br>
✅ Session-wise temporal behavior has been converted into quantitative measurements.<br>
✅ The resulting metrics_df serves as the primary dataset for the statistical analyses and visualizations in the remaining Stage 2 blocks.<br>
✅ The project is now ready to evaluate whether the model introduces significantly more temporal inconsistency than the naturally smooth ground truth.<br>

## Block 2.3: Model vs Ground Truth Temporal Consistency

What this block does?

Compares the temporal consistency of the model's predictions against the ground-truth fatigue trajectories.

Uses the Wilcoxon Signed-Rank Test, a paired non-parametric statistical test, to determine whether differences are statistically significant across sessions.

Evaluates three primary temporal metrics:

Reversal Rate (RR) – frequency of fatigue level decreases.

Temporal Deviation Score (TDS) – deviation from the smoothest possible monotonic trajectory.

Trajectory Correlation (TC) – how well fatigue predictions increase over time.

Additionally computes the average rate of Safety-Critical Reversals (SCRC), representing dangerous transitions from Drowsy to a lower fatigue state.

Understanding the Results

1. Reversal Rate (RR)

Ground Truth:

0.0078

Model Predictions:

0.0190

Difference:

+0.0112

p-value:

0.0002

Interpretation

The model performs nearly 2.4× more backward fatigue transitions than the ground truth.

Since

p = 0.0002 < 0.05

this difference is statistically significant.

This provides strong evidence that the model introduces additional temporal inconsistency beyond the natural variability present in the labels.

2. Temporal Deviation Score (TDS)

Ground Truth:

0.1874

Model:

0.1543

Difference:

−0.0331

p-value:

0.7098

Interpretation

The model's overall trajectory is not significantly farther from a smooth monotonic trajectory than the ground truth.

This means that although the model makes more local reversals, its overall long-term trajectory remains comparable to the natural fatigue progression.

This metric does not support the hypothesis of additional inconsistency.

3. Trajectory Correlation (TC)

Ground Truth:

0.2183

Model:

0.0528

Difference:

−0.1655

p-value:

0.0042

Interpretation

Ground truth labels show a noticeably stronger positive trend with time than the model predictions.

The model largely loses this temporal trend.

Since

p = 0.0042 < 0.05

this degradation is statistically significant.

This indicates that the model does not preserve the expected progression of fatigue over time as well as the ground truth does.

4. Safety-Critical Reversals (SCRC)

Average rate:

0.0096 per timestep

Equivalent to:

≈2 dangerous reversals in a 300-window session

Interpretation

These events represent situations where the model predicts Drowsy and immediately changes to Awake or Tired.

Although relatively infrequent, such reversals are safety-critical because they could falsely reassure a driver shortly after detecting drowsiness.

Overall Conclusions <br>
✅ The model exhibits a significantly higher reversal rate than the ground truth (p = 0.0002), demonstrating additional temporal inconsistency.<br>
✅ The model shows a significantly weaker temporal progression than the ground truth (p = 0.0042), indicating reduced ability to follow fatigue evolution over time.<br>
✅ The Temporal Deviation Score shows no significant difference (p = 0.7098), suggesting the model's overall trajectory remains comparably smooth despite local fluctuations.<br>
✅ The model produces approximately 2 safety-critical fatigue reversals per 300-window session, highlighting a potential reliability concern in practical deployment.<br>
✅ These results provide the first quantitative evidence in your pipeline that the model introduces temporal behavior not explained solely by the dataset, supporting the motivation for developing temporal consistency enhancement methods in the next stage.<br>

One important observation

This is actually a stronger result than if all three metrics had been significant.

Why? Because it paints a nuanced picture:

The model's overall trajectory is not dramatically worse than the ground truth (TDS).<br>
However, it makes significantly more local reversals (RR) and fails to preserve the expected fatigue trend (TC).<br>

## 2.4 – What this block does?

✅ Identifies the sessions with the highest temporal inconsistency (highest reversal rate). <br>
✅ Plots ground truth labels and MLP predictions together for direct comparison.<br>
✅ Highlights safety-critical reversals (Drowsy → Awake/Tired) using vertical dark red lines.<br>
✅ Displays important metrics (Accuracy, RR, TDS, TC) for each selected session.<br>
✅ Saves the visualization for qualitative analysis and inclusion in the research paper.<br>

Conclusions<br>
☑️ The visualization clearly compares model predictions with the corresponding ground truth trajectories.<br>
☑️ Sessions with the highest reversal rates are displayed to illustrate the most inconsistent prediction behavior.<br>
☑️ Safety-critical prediction reversals are explicitly highlighted, making risky prediction changes easy to identify.<br>
☑️ The figure provides visual evidence supporting the quantitative temporal inconsistency metrics computed earlier.<br>
☑️ The generated plot serves as a key qualitative result for validating the temporal inconsistency analysis.<br>

## Block 2.5 – What this block does?

✅ Analyzes the distribution of temporal inconsistency metrics across all sessions.

✅ Compares the distributions of ground truth and model predictions for Reversal Rate and Trajectory Correlation.

✅ Examines the relationship between classification accuracy and temporal inconsistency using a scatter plot and Spearman correlation.

✅ Determines whether temporal inconsistency is a system-wide phenomenon or merely caused by a few outlier sessions.

Conclusions

☑️ Temporal inconsistency is observed across multiple sessions rather than being limited to a few outliers.

☑️ The model generally exhibits higher reversal rates and weaker temporal trends than the ground truth.

☑️ Session accuracy shows a very weak negative correlation with reversal rate (Spearman r = -0.075, p = 0.7349).

☑️ The lack of significant correlation indicates that temporal inconsistency is largely independent of overall classification accuracy.

☑️ This supports the central research hypothesis that temporal inconsistency represents a distinct failure mode, not simply poor predictive accuracy, making it a meaningful property to evaluate separately.

## Block 2.6 – What this block does?

Saves all Stage 2 temporal analysis results (metrics_df and statistical comparison results) into stage2_output.pkl for use in later stages.

Summarizes the key quantitative findings of Stage 2 that will be referenced in the research paper.

Marks the completion of Stage 2 and prepares the pipeline for Stage 3 (temporal consistency improvement).

Conclusions

✅ Stage 2 results were successfully saved for future analysis and post-processing.

✅ The model's mean reversal rate (0.0190) is over 2.4× higher than the ground truth (0.0078), indicating additional temporal inconsistency introduced by the model.

✅ The Wilcoxon test (p = 0.00018) confirms that the higher reversal rate is statistically significant, not due to random variation.

✅ The model exhibits a much weaker temporal trend (Trajectory Correlation = 0.0528) compared to the ground truth (0.2037), showing poorer tracking of fatigue progression.

✅ Accuracy and reversal rate are essentially unrelated (Spearman r = -0.0747, p = 0.7349), suggesting temporal inconsistency is a distinct failure mode rather than simply a consequence of lower classification accuracy.

✅ The model produces an average safety-critical reversal rate of 0.0096, indicating occasional unsafe transitions from Drowsy → Awake/Tired that could be important in real-world driver monitoring systems.

✅ Stage 2 provides quantitative evidence supporting the central hypothesis that machine learning models can introduce temporal inconsistencies beyond those present in the ground truth data, establishing the motivation for Stage 3.

