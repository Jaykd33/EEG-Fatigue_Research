# Stage 5B — Adversarial Subject Disentanglement using Domain-Adversarial Neural Networks (DANN)

**Purpose:** Investigates whether explicitly removing subject-specific information from the BiLSTM representation through adversarial learning improves cross-subject fatigue classification performance under the Leave-One-Subject-Out (LOSO) evaluation protocol.

**What this stage does:**
- Implements a **Domain-Adversarial Neural Network (DANN)** by extending the Stage 1 BiLSTM architecture with a **Gradient Reversal Layer (GRL)** and an auxiliary subject-classification branch.
- Trains the feature extractor to simultaneously:
  - Minimize fatigue classification error.
  - Maximize subject-classification error through gradient reversal, encouraging subject-invariant representations.
- Reuses the existing variable-length EEG data pipeline and LOSO evaluation framework developed in earlier stages.
- Evaluates whether adversarial learning improves cross-subject fatigue classification compared with both the original scikit-learn MLP and a PyTorch BiLSTM baseline.
- Repeats the linear subject-identity probe from Stage 5A to verify whether adversarial training successfully reduces subject-specific information within the learned representation space.
- Performs statistical analyses and visual comparisons to assess whether any observed improvements support the causal hypothesis that subject identity leakage contributes to poor cross-subject generalization.

**Key outputs:**
- PyTorch BiLSTM baseline (without adversarial learning).
- DANN model with Gradient Reversal Layer.
- LOSO fatigue classification results.
- Post-DANN subject identity probe results.
- Statistical comparison between baseline and DANN performance.
- Visualization figures and summary tables.

**Conclusion:**
- Stage 5B evaluates the proposed causal intervention by attempting to suppress subject identity information within the BiLSTM representations while preserving fatigue-discriminative features. The effectiveness of this intervention is assessed through changes in LOSO fatigue classification accuracy, post-adversarial subject probe performance, and statistical analyses, providing evidence for or against the hypothesis that subject identity encoding is a primary driver of poor cross-subject generalization.

### Block 5B.0 — Stage 5B Imports and Configuration

**Purpose:** Imports the additional libraries required for adversarial training and configures the Domain-Adversarial Neural Network (DANN) hyperparameters while reusing the existing BiLSTM training settings established in previous stages.

**What this block does:**
- Imports the additional Python modules required for:
  - Logistic Regression subject probing.
  - Subject label encoding.
  - Stratified train/test splitting.
  - Classification metrics.
  - Gradient Reversal Layer implementation.
  - Statistical significance testing.
- Defines the DANN-specific hyperparameters while reusing the baseline BiLSTM settings for:
  - Learning rate.
  - Maximum training epochs.
  - Early stopping patience.
  - Batch size.
  - Validation split.
- Sets the maximum adversarial weight (**λ<sub>max</sub> = 1.0**) for Gradient Reversal training.
- Creates a label encoder that maps the **21 subject IDs** to integer labels required by the subject classifier.
- Displays the adversarial λ annealing schedule used during training according to **Ganin et al. (2016)**.

**Key outputs:**
- Device: **CUDA**
- Number of subjects: **21**
- Maximum adversarial weight: **λ<sub>max</sub> = 1.0**
- Maximum epochs: **50**
- Batch size: **8 sequences**
- Lambda annealing schedule:
  - Epoch 0 → **0.0000**
  - Epoch 10 → **0.7700**
  - Epoch 20 → **0.9668**
  - Epoch 30 → **0.9956**
  - Epoch 40 → **0.9994**
  - Epoch 50 → **0.9999**

**Conclusion:**
- The computational environment and adversarial training configuration were successfully initialized. By reusing the baseline BiLSTM hyperparameters while introducing only the DANN-specific settings, this block ensures that subsequent performance differences can be attributed primarily to adversarial subject-invariant learning rather than changes in the underlying training configuration.

- ### Block 5B.1 — Gradient Reversal Layer

**Purpose:** Implements the Gradient Reversal Layer (GRL), the core component of the Domain-Adversarial Neural Network (DANN), enabling adversarial learning by encouraging the BiLSTM feature extractor to learn representations that are discriminative for fatigue classification while being invariant to subject identity.

**What this block does:**
- Defines the custom `GradientReversalFunction`, which:
  - Acts as an identity function during the forward pass.
  - Multiplies incoming gradients by **−λ** during backpropagation.
- Implements the `GradientReversalLayer` module for seamless integration into the DANN architecture.
- Defines the **Ganin et al. (2016)** λ annealing schedule, which progressively increases the strength of adversarial learning throughout training.
- Performs a gradient verification test by:
  - Passing a synthetic tensor through the GRL.
  - Executing backpropagation.
  - Confirming that gradients are correctly multiplied by **−0.5** when λ = 0.5.
- Removes temporary verification variables after successful validation.

**Key outputs:**
- `GradientReversalFunction`
- `GradientReversalLayer`
- `get_lambda()`
- Verification results:
  - Forward pass: **Input (4, 128) → Output (4, 128)**
  - Backward pass: **Gradient correctly multiplied by −0.5**
  - Gradient reversal verification: **Passed**

**Conclusion:**
- The Gradient Reversal Layer was successfully implemented and verified. The forward pass preserves the input representations unchanged, while the backward pass correctly reverses and scales the gradients according to the specified adversarial weight. This confirms that the feature extractor will receive adversarial gradients during training, enabling the DANN model to learn representations that retain fatigue-related information while discouraging the encoding of subject-specific characteristics.

- ### Block 5B.2 — DANN-BiLSTM Architecture

**Purpose:** Defines the Domain-Adversarial BiLSTM (DANN-BiLSTM) architecture by extending the baseline BiLSTM fatigue classifier with a Gradient Reversal Layer (GRL) and a sequence-level subject classification branch for adversarial subject-invariant representation learning.

**What this block does:**
- Defines the `DANNBiLSTM` model, consisting of:
  - A shared **2-layer bidirectional LSTM** feature extractor identical to the baseline model.
  - A **fatigue classification head** that predicts fatigue labels for every EEG timestep.
  - A **Gradient Reversal Layer (GRL)** that reverses gradients flowing from the subject classifier during backpropagation.
  - A **subject classification head** that predicts subject identity from the mean-pooled sequence representation.
- Computes fatigue predictions using the per-timestep LSTM outputs.
- Computes subject predictions from the **mean-pooled sequence representation**, ensuring adversarial learning operates at the session level.
- Provides the `get_sequence_repr()` function for extracting sequence representations without gradient reversal for post-training subject probe analysis.
- Performs a forward-pass sanity check to verify the architecture and output dimensions.

**Key outputs:**
- `DANNBiLSTM`
- Fatigue logits shape: **(3, 100, 3)**
- Subject logits shape: **(3, 21)**
- Trainable parameters: **194,712**

**Conclusion:**
- The DANN-BiLSTM architecture was successfully constructed and verified. The baseline BiLSTM fatigue classifier was preserved unchanged, while a Gradient Reversal Layer and sequence-level subject classifier were incorporated to enable adversarial subject-invariant learning. The successful sanity check confirms that the model produces correctly shaped fatigue and subject predictions, providing the foundation for subsequent adversarial training and evaluation.

- ### Block 5B.3 — DANN Training and Evaluation Utilities

**Purpose:** Implements the core training and evaluation functions for the DANN-BiLSTM, extending the baseline BiLSTM training pipeline to jointly optimize fatigue classification and adversarial subject-invariant representation learning.

**What this block does:**
- Defines `train_dann_epoch()`, which:
  - Performs one epoch of adversarial DANN training.
  - Extracts subject labels directly from the session metadata using the subject label encoder.
  - Computes the fatigue classification loss while ignoring padded timesteps (`ignore_index = -100`).
  - Computes the sequence-level subject classification loss.
  - Combines both objectives into a single optimization loss.
  - Applies gradient reversal to the feature extractor through the GRL while updating the subject classifier normally.
  - Uses gradient clipping to improve training stability.
- Defines `evaluate_dann()`, which:
  - Evaluates fatigue classification performance only.
  - Disables gradient reversal during inference (λ = 0).
  - Ignores padded timesteps when computing predictions and loss.
  - Returns the overall fatigue classification accuracy, average loss, and flattened prediction arrays for subsequent analyses.
- Preserves the same data handling and evaluation strategy used in the baseline BiLSTM, enabling direct performance comparisons.

**Key outputs:**
- `train_dann_epoch()`
- `evaluate_dann()`
- Returned metrics:
  - Mean fatigue loss.
  - Mean subject loss.
  - Mean total training loss.
  - Fatigue classification accuracy.
  - Flattened true and predicted fatigue labels.

**Conclusion:**
- The DANN-BiLSTM training and evaluation utilities were successfully implemented. By extending the baseline training pipeline with an additional adversarial subject-classification objective while preserving the original fatigue evaluation protocol, this block provides the computational framework required to assess whether adversarial subject-invariant learning improves cross-subject fatigue classification performance.

- ### Block 5B.4 — DANN LOSO Evaluation Loop

**Purpose:** Implements the complete Leave-One-Subject-Out (LOSO) evaluation pipeline for the DANN-BiLSTM, ensuring that adversarial subject-invariant learning is evaluated under the same experimental protocol as the baseline BiLSTM.

**What this block does:**
- Defines the `run_dann_loso()` function to execute the complete DANN evaluation procedure.
- Performs Leave-One-Subject-Out (LOSO) cross-validation by:
  - Holding one subject out for testing in each fold.
  - Splitting the remaining subjects into training and validation sets.
- Fits a feature scaler using only the training subjects to prevent data leakage.
- Constructs the training, validation, and testing datasets using the existing variable-length EEG data pipeline.
- Initializes a new DANN-BiLSTM model for each fold together with the optimizer, learning-rate scheduler, and loss functions.
- Trains the model using adversarial optimization while monitoring validation fatigue accuracy for early stopping.
- Restores the best-performing model before evaluating the held-out test subject.
- Records per-session predictions, LOSO accuracies, and training histories for subsequent statistical analysis and visualization.

**Key outputs:**
- `run_dann_loso()`
- Returned objects:
  - `dann_results` — per-session LOSO fatigue classification results.
  - `training_log` — per-fold fatigue loss, subject loss, and validation accuracy curves.
- Console output for each LOSO fold:
  - Test subject.
  - Number of training epochs.
  - Final adversarial weight (λ).
  - Best validation accuracy.
  - Test accuracy.

**Conclusion:**
- The complete DANN-BiLSTM LOSO evaluation framework was successfully implemented. By preserving the same data preprocessing, validation strategy, early stopping, and evaluation protocol used by the baseline BiLSTM while introducing adversarial training, this block enables a fair assessment of whether learning subject-invariant representations improves cross-subject fatigue classification performance.

- ### Block 5B.5 — Run DANN-BiLSTM LOSO Evaluation

**Purpose:** Executes the complete Leave-One-Subject-Out (LOSO) evaluation of the DANN-BiLSTM model to assess whether adversarial subject-invariant learning improves cross-subject fatigue classification performance.

**What this block does:**
- Executes the complete DANN-BiLSTM LOSO evaluation pipeline using the adversarial training configuration established in the previous blocks.
- Trains one DANN-BiLSTM model for each of the **21 LOSO folds** with Gradient Reversal enabled.
- Applies validation-based early stopping independently for each held-out subject.
- Records the final adversarial weight (λ), validation accuracy, and test accuracy for every LOSO fold.
- Aggregates the predictions from all folds to compute the overall pooled accuracy and the mean per-subject LOSO accuracy.

**Key results:**
- Number of LOSO folds: **21**
- Overall pooled LOSO accuracy: **41.00%**
- Mean per-subject LOSO accuracy: **41.00% ± 22.64%**
- Final adversarial weight (λ) ranged from **0.6134** to **0.9991**, depending on the number of training epochs completed before early stopping.

**Conclusion:**
- The DANN-BiLSTM model successfully completed adversarial training and evaluation across all **21 LOSO folds**.
- The final pooled LOSO accuracy of **41.00%** indicates that, under the current training configuration, adversarial subject-invariant learning **did not improve cross-subject fatigue classification performance** over the baseline BiLSTM established in Stage 1.
- The wide variation in per-subject accuracies further suggests that the effect of adversarial training is highly subject-dependent, motivating the subsequent analyses to determine whether the learned representations successfully reduced subject identity information despite the lack of overall performance improvement.

- ### Block 5B.6 — Post-DANN Subject Identity Probe (Window-Level)

**Purpose:** Evaluates whether adversarial training successfully reduced subject-specific information in the learned BiLSTM representations by repeating the identical window-level linear probe protocol used in Stage 5A. :contentReference[oaicite:0]{index=0}

**What this block does:**
- Retrains the DANN-BiLSTM on the reference LOSO fold to obtain a representative trained model.
- Registers a forward hook on the **ReLU layer (`fatigue_head[1]`)** to extract **64-dimensional window-level representations**, matching the extraction point used in Stage 5A.
- Extracts one representation for every EEG window across all sessions.
- Verifies that the extracted representations have the expected dimensionality and are correctly aligned with the fatigue labels.
- Performs a **10-fold stratified (80/20) subject identity probe** using multinomial Logistic Regression, identical to the Stage 5A protocol.
- Compares the resulting probe accuracy directly with the Stage 5A BiLSTM representations.
- Reports a mechanistic interpretation of the effectiveness of Gradient Reversal in removing subject identity.

**Key results:**
- Best validation accuracy (reference DANN model): **50.82%**
- Representation matrix: **(20,355, 64)**
- Fatigue labels: **(20,355,)**
- Subjects represented: **21**
- Representation dimensionality verified: **64**
- Probe protocol:
  - **10 stratified train/test splits (80/20)**
  - **16,284 training windows / 4,071 testing windows per split**
- Post-DANN probe accuracy: **88.63% ± 0.48%**
- Stage 5A probe accuracy: **76.37%**
- Chance accuracy: **4.76%**
- Probe change: **−12.26 percentage points** (76.37% → 88.63%)
- Statistical significance:
  - Stage 5A: **p = 7.61 × 10⁻²²**
  - Post-DANN: **p = 1.67 × 10⁻²¹**

**Conclusion:**
- Contrary to the intended objective of adversarial learning, the post-DANN representations became **more predictive of subject identity** than the original BiLSTM representations. The linear probe accuracy increased from **76.37%** to **88.63%**, remaining far above the **4.76%** chance level. Consequently, the Gradient Reversal Layer did **not** produce subject-invariant representations under the current configuration. Instead, the learned features retained—and even strengthened—subject-specific information, indicating that stronger adversarial regularization or architectural modifications would be required to achieve effective subject disentanglement.

- ### Block 5B.7 — Baseline vs DANN-BiLSTM Comparison Analysis

**Purpose:** Compares the cross-subject fatigue classification performance of the baseline BiLSTM and the DANN-BiLSTM using per-subject LOSO accuracies, statistical significance testing, and class-wise performance metrics.

**What this block does:**
- Computes the mean LOSO accuracy for each subject using the baseline BiLSTM and DANN-BiLSTM results.
- Constructs a per-subject comparison table showing the performance difference between the two models.
- Calculates the overall mean LOSO accuracy and the average improvement (Δ) across all subjects.
- Performs a **Wilcoxon signed-rank test** to determine whether the observed performance differences are statistically significant.
- Generates classification reports for both models, including precision, recall, F1-score, and overall accuracy for each fatigue class.

**Key results:**
- Baseline BiLSTM mean LOSO accuracy: **40.85%**
- DANN-BiLSTM mean LOSO accuracy: **41.56%**
- Mean improvement (DANN − Baseline): **+0.70 ± 6.91 percentage points**
- Wilcoxon signed-rank test:
  - Statistic: **73.000**
  - p-value: **0.8684**
  - Result: **No statistically significant difference**
- Overall classification accuracy:
  - Baseline BiLSTM: **39%**
  - DANN-BiLSTM: **41%**
- DANN-BiLSTM showed:
  - Higher recall for the **Tired** class (**0.64 → 0.70**).
  - Improved precision for the **Drowsy** class (**0.35 → 0.42**).
  - Similar performance for the **Awake** class.

**Conclusion:**
- The DANN-BiLSTM produced only a **marginal improvement** in average LOSO accuracy (**40.85% → 41.56%**), with considerable variability across subjects. Although modest gains were observed for several individual subjects and slight improvements were achieved in the class-wise classification metrics, the **Wilcoxon signed-rank test (p = 0.8684)** indicates that these differences are **not statistically significant**. Combined with the results of the post-DANN subject identity probe, the findings suggest that the adversarial training strategy did not provide a meaningful improvement in cross-subject generalization under the current experimental configuration.

- ### Block 5B.8 — Visualization Suite

**Purpose:** Generates visualizations that compare the baseline BiLSTM and DANN-BiLSTM models, illustrating per-subject performance, training dynamics, confusion matrices, and the adversarial λ annealing schedule.

**What this block does:**
- Creates a comprehensive visualization figure containing:
  - A per-subject LOSO accuracy comparison between the baseline BiLSTM and DANN-BiLSTM.
  - A per-subject improvement (Δ accuracy) plot highlighting subjects that benefited or declined after adversarial training.
  - Training curves for a representative LOSO fold, including fatigue loss, subject loss, and validation accuracy.
  - Side-by-side normalized confusion matrices for the baseline and DANN-BiLSTM models.
- Generates a separate plot illustrating the **Ganin et al.** adversarial λ annealing schedule used during training.
- Saves all generated figures to the project output directory.

**Key outputs:**
- Visualization panels:
  - Per-subject LOSO accuracy comparison.
  - Per-subject accuracy improvement (Δ).
  - DANN training curves (fatigue loss, subject loss, validation accuracy).
  - Baseline and DANN normalized confusion matrices.
- Additional visualization:
  - Lambda annealing schedule.
- Saved figures:
  - `bilstm_stage5B_dann_results.png`
  - `bilstm_stage5B_lambda_schedule.png`

**Conclusion:**
- The visualization suite provides a comprehensive graphical summary of the DANN-BiLSTM evaluation. The figures demonstrate that adversarial training produced only minor subject-specific performance changes, with improvements for some subjects and degradations for others, consistent with the statistically non-significant overall performance difference. The training curves and λ schedule verify the intended optimization process, while the confusion matrices enable class-wise comparison between the baseline and adversarial models.

- 
