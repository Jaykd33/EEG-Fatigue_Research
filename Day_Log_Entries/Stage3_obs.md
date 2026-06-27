# Stage 3:

What this block does?

✅ Imports the libraries required for Stage 3.

✅ Loads the outputs saved from Stages 0, 1, and 2.

✅ Retrieves the model prediction sequences (all_results) and the temporal metrics (metrics_df).

✅ Confirms that all previous stages completed successfully and that all 23 sessions are available for post-processing.

Conclusions

☑️ Outputs from Stages 0, 1, and 2 were successfully loaded.

☑️ Prediction sequences for all 23 sessions are available for survivability testing.

☑️ The experiment is correctly initialized for evaluating post-processing techniques.

☑️ No temporal consistency analysis is performed in this block; it only prepares the required data for Stage 3.

## Stage 3.1: What it does?

Installs and imports the hmmlearn library required for HMM/Viterbi smoothing.

Reloads the temporal inconsistency metric functions from Stage 2 so Stage 3 can independently evaluate post-processed predictions.

Defines helper functions (nearest_monotone_nondecreasing and compute_temporal_metrics) that will be reused after applying different smoothing methods.

Ensures Stage 3 is self-contained and does not depend on variables/functions from previous notebooks.

Output Conclusions<br>
✅ hmmlearn was successfully installed and imported.<br>
✅ Temporal evaluation functions have been recreated successfully.<br>
✅ The environment is now ready to apply and evaluate the three post-processing methods (Majority Vote, Moving Average, and HMM/Viterbi) on the prediction sequences.<br>
✅ No experimental results are produced in this block—it is purely a setup block for the survivability analysis.<br>

## Block 3.2 – Majority Vote Smoothing

What this block does?

Implements the first post-processing baseline using a sliding-window majority vote.<br>
Replaces each prediction with the most frequent class in its local neighborhood.<br>
Reduces isolated prediction fluctuations while preserving the overall sequence trend.<br>
Serves as the simplest temporal smoothing baseline.<br>

Conclusions

No experimental conclusions yet.<br>
The method has been successfully implemented and is ready for evaluation.<br>

## Block 3.3 – Moving Average Smoothing

What this block does?

Implements a moving-average filter over predicted class values.<br>
Smooths the prediction trajectory by averaging neighboring predictions.<br>
Converts the smoothed values back into discrete fatigue classes through rounding.<br>
Represents a stronger smoothing baseline than majority voting.<br>

Conclusions<br>
No experimental conclusions yet.<br>
The smoothing method is ready for comparison in later evaluation.<br>

## Block 3.4 – HMM (Viterbi) Decoding

What this block does?

Implements the strongest classical temporal smoothing baseline using a Hidden Markov Model (HMM).<br>
Models fatigue as a left-to-right progression (Awake → Tired → Drowsy).<br>
Learns transition and emission probabilities from prediction sequences.<br>
Uses the Viterbi algorithm to infer the most likely temporally consistent fatigue trajectory.<br>
Falls back to majority-vote smoothing if HMM fitting fails.<br>

Conclusions<br>
No experimental conclusions yet.<br>
The HMM baseline has been implemented and is ready for evaluation against the original predictions.<br>

## Block 3.5:

What Block 3.5 does?

This is the core experiment of Stage 3.

For every session it:

starts from the raw MLP predictions,<br>
applies Majority Vote smoothing using window sizes 3, 5 and 9,<br>
applies Moving Average smoothing using window sizes 3, 5 and 9,<br>
applies HMM Viterbi decoding,<br>
computes accuracy after each method,<br>
computes all temporal inconsistency metrics after each method,<br>
stores everything in a dataframe (pp_df) for comparison.<br>

This creates the complete set of post-processed prediction sequences that will be compared against the original model in the next block.

Conclusions from this block<br>
✅ All 23 sessions were successfully processed using all three post-processing methods.<br>
✅ Accuracy and temporal metrics were computed for every smoothing approach.<br>
✅ Results are stored in pp_df and are ready for quantitative comparison.<br>
✅ The HMM warnings are expected behavior from hmmlearn initialization and do not indicate failure.<br>

## Block 3.6: Survivability Test
What this block does?

Compares the original MLP predictions against all post-processing methods.<br>
Evaluates each method using:<br>
Accuracy<br>
Reversal Rate (RR)<br>
Temporal Deviation Score (TDS)<br>
Trajectory Correlation (TC)<br>

Measures how much each method reduces temporal inconsistency while preserving classification accuracy.<br>
Determines whether temporal inconsistency is easily removable or persists despite post-processing.<br>

Key conclusions<br>
✅ Majority Vote failed to meaningfully reduce temporal inconsistency (maximum RR reduction only 1.6%).<br>
✅ Moving Average also failed, slightly increasing the reversal rate instead of reducing it.<br>
✅ Simple temporal smoothing techniques cannot eliminate the inconsistency present in the model predictions.<br>
⚠️ HMM performed much worse than the baseline (accuracy dropped from 41.2% → 28.7% and RR increased dramatically). However, due to initialization warnings, these results are likely influenced by an implementation issue and should not be used as final scientific evidence without fixing the HMM.<br>
✅ Overall, temporal inconsistency survived naive post-processing, indicating that it is not simply random prediction noise.<br>
✅ These findings strengthen the hypothesis that temporal inconsistency is an intrinsic property of the classifier's predictions, rather than something that can be removed by straightforward smoothing.<br>

## Block 3.7 – What this block does

Plots the accuracy vs temporal consistency tradeoff for all post-processing methods.<br>
Defines temporal consistency = 1 − Reversal Rate (RR).

Compares:<br>
Raw MLP predictions<br>
Majority Vote (window sizes 3, 5, 9)<br>
Moving Average (window sizes 3, 5, 9)<br>

HMM Viterbi<br>
Generates two visualizations:<br>
Left: Accuracy vs Temporal Consistency scatter plot.<br>
Right: Reversal Rate reduction vs Accuracy cost per session.<br>
Saves the figure as stage3_tradeoff_curve.png.<br>

