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


