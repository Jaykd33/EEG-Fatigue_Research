# Stage 0

## Block 0.1 – Environment Setup & Reproducibility
☑ Imported all required libraries for data processing, deep learning, evaluation, and visualization.

☑ Fixed random seeds to ensure reproducible experimental results.

☑ Configured deterministic PyTorch execution for consistent model training.

☑ Verified GPU availability and PyTorch installation (cuda, PyTorch 2.10.0).

## Block 0.2 – Dataset & Experiment Configuration
☑ Defined the dataset root directory and output folder for experiment artifacts.

☑ Created the output directory automatically if it did not exist.

☑ Set PERCLOS thresholds for three-class fatigue labeling (Awake, Tired, Drowsy).

☑ Established a consistent class mapping (N_CLASSES = 3) matching the MLP baseline for fair comparison.

## Block 0.3 – Data Loading & Preprocessing
What this block does?

☑ Loads EEG feature files and corresponding PERCLOS label files from separate directories.

☑ Converts raw EEG features from (17, T, 5) to (T, 85), matching the MLP preprocessing pipeline.

☑ Aligns feature and label sequences to a common length for each session.

☑ Organizes the data into subject-wise and session-wise dictionaries for LOSO evaluation.

Conclusions

☑ Successfully loaded all 23 EEG feature files and 23 PERCLOS label files without errors.

☑ Data from 21 unique subjects (23 recording sessions) was successfully prepared.

☑ EEG feature preprocessing was verified to produce the same input representation (T, 85) used in the MLP baseline, ensuring fair architectural comparison.

☑ The dataset is correctly structured and ready for fatigue label generation and subsequent preprocessing stages.

## Block 0.4 – PERCLOS Label Generation
What this block does?

☑ Converts continuous PERCLOS values into three fatigue classes using predefined thresholds.

☑ Assigns labels as Awake (0), Tired (1), and Drowsy (2).

☑ Applies the same thresholding strategy as the MLP baseline to ensure experimental consistency.

☑ Computes and verifies the overall class distribution across all sessions.

Conclusions

☑ Successfully converted continuous PERCLOS values into three-class fatigue labels for all sessions.

☑ Obtained a class distribution of 36.4% Awake, 43.7% Tired, and 19.9% Drowsy.

☑ The class distribution exactly matches the MLP baseline, confirming that data loading and preprocessing are consistent across both models.

☑ The labeled dataset is correctly prepared for LOSO training and evaluation.

## Block 0.5 conclusions
What this block does?

☑ Summarizes the number of windows and feature dimensions for each subject-session.

☑ Computes the per-session class distribution for Awake, Tired, and Drowsy states.

☑ Verifies dataset consistency before model training.

☑ Confirms successful completion of Stage 0 data preparation.

Conclusions

☑ Successfully prepared data for 23 recording sessions from 21 unique subjects.

☑ Verified that each session contains 885 time windows with 85 EEG features.

☑ Confirmed that fatigue class distributions vary across sessions, reflecting natural subject variability.

☑ Stage 0 preprocessing is complete, and the dataset is ready for LOSO-based BiLSTM training.

# Stage 1 — BiLSTM Model, Training, and LOSO Evaluation

## Block 1.1 – BiLSTM Hyperparameter Configuration
What this block does?

☑ Defines the BiLSTM architecture, including hidden size, number of layers, dropout, and fully connected layer size.

☑ Configures the training hyperparameters, including learning rate, batch size, maximum epochs, and early stopping settings.

☑ Sets learning rate scheduler parameters for adaptive optimization.

☑ Displays the complete training configuration for reproducibility.

Conclusions

☑ Successfully configured the BiLSTM model architecture and training parameters.

☑ Enabled regularization using dropout and early stopping to reduce overfitting.

☑ Configured adaptive learning rate reduction for stable model convergence.

☑ The training configuration is finalized and ready for LOSO-based BiLSTM model development.

## Block 1.2 – BiLSTM Model Architecture
What this block does?

☑ Defines a two-layer bidirectional LSTM architecture for sequence-based EEG fatigue classification.


☑ Applies a fully connected classifier head to generate class predictions at every time window.

☑ Performs a forward-pass sanity check using dummy input data to verify input and output dimensions.

☑ Computes the total number of trainable model parameters.

Conclusions

☑ Successfully initialized the BiLSTM model with an input feature dimension of 85.

☑ Verified that the model correctly maps input sequences of shape (batch, seq_len, 85) to output predictions of shape (batch, seq_len, 3).

☑ Confirmed the architecture is functioning correctly through a successful forward-pass test.

☑ The BiLSTM model contains 185,091 trainable parameters and is ready for LOSO training.

## Block 1.3 – Dataset & DataLoader Preparation
What this block does?


☑ Defines a custom dataset to load complete EEG sessions as temporal sequences.

☑ Applies feature standardization using a StandardScaler fitted only on the training data.

☑ Preserves subject and session identifiers for LOSO evaluation and result tracking.

☑ Implements a custom collate function to pad variable-length sequences for efficient batch processing.

Conclusions

☑ Successfully defined the dataset pipeline for sequence-based BiLSTM training.

☑ Ensured data normalization is performed without introducing train-test data leakage.

☑ Enabled batching of variable-length EEG sequences through sequence padding.

☑ The data pipeline is ready for LOSO training and inference.

## Block 1.4 – Training & Evaluation Utilities
What this block does?


☑ Defines the training routine for one epoch, including forward pass, backpropagation, and parameter updates.

☑ Computes cross-entropy loss while ignoring padded sequence elements.

☑ Applies gradient clipping to improve training stability.

☑ Defines the evaluation routine to compute validation loss, accuracy, and collect predictions for further analysis.

Conclusions

☑ Successfully implemented the training and evaluation pipeline for the BiLSTM model.

☑ Ensured padded sequence elements are excluded from loss and accuracy calculations.

☑ Incorporated gradient clipping to stabilize optimization during sequence learning.

☑ The model training pipeline is ready for LOSO-based training and performance evaluation.

## Block 1.5 – LOSO Training & Evaluation Pipeline
What this block does?

☑ Implements the complete Leave-One-Subject-Out (LOSO) training and evaluation workflow.

☑ Splits subjects into training, validation, and test sets for each LOSO fold.

☑ Fits feature normalization using only the training subjects to prevent data leakage.

☑ Trains the BiLSTM using early stopping and adaptive learning rate scheduling.

☑ Restores the best-performing model and performs chronological prediction on the held-out subject.

☑ Stores subject-wise prediction sequences and evaluation results for subsequent temporal consistency analysis.

Conclusions

☑ Successfully defined a complete LOSO evaluation pipeline for the BiLSTM model.

☑ Ensured strict subject-wise separation throughout training, validation, and testing.

☑ Preserved temporal ordering of EEG sequences during training and inference.

☑ Generated prediction outputs in the same format as the MLP baseline, enabling direct comparison in later evaluation stages.

## Block 1.6 – LOSO Training Execution
What this block does?

☑ Executes the complete LOSO evaluation using the configured BiLSTM model.

☑ Trains and evaluates the model independently for each held-out subject.

☑ Applies early stopping based on validation accuracy for each fold.

☑ Stores chronological prediction sequences and evaluation results for all sessions.

Conclusions

☑ Successfully completed LOSO evaluation across 21 subjects and 23 recording sessions.

☑ Early stopping converged between 8 and 44 epochs, indicating fold-specific training behavior.

☑ Test accuracy varied considerably across subjects, reflecting expected cross-subject variability in EEG fatigue classification.

☑ Prediction sequences for all sessions have been generated and are ready for Stage 2 temporal consistency analysis.

## Block 1.7 – Overall BiLSTM Performance Evaluation
What this block does?

☑ Aggregates predictions from all LOSO folds to compute overall classification performance.

☑ Calculates pooled accuracy and mean subject-wise accuracy.

☑ Generates precision, recall, and F1-score for each fatigue class.

☑ Visualizes the pooled confusion matrix and saves it for later analysis.

Conclusions

☑ Achieved a pooled LOSO classification accuracy of 39.38% across all evaluation sessions.

☑ Obtained a mean subject-wise accuracy of 39.38% ± 23.24%, indicating substantial inter-subject performance variability.

☑ The model achieved the highest recall for the Tired class, while Awake and Drowsy were more difficult to distinguish.

☑ All prediction sequences have been successfully generated and are ready for temporal consistency evaluation.

# Stage 2

## Block 2.1 – Temporal Metric Definition
What this block does?

☑ Defines the temporal inconsistency metrics used to evaluate prediction sequences.

☑ Computes Reversal Rate (RR), Temporal Deviation Score (TDS), Trajectory Correlation (TC), and Safety-Critical Reversal Count (SCRC).

☑ Computes corresponding ground-truth metrics for comparison.

☑ Validates the implementation using synthetic monotonic and non-monotonic sequences.

Conclusions

☑ Successfully implemented the temporal consistency evaluation framework.

☑ Sanity checks confirmed that monotonic sequences produce minimal temporal inconsistency, while fluctuating sequences produce higher inconsistency.

☑ The metric implementation behaves as expected and is ready for evaluation on BiLSTM prediction sequences.

☑ The same evaluation framework is retained from the MLP baseline, ensuring fair comparison across architectures.

## Block 2.3 – Model vs Ground Truth Temporal Consistency Comparison
What this block does?

☑ Compares the temporal consistency of BiLSTM prediction sequences against the corresponding ground-truth label sequences.

☑ Evaluates Reversal Rate (RR), Temporal Deviation Score (TDS), and Trajectory Correlation (TC) for both predictions and ground truth.

☑ Performs paired Wilcoxon signed-rank tests to determine whether the model introduces significantly greater temporal inconsistency than the labels.

☑ Computes the average Safety-Critical Reversal Count (SCRC) to quantify potentially unsafe prediction transitions.

Conclusions

☑ The BiLSTM prediction sequences exhibited no statistically significant increase in temporal inconsistency compared with the ground-truth labels across all evaluated 
metrics.

☑ The average Reversal Rate (0.0065) was slightly lower than that of the ground truth (0.0078), with no significant difference (p = 0.8821).

☑ The BiLSTM achieved a lower Temporal Deviation Score than the ground truth, indicating smoother prediction trajectories.

☑ Trajectory Correlation was slightly lower than the ground truth but the difference was not statistically significant.

☑ The average Safety-Critical Reversal Rate was 0.0038 per timestep, corresponding to approximately one safety-critical prediction reversal per 300-window session.

☑ Unlike the MLP baseline, the BiLSTM did not introduce additional temporal inconsistency beyond the inherent variability of the dataset, suggesting that temporal 
behavior is influenced by the underlying model architecture rather than being a universal property of EEG fatigue classifiers.

## Block 2.4 – Temporal Prediction Visualization
What this block does?

☑ Selects the sessions with the highest prediction reversal rates.

☑ Visualizes ground-truth and BiLSTM prediction trajectories over time.

☑ Highlights safety-critical prediction reversals (Drowsy → Awake/Tired).

☑ Displays session-level temporal metrics (Accuracy, RR, TDS, and TC) alongside each trajectory.

☑ Compares prediction and ground-truth reversal rates using bar charts for each selected session.

Conclusions

☑ Successfully generated visual comparisons between ground-truth and BiLSTM prediction sequences.

☑ Identified the sessions exhibiting the highest temporal inconsistency for detailed qualitative analysis.

☑ Enabled direct visual inspection of prediction stability and safety-critical transitions.

☑ The generated figures provide qualitative evidence to complement the quantitative temporal consistency metrics.

## Block 2.5 – Distribution Analysis
What this block does?

☑ Visualizes the distribution of temporal consistency metrics across all sessions.

☑ Compares the distributions of prediction and ground-truth reversal rates.

☑ Compares the distributions of prediction and ground-truth trajectory correlations.

☑ Examines the relationship between classification accuracy and temporal inconsistency using Spearman correlation analysis.

☑ Generates distribution plots to support qualitative interpretation of the temporal metrics.

Conclusions

☑ Successfully visualized the distribution of temporal consistency metrics across all evaluation sessions.

☑ The prediction and ground-truth reversal rate distributions showed substantial overlap, consistent with the statistical findings from Block 2.3.

☑ No significant correlation was observed between session accuracy and prediction reversal rate (Spearman r = -0.026, p = 0.9050).

☑ These results indicate that classification accuracy and temporal consistency behave as largely independent characteristics of the BiLSTM model.

☑ The distribution analysis supports the observation that the BiLSTM maintains temporal behavior comparable to the ground truth rather than introducing additional temporal inconsistency.

### For the BiLSTM, prediction accuracy and temporal consistency appear largely independent, although the model itself does not exhibit statistically significant excess temporal inconsistency relative to the ground truth.

## Block 2.6 – Save Stage 2 Results
What this block does?

☑ Saves all computed temporal consistency metrics and statistical comparison results for later use.

☑ Summarizes the key Stage 2 temporal consistency metrics for the BiLSTM model.

☑ Reports the statistical comparison between prediction and ground-truth temporal behavior.

☑ Provides the primary metrics that will be compared across different classifier architectures.

Conclusions

☑ The BiLSTM achieved a mean prediction reversal rate of 0.0065, slightly lower than the ground-truth reversal rate (0.0078).

☑ The Wilcoxon signed-rank test (p = 0.8821) found no significant difference between prediction and ground-truth reversal rates.

☑ The mean trajectory correlation of the BiLSTM (0.0881) was lower than the ground truth (0.2037), although this difference was not statistically significant.

☑ No meaningful relationship was observed between classification accuracy and reversal rate (Spearman r = -0.0264, p = 0.9050).

☑ The average safety-critical reversal rate was 0.0038 per timestep, indicating relatively few unsafe prediction transitions.

☑ Overall, the BiLSTM did not introduce statistically significant temporal inconsistency beyond the inherent variability of the ground-truth labels.

# STAGE 3: SURVIVABILITY TEST

## Block 3.0: Loading Previous Outputs
What this block does?

☑ Imports the libraries required for Stage 3 temporal post-processing and analysis.

☑ Loads the BiLSTM Stage 2 outputs containing prediction sequences and temporal consistency metrics.

☑ Retrieves the prediction results and session-wise temporal metrics for further evaluation.

☑ Verifies that all sessions are available for post-processing analysis.

Conclusions

☑ Successfully loaded the BiLSTM Stage 2 outputs for survivability testing.

☑ Retrieved prediction sequences and temporal consistency metrics for all 23 recording sessions.

☑ Confirmed that the required data is available for evaluating temporal post-processing methods.

☑ The dataset is ready for Stage 3 analysis to determine whether simple post-processing techniques can meaningfully alter the temporal behavior of BiLSTM predictions.

## Block 3.1 – Install Dependencies & Define Temporal Metrics
What this block does?

☑ Installs and imports the hmmlearn library required for HMM-based post-processing.

☑ Re-defines the temporal consistency metric functions from Stage 2 to make the Stage 3 notebook self-contained.

☑ Implements the isotonic regression routine used for computing the Temporal Deviation Score (TDS).

☑ Ensures that all post-processed prediction sequences will be evaluated using the same temporal consistency metrics as the original predictions.


Conclusions

☑ Successfully installed and imported the required dependencies for Stage 3.

☑ Re-established the temporal consistency evaluation functions without modifying their definitions.

☑ Guaranteed that all post-processing methods will be evaluated using an identical metric framework, ensuring fair comparison with the original BiLSTM predictions.

☑ Stage 3 is fully prepared for evaluating whether naive post-processing methods can meaningfully alter the temporal behavior of the BiLSTM predictions.

## Block 3.2 – Majority Vote Smoothing
What this block does?

☑ Implements a sliding-window majority vote smoothing algorithm.

☑ Replaces each prediction with the most frequently occurring class within its local temporal neighborhood.

☑ Serves as the simplest baseline for reducing short-term prediction fluctuations.

Conclusions

☑ Successfully implemented the Majority Vote post-processing method.

☑ Provides a simple temporal smoothing baseline for comparison with more advanced post-processing techniques.

☑ Will be evaluated using the same temporal consistency metrics as the original BiLSTM predictions.

## Block 3.3 – Moving Average Smoothing
What this block does?
☑ Applies a moving average filter to the prediction sequence.

☑ Converts the smoothed values back into discrete fatigue classes by rounding.

☑ Reduces isolated prediction fluctuations while preserving the overall temporal trend.

Conclusions

☑ Successfully implemented the Moving Average smoothing method.

☑ Provides a continuous-valued smoothing baseline for temporal post-processing.

☑ Enables comparison between statistical smoothing and majority-vote filtering.

#Block 3.4 – HMM Viterbi Decoding
What this block does?

☑ Implements Hidden Markov Model (HMM) based temporal post-processing using Viterbi decoding.

☑ Models fatigue progression using transition probabilities that favor gradual state changes.

☑ Learns transition and emission probabilities from the prediction sequences before decoding the most likely temporal state sequence.

☑ Provides the strongest sequence-modeling baseline among the evaluated post-processing methods.

Conclusions

☑ Successfully implemented the HMM-based temporal smoothing framework.

☑ Introduced a probabilistic baseline capable of enforcing temporally coherent prediction sequences.


☑ Completes the set of three post-processing strategies (Majority Vote, Moving Average, and HMM) for survivability testing.

☑ All post-processing methods are now ready for quantitative evaluation under the identical temporal consistency framework.

## Block 3.5 – Apply Post-processing Methods
What this block does?

☑ Applies three post-processing methods (Majority Vote, Moving Average, and HMM Viterbi decoding) to every BiLSTM prediction sequence.

☑ Evaluates multiple window sizes (3, 5, and 9) for the Majority Vote and Moving Average methods.

☑ Computes classification accuracy and temporal consistency metrics for every post-processed prediction sequence.

☑ Stores the results for subsequent comparison with the original BiLSTM predictions.

Conclusions

☑ Successfully applied all three post-processing methods to all 23 recording sessions.

☑ Evaluated multiple smoothing configurations for Majority Vote and Moving Average.

☑ Successfully generated post-processed prediction sequences and corresponding temporal consistency metrics.

☑ The Stage 3 evaluation dataset is now prepared for quantitative comparison of post-processing effectiveness.

## Block 3.6 – Survivability Comparison
What this block does?

☑ Compares the temporal consistency of the original BiLSTM predictions with three post-processing methods.

☑ Evaluates the effect of Majority Vote, Moving Average, and HMM Viterbi decoding on prediction accuracy and temporal consistency.

☑ Quantifies changes in Reversal Rate (RR), Temporal Deviation Score (TDS), Trajectory Correlation (TC), and classification accuracy.

☑ Determines whether simple post-processing can substantially alter the temporal behavior of BiLSTM predictions.

Conclusions

☑ Majority Vote and Moving Average smoothing produced only minor reductions in prediction reversal rate while maintaining essentially unchanged classification accuracy.

☑ The largest reduction in reversal rate (approximately 25%) was achieved using Majority Vote with a window size of 9, although the absolute improvement remained small 
because the original BiLSTM reversal rate was already low.

☑ Moving Average smoothing produced similarly modest improvements, with negligible changes in classification accuracy.

☑ The HMM-based post-processing substantially degraded both classification accuracy and temporal consistency, indicating that the implemented HMM configuration was not effective for this dataset.

☑ Overall, the BiLSTM prediction sequences were already temporally stable, leaving limited opportunity for further improvement through simple post-processing.

## Block 3.7 – Accuracy–Consistency Comparison
What this block does?

☑ Visualizes the relationship between classification accuracy and temporal consistency after applying different post-processing methods.


☑ Compares the original BiLSTM predictions with Majority Vote, Moving Average, and HMM-based post-processing.

☑ Examines whether improvements in temporal consistency are associated with reductions in classification accuracy.

☑ Provides a graphical comparison of the effect of post-processing on prediction behavior.

Conclusions

☑ Majority Vote and Moving Average post-processing produced only marginal changes in both temporal consistency and classification accuracy.

☑ No meaningful accuracy–consistency tradeoff was observed for the BiLSTM predictions.

☑ The original BiLSTM predictions already occupied a region of high temporal consistency, leaving limited room for further improvement.

☑ The HMM method substantially reduced classification accuracy without improving temporal consistency, indicating that it was not an effective post-processing strategy 
under the current implementation.

## Block 3.8 – Final Stage 3 Summary
What this block does?

☑ Summarizes the effect of post-processing on the temporal behavior of the BiLSTM predictions.

☑ Reports the best post-processing performance achieved across all evaluated methods.

☑ Saves the Stage 3 outputs for future comparison with other classifier architectures.

☑ Provides a concise summary of the principal Stage 3 quantitative results.

Conclusions

☑ The original BiLSTM prediction sequences exhibited a low mean reversal rate (0.0065).

☑ The best post-processing method reduced the reversal rate to 0.0049, corresponding to an improvement of approximately 25%.

☑ Classification accuracy remained essentially unchanged after the best-performing post-processing method.

☑ The HMM-based post-processing substantially degraded both temporal consistency and classification accuracy under the current implementation.

☑ Overall, simple post-processing produced only limited improvements because the BiLSTM prediction sequences were already temporally stable.

