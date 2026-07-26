# STAGE 5B
### Block 5B.0 — Imports and Configuration

**Purpose:** Initializes the complete experimental environment required for Stage 5B by importing all necessary libraries, establishing reproducibility, defining the DANN architecture parameters, and configuring the hyperparameters for adversarial training.

**What this block does:**
- Imports all required PyTorch, scientific computing, visualization, and machine learning libraries used throughout Stage 5B.
- Sets deterministic random seeds for Python, NumPy, and PyTorch to ensure reproducible experimental results.
- Automatically detects the available computation device (CPU or GPU) for model training.
- Defines the architecture of the Domain-Adversarial Neural Network (DANN), matching the original MLP feature extractor:
  - Input dimension: **85 DE features**
  - Hidden layers: **256 → 128 → 64**
  - Representation bottleneck: **64 dimensions**
  - Fatigue classifier: **3 classes (Awake, Tired, Drowsy)**
  - Subject classifier: **21 subject classes**
- Specifies the training hyperparameters, including learning rate, batch size, maximum epochs, early stopping patience, adversarial loss weight, and validation split.
- Creates the output directory used for storing Stage 5B results.

**Configuration used:**
- Device: **CUDA GPU**
- Feature dimension: **85**
- Representation dimension: **64**
- Fatigue classes: **3**
- Subject classes: **21**
- Learning rate: **0.001**
- Maximum epochs: **60**
- Batch size: **256**
- Maximum adversarial weight (λ): **1.0**
- Validation fraction: **15%**

**Conclusion:**
- This block prepares the complete computational environment required for Domain-Adversarial Neural Network training.
- The architecture is intentionally designed to mirror the original MLP feature extractor while introducing an additional adversarial subject-classification branch.
- Maintaining identical feature dimensions and hidden-layer structure ensures that any performance differences observed in Stage 5B can be attributed to adversarial subject-invariant representation learning rather than architectural changes.

### Block 5B.1 — Gradient Reversal Layer

**Purpose:** Implements the **Gradient Reversal Layer (GRL)**, the key component of the Domain-Adversarial Neural Network (DANN), which encourages the feature extractor to learn representations that are highly informative for fatigue classification while suppressing subject-specific information.

**What this block does:**
- Defines a custom **Gradient Reversal Function** using PyTorch's automatic differentiation framework.
- Implements an identity mapping during the forward pass, allowing feature representations to pass unchanged to the subject classifier.
- Reverses the sign of the gradients during backpropagation by multiplying them by **−λ**, causing the feature extractor to maximize the subject classification loss while minimizing the fatigue classification loss.
- Wraps the custom autograd function into a reusable **Gradient Reversal Layer (GRL)** module.
- Implements the **Ganin et al. (2016)** adversarial weight scheduling strategy, where the gradient reversal coefficient (λ) gradually increases throughout training.
- Prints the λ values at representative training epochs to verify the annealing schedule.

**Key outputs:**
- `GradientReversalFunction` — custom autograd implementation of gradient reversal.
- `GradientReversalLayer` — reusable PyTorch module for adversarial training.
- `get_lambda()` — function implementing the progressive λ annealing schedule.
- λ schedule:
  - Epoch 0: **0.0000**
  - Epoch 10: **0.6897**
  - Epoch 20: **0.9348**
  - Epoch 30: **0.9877**
  - Epoch 40: **0.9977**
  - Epoch 50: **0.9996**
  - Epoch 59: **0.9999**

**Conclusion:**
- This block establishes the adversarial learning mechanism that distinguishes DANN from conventional neural networks.
- The Gradient Reversal Layer enables simultaneous optimization of two competing objectives: preserving fatigue-discriminative information while actively removing subject-discriminative information from the learned representation space.
- The gradual λ annealing schedule ensures stable optimization by allowing the model to first learn meaningful fatigue representations before progressively strengthening the adversarial objective to enforce subject invariance.

### Block 5B.2 — DANN Architecture

**Purpose:** Defines the complete **Domain-Adversarial Neural Network (DANN)** architecture, extending the baseline MLP with an adversarial subject-classification branch to learn fatigue-discriminative yet subject-invariant feature representations.

**What this block does:**
- Implements the **Feature Extractor**, which transforms the 85-dimensional differential entropy feature vector into a compact **64-dimensional representation** using three fully connected layers (256 → 128 → 64).
- Incorporates **Batch Normalization**, ReLU activation, and Dropout within the feature extractor to improve training stability during adversarial optimization.
- Defines the **Fatigue Classifier**, which predicts one of the three fatigue states directly from the learned representation.
- Defines the **Subject Classifier**, consisting of a hidden layer followed by a 21-class output layer, providing sufficient capacity to detect subject identity from the learned features.
- Connects the subject classifier through the **Gradient Reversal Layer (GRL)** so that gradients from the subject classification objective encourage the feature extractor to suppress subject-specific information.
- Combines all components into a unified **DANNModel**, which simultaneously produces:
  - Fatigue classification logits.
  - Subject classification logits.
- Provides a utility function to extract the learned 64-dimensional representations without applying gradient reversal.
- Performs a forward-pass sanity check to verify the correctness of the architecture and reports the total number of trainable parameters.

**Key outputs:**
- `FeatureExtractor` — shared representation learning network.
- `FatigueClassifier` — predicts fatigue state from the learned representation.
- `SubjectClassifier` — predicts subject identity through the adversarial branch.
- `DANNModel` — complete adversarial network integrating all three components.
- Sanity check:
  - Input shape: **(8, 85)**
  - Fatigue logits: **(8, 3)**
  - Subject logits: **(8, 21)**
  - Trainable parameters: **69,784**

**Conclusion:**
- This block establishes the complete DANN architecture used throughout Stage 5B.
- The feature extractor closely mirrors the baseline MLP architecture to ensure a fair comparison while introducing an adversarial subject-classification branch through the Gradient Reversal Layer.
- Successful forward-pass verification confirms that both classification heads produce outputs with the expected dimensions, indicating that the architecture is correctly configured for subsequent adversarial training and evaluation.

### Block 5B.3 — Window-Level Dataset and LOSO Utilities

**Purpose:** Prepares the window-level dataset required for DANN training by converting session-based EEG recordings into individual training samples and generating the subject identity labels needed for adversarial learning.

**What this block does:**
- Defines a custom **WindowDataset** class compatible with the PyTorch `Dataset` interface.
- Converts each EEG recording session into independent **window-level samples**, where every window contains:
  - An 85-dimensional differential entropy feature vector.
  - A fatigue class label.
  - A subject identity label.
- Optionally fits and applies a **StandardScaler** using only the training data to ensure consistent feature normalization.
- Encodes subject identities as integer labels using a **LabelEncoder**, enabling multi-class subject classification within the adversarial branch.
- Stores all feature vectors, fatigue labels, and subject labels as PyTorch tensors for efficient mini-batch training with `DataLoader`.
- Preserves the chronological order of windows within each recording session while allowing windows from different sessions to be combined during mini-batch sampling.

**Key outputs:**
- `WindowDataset` — custom dataset for DANN training and evaluation.
- `le_subj_dann` — fitted subject label encoder.
- Subject encoder summary:
  - Total subjects: **21**
  - Example mapping:
    - Subject **'1' → 0**
    - Subject **'10' → 1**
    - Subject **'11' → 2**

**Conclusion:**
- This block transforms the original session-level EEG recordings into a window-level dataset suitable for adversarial neural network training.
- By pairing every EEG window with both its fatigue label and encoded subject identity, the dataset simultaneously supports the fatigue classification objective and the adversarial subject-classification objective of the DANN framework.
- The resulting dataset serves as the primary input for the LOSO adversarial training pipeline implemented in the subsequent blocks.

### Block 5B.4 — DANN Training and Evaluation Functions

**Purpose:** Implements the complete training and evaluation pipeline for the Domain-Adversarial Neural Network (DANN), including adversarial optimization, model validation, and Leave-One-Subject-Out (LOSO) evaluation.

**What this block does:**
- Defines `train_dann_epoch()`, which performs one epoch of adversarial training by:
  - Computing the fatigue classification loss.
  - Computing the subject classification loss.
  - Combining both objectives while relying on the Gradient Reversal Layer to reverse gradients flowing into the feature extractor.
  - Applying gradient clipping to stabilize optimization.
  - Updating model parameters using the Adam optimizer.
- Defines `evaluate_dann()`, which evaluates fatigue classification performance on any dataset by:
  - Disabling gradient reversal during inference.
  - Computing fatigue classification loss and overall accuracy.
  - Returning the true and predicted fatigue labels for further analysis.
- Defines `run_dann_loso()`, which executes the complete **Leave-One-Subject-Out (LOSO)** evaluation procedure by:
  - Holding one subject out for testing in each fold.
  - Randomly selecting a subset of the remaining training subjects for validation.
  - Fitting a feature scaler using only the training data.
  - Constructing window-level training, validation, and testing datasets.
  - Initializing and training a new DANN model for each fold.
  - Applying early stopping based on validation fatigue accuracy.
  - Adjusting the learning rate using a ReduceLROnPlateau scheduler.
  - Restoring the best-performing model before final testing.
  - Recording per-session predictions and classification accuracies.
- Stores training curves and evaluation results for subsequent quantitative analysis and visualization.

**Key outputs:**
- `train_dann_epoch()` — performs one epoch of adversarial optimization.
- `evaluate_dann()` — evaluates fatigue classification performance on any dataset.
- `run_dann_loso()` — executes the complete LOSO adversarial training pipeline.
- Returned objects:
  - `dann_results` — per-session LOSO prediction results.
  - `training_log` — training and validation histories for every LOSO fold.

**Conclusion:**
- This block establishes the complete experimental framework for evaluating the DANN model under the same Leave-One-Subject-Out protocol used throughout the dissertation.
- The training procedure jointly optimizes fatigue classification and adversarial subject confusion while employing validation-based early stopping and adaptive learning-rate scheduling to improve training stability.
- By producing standardized LOSO evaluation results and detailed training logs, this pipeline enables a direct comparison between the baseline model and the adversarial DANN model in the subsequent experimental analysis.

- ### Block 5B.5 — Baseline PyTorch MLP (No Adversarial Training)

**Purpose:** Establishes a PyTorch implementation of the baseline MLP without adversarial learning to verify that the DANN architecture itself does not introduce performance improvements independent of the Gradient Reversal Layer.

**What this block does:**
- Executes the complete Leave-One-Subject-Out (LOSO) evaluation pipeline using the DANN architecture with the adversarial weight fixed at **λ = 0**, effectively disabling gradient reversal.
- Trains the shared feature extractor and fatigue classifier while preventing the subject-classification objective from influencing the learned representations.
- Evaluates fatigue classification performance on every held-out subject using the same protocol employed for subsequent DANN experiments.
- Computes the overall LOSO accuracy and the mean per-subject accuracy across all folds.
- Compares the PyTorch baseline performance with the previously obtained **scikit-learn MLP** baseline to validate the correctness of the PyTorch reimplementation.

**Key results:**
- Overall LOSO accuracy: **47.05%**
- Mean per-subject LOSO accuracy: **47.05% ± 20.56%**
- Reference scikit-learn MLP accuracy: **≈41%**
- Comparison verdict: **Warning** — the PyTorch implementation exceeds the scikit-learn baseline by more than **5 percentage points**.

**Conclusion:**
- The PyTorch baseline successfully completed the full LOSO evaluation without adversarial training, providing an appropriate reference model for evaluating the effectiveness of DANN.
- However, the observed baseline accuracy (**47.05%**) is noticeably higher than the original scikit-learn MLP baseline (**≈41%**), exceeding the predefined equivalence threshold.
- This discrepancy suggests that differences in implementation or training dynamics—such as mini-batch optimization, Batch Normalization, Dropout, Adam optimization, validation-based early stopping, or other PyTorch-specific training procedures—may contribute to improved performance independent of adversarial learning.
- Consequently, improvements observed after enabling DANN should be interpreted relative to this **PyTorch baseline**, rather than being attributed solely to adversarial subject-invariant representation learning.

- ### Block 5B.6 — DANN Training (Full Adversarial Run)

**Purpose:** Evaluates the complete Domain-Adversarial Neural Network (DANN) under the Leave-One-Subject-Out (LOSO) protocol to determine whether learning subject-invariant representations improves cross-subject fatigue classification performance.

**What this block does:**
- Executes the full LOSO evaluation pipeline using the DANN model with the adversarial objective enabled (**λ<sub>max</sub> = 1.0**).
- Gradually increases the Gradient Reversal Layer strength during training according to the Ganin et al. annealing schedule.
- Trains one DANN model for each LOSO fold while simultaneously optimizing:
  - Fatigue classification performance.
  - Subject-invariant representation learning through adversarial training.
- Applies early stopping using validation fatigue accuracy to prevent overfitting.
- Evaluates the best-performing model on the held-out subject in each fold.
- Aggregates predictions across all folds to compute the overall LOSO performance and mean per-subject accuracy.

**Key results:**
- Overall LOSO accuracy: **49.36%**
- Mean per-subject LOSO accuracy: **49.36% ± 22.71%**
- Adversarial training strength: **λ<sub>max</sub> = 1.0**
- Final λ values varied across folds depending on early stopping, reaching values between **0.6897** and **0.9896**.

**Conclusion:**
- The DANN model successfully completed adversarial LOSO training across all 21 subjects while progressively increasing the strength of the subject-invariance objective.
- Compared with the PyTorch baseline (**47.05%**), adversarial training improved the overall LOSO accuracy to **49.36%**, representing an absolute improvement of approximately **2.31 percentage points**.
- Although this improvement demonstrates that adversarial subject-invariant representation learning provides a measurable benefit for cross-subject fatigue classification, it falls slightly below the predefined **3 percentage point** threshold considered strong evidence for the causal hypothesis.
- These findings suggest that **subject identity leakage contributes to the cross-subject generalization gap**, but eliminating subject-specific information alone is insufficient to fully close the performance gap. Additional factors, such as label boundary variability across subjects, likely continue to influence cross-subject classification performance and motivate the subsequent analyses in Stage 5C.

### Block 5B.7 — Post-DANN Subject Identity Probe

**Purpose:** Evaluates whether adversarial training successfully reduced subject-specific information in the learned representations by repeating the same linear subject-identity probe used in Stage 5A on the representations learned by the DANN model.

**What this block does:**
- Trains a representative DANN model using the Stage 5B adversarial training procedure.
- Extracts the learned **64-dimensional feature representations** for every EEG window using the trained feature extractor.
- Encodes subject identities as numerical class labels.
- Performs the same **10-fold stratified window-level linear probe** employed in Stage 5A using multinomial Logistic Regression.
- Computes the mean and standard deviation of the subject-identification accuracy across all probe splits.
- Compares the post-DANN probe accuracy with the Stage 5A baseline to quantify the reduction in subject identity information.
- Determines whether adversarial training successfully removed, partially removed, or failed to remove subject-specific representations.

**Key results:**
- Stage 5A subject probe accuracy: **100.00%**
- Post-DANN subject probe accuracy: **99.31% ± 0.18%**
- Chance accuracy: **4.76%**
- Reduction in probe accuracy: **0.69 percentage points**
- Verdict: **Subject identity not substantially removed**

**Conclusion:**
- Repeating the subject-identity probe after adversarial training revealed that the learned representations remain **highly predictive of subject identity**.
- Although the DANN model achieved a modest improvement in cross-subject fatigue classification performance (Block 5B.6), the subject probe accuracy decreased by only **0.69 percentage points**, remaining close to perfect (**99.31%**).
- These results indicate that the adversarial objective was **insufficient to eliminate subject-specific information** from the learned feature space under the current training configuration.
- Consequently, the modest improvement in LOSO performance observed after DANN training is unlikely to be explained by successful removal of subject identity leakage alone. Strong subject-discriminative information remains embedded within the representations, suggesting that more aggressive adversarial training, architectural modifications, or alternative domain-invariant learning strategies may be required to effectively disentangle subject identity from fatigue-related information.

### Block 5B.8 — Comprehensive Comparison and Statistical Analysis

**Purpose:** Compares the performance of the original scikit-learn MLP, the PyTorch baseline, and the Domain-Adversarial Neural Network (DANN) to determine whether adversarial training provides meaningful improvements in cross-subject fatigue classification and whether those improvements are statistically significant.

**What this block does:**
- Aggregates the Leave-One-Subject-Out (LOSO) accuracies obtained from:
  - The original **scikit-learn MLP**.
  - The **PyTorch baseline** without adversarial learning.
  - The **DANN** model with adversarial training.
- Constructs a per-subject comparison table showing:
  - LOSO accuracy for each model.
  - Improvement of DANN over the PyTorch baseline.
  - Improvement of DANN over the original scikit-learn MLP.
- Computes the overall mean and standard deviation of LOSO accuracy for each model.
- Performs a **Wilcoxon signed-rank test** to evaluate whether the performance difference between the PyTorch baseline and DANN is statistically significant.
- Generates detailed classification reports (precision, recall, and F1-score) for each fatigue class under both the PyTorch baseline and DANN.

**Key results:**
- Mean LOSO accuracy:
  - **Scikit-learn MLP:** **41.60% ± 20.53%**
  - **PyTorch baseline:** **46.58% ± 21.95%**
  - **DANN:** **49.31% ± 24.08%**
- Mean improvement:
  - DANN vs PyTorch baseline: **+2.73 percentage points**
  - DANN vs scikit-learn MLP: **+7.71 percentage points**
- Wilcoxon signed-rank test:
  - Statistic: **39.50**
  - **p = 0.0798**
  - Result: **No statistically significant difference** between DANN and the PyTorch baseline at the 5% significance level.
- Classification performance:
  - Overall accuracy improved from **47%** (PyTorch baseline) to **49%** (DANN).
  - DANN increased the precision and recall of the **Awake** and **Tired** classes while maintaining comparable performance on the **Drowsy** class.

**Conclusion:**
- The DANN model achieved the highest overall LOSO accuracy among the three evaluated models, improving average cross-subject performance by approximately **2.73 percentage points** over the PyTorch baseline and **7.71 percentage points** over the original scikit-learn implementation.
- However, the Wilcoxon signed-rank test indicated that these improvements were **not statistically significant** (**p = 0.0798**), suggesting that the observed gains may partly reflect subject-specific variability rather than a consistent improvement across all participants.
- Subject-level analysis revealed that DANN substantially benefited several subjects while producing little improvement—or slight degradation—for others, indicating heterogeneous responses to adversarial training.
- Overall, Stage 5B demonstrates that adversarial training provides **modest but inconsistent improvements** in cross-subject fatigue classification. Combined with the findings of Block 5B.7, where subject identity remained highly recoverable after adversarial learning, the results suggest that the current DANN configuration only partially addresses the cross-subject generalization problem, motivating further investigation into alternative explanations such as subject-specific decision boundary differences in Stage 5C.

### Block 5B.9 — Visualization Suite

**Purpose:** Generates publication-quality visualizations summarizing the performance of the baseline and DANN models, illustrating subject-wise improvements, adversarial training dynamics, and the evolution of the Gradient Reversal Layer (GRL) strength throughout training.

**What this block does:**
- Creates a four-panel visualization comprising:
  - A per-subject comparison of LOSO accuracies for the **scikit-learn MLP**, **PyTorch baseline**, and **DANN** models.
  - A bar chart showing the per-subject change in LOSO accuracy achieved by DANN relative to the PyTorch baseline.
  - Training curves for a representative LOSO fold, including fatigue loss, subject-classification loss, and validation fatigue accuracy.
  - The **Ganin et al.** adversarial weight (λ) annealing schedule used during DANN training.
- Includes appropriate titles, legends, axis labels, and reference lines to facilitate interpretation.
- Saves the generated figures to the Stage 5B output directory for inclusion in the dissertation.

**Key outputs:**
- Figure: **`stage5B_dann_results.png`**
  - Per-subject LOSO accuracy comparison.
  - DANN improvement over the PyTorch baseline.
  - Representative DANN training curves.
- Figure: **`stage5B_lambda_schedule.png`**
  - Adversarial λ annealing schedule used during training.

**Conclusion:**
- The generated visualizations provide a comprehensive summary of the Stage 5B experiments by illustrating comparative model performance, subject-specific variability, adversarial training behaviour, and the progressive increase of the Gradient Reversal Layer strength.
- Together, these figures complement the quantitative analyses presented in previous blocks and provide visual evidence supporting the interpretation of the DANN experimental results.

### Block 5B.10 — Stage 5B Summary and Causal Verdict

**Purpose:** Consolidates the findings from all Stage 5B experiments to evaluate whether adversarial subject-invariant learning provides causal evidence that subject identity encoding is responsible for poor cross-subject fatigue classification performance.

**What this block does:**
- Summarizes the average LOSO performance of the:
  - Original **scikit-learn MLP**.
  - **PyTorch baseline** without adversarial learning.
  - **DANN** model with adversarial training.
- Reports the post-DANN subject identity probe accuracy alongside the Stage 5A baseline.
- Includes the Wilcoxon signed-rank test results comparing DANN with the PyTorch baseline.
- Applies predefined decision criteria combining:
  - Reduction in subject identity leakage.
  - Improvement in LOSO fatigue classification.
  - Statistical significance.
- Determines the overall causal verdict regarding the effectiveness of adversarial subject disentanglement.
- Saves the complete comparison table as a CSV file together with the generated figures.

**Key results:**
- Mean LOSO accuracy:
  - **Scikit-learn MLP:** **41.60%**
  - **PyTorch baseline:** **46.58%**
  - **DANN:** **49.31%**
- DANN improvement:
  - **+2.73 percentage points** over the PyTorch baseline.
  - **+7.71 percentage points** over the original scikit-learn MLP.
- Subject probe accuracy:
  - Stage 5A: **100.00%**
  - Post-DANN: **99.31%**
  - Reduction: **0.69 percentage points**
- Wilcoxon signed-rank test:
  - **p = 0.0798** (not statistically significant)
- Final causal verdict: **GRL did not fully disentangle subject identity.**

**Key outputs:**
- `stage5B_summary.csv`
- `stage5B_dann_results.png`
- `stage5B_lambda_schedule.png`

**Conclusion:**
- Stage 5B demonstrates that adversarial training produced a modest improvement in cross-subject fatigue classification, increasing the mean LOSO accuracy from **46.58%** to **49.31%**. However, this improvement was **not statistically significant** and remained below the predefined threshold for establishing a strong causal effect.
- More importantly, the post-DANN subject probe continued to identify subjects with **99.31% accuracy**, indicating that the learned representations still retained nearly all subject-specific information despite adversarial training.
- Consequently, the Domain-Adversarial Neural Network **did not successfully achieve its intended mechanistic objective of learning subject-invariant representations**, preventing a causal attribution of the observed performance changes to the removal of subject identity information.
- Overall, the evidence from Stage 5B is **inconclusive with respect to the causal hypothesis**. While adversarial training yielded small performance gains, the persistence of strong subject identity encoding suggests that the current DANN configuration was insufficient to disentangle subject-specific features. These findings motivate the subsequent analyses in **Stage 5C**, which investigate alternative sources of poor cross-subject generalization beyond subject identity leakage.
