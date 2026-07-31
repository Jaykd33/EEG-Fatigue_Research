## Stage 5RC — Random Baseline Control

**Purpose:** Determines whether the strong subject identity leakage observed in Stage 5A originates from the **raw EEG feature space** or is **learned by the MLP during training** by evaluating multiple control representations using the identical subject identity probe protocol.

**What this stage does:**
- Evaluates subject identity separability using three control feature representations:
  - **Raw scaled DE-LDS features (85-dimensional)** to measure subject information inherently present in the input.
  - **Random network representations (64-dimensional)** to assess whether the network architecture alone induces subject separability without learning.
  - **PCA-reduced representations (64-dimensional)** to determine whether subject identity is preserved within the dominant linear variance of the input space.
- Applies the **same window-level subject identity probe** used in Stage 5A to each representation:
  - 10 repeated stratified train/test splits (80/20).
  - Multinomial Logistic Regression classifier.
  - Training-only feature standardization.
- Compares the resulting probe accuracies with:
  - Chance-level performance.
  - Stage 5A learned MLP representations.
  - Stage 5B post-DANN representations.
- Uses these comparisons to identify whether subject identity leakage is primarily caused by the input features, the learned representations, or both.

**Key outputs:**
- Probe accuracy for:
  - Raw scaled features.
  - Random network representations.
  - PCA-64 representations.
- Direct comparison against:
  - Chance baseline.
  - Stage 5A MLP representations.
  - Stage 5B post-DANN representations.

**Conclusion:**
- This stage establishes the experimental control required to interpret the findings of Stages 5A and 5B. By evaluating identical subject identity probes on untrained and non-learned feature representations, it distinguishes **intrinsic subject information present in the input data** from **subject-specific information introduced or amplified during model training**, thereby providing a causal interpretation of the observed representation leakage.

- ### Block 5RC.1 — Imports and Configuration

**Purpose:** Imports the required libraries and configures the Random Baseline Control experiment, ensuring that all control representations are evaluated using the identical subject identity probe protocol established in Stage 5A.

**What this block does:**
- Imports the scientific computing, visualization, machine learning, and statistical analysis libraries required for the control experiments.
- Defines the probe protocol parameters to exactly match Stage 5A:
  - 10 repeated stratified train/test splits.
  - 80/20 train-test ratio.
  - Fixed random seed (42).
- Specifies the representation dimensionalities:
  - Raw DE-LDS features (**85 dimensions**).
  - Control representations (**64 dimensions**), matching the MLP penultimate-layer representations.
- Aggregates all EEG windows, fatigue labels, and subject identifiers across the dataset.
- Fits a global `StandardScaler` to the complete feature set and produces standardized input features for the control analyses.
- Encodes subject identifiers into integer class labels and computes the theoretical chance-level subject classification accuracy.

**Key outputs:**
- Total EEG windows: **20,355**
- Number of subjects: **21**
- Chance accuracy: **4.76%**
- Probe protocol:
  - **10× StratifiedShuffleSplit**
  - **80/20 train-test split**
  - **Random seed = 42**
- Raw feature dimensionality: **85**
- Control representation dimensionality: **64**

**Conclusion:**
- The Random Baseline Control experiment was successfully configured using the same preprocessing and subject identity probe settings employed in Stage 5A. By matching the representation dimensionality and evaluation protocol, this configuration enables a fair and directly comparable assessment of whether subject identity is inherently present in the raw EEG feature space before model training.

- ### Block 5RC.2 — Shared Subject Identity Probe Function

**Purpose:** Implements a reusable subject identity probe function that applies the identical evaluation protocol from Stage 5A to any feature representation, ensuring fair and consistent comparison across all Random Baseline Control experiments.

**What this block does:**
- Defines the `run_subject_probe()` function for evaluating subject identity separability from any feature matrix.
- Uses the same protocol established in Stage 5A:
  - **10 repeated stratified train/test splits (80/20)**.
  - Train-only feature standardization within each split.
  - Multinomial Logistic Regression classifier (`lbfgs`, `max_iter = 2000`, `C = 1.0`).
- Computes the subject classification accuracy for every split.
- Calculates summary statistics, including:
  - Mean accuracy.
  - Standard deviation.
  - Standard error.
  - One-sample t-test against chance-level accuracy.
  - Ratio above chance performance.
- Classifies the degree of subject identity leakage into predefined tiers (**NONE**, **WEAK**, **MODERATE**, or **STRONG**).
- Returns all probe statistics in a structured dictionary for subsequent comparison across control conditions.

**Key outputs:**
- `run_subject_probe()`
- Probe configuration:
  - Number of splits: **10**
  - Test fraction: **20%**
  - Random seed: **42**
  - Logistic Regression:
    - Solver: **lbfgs**
    - Maximum iterations: **2000**
    - Regularization parameter: **C = 1.0**

**Conclusion:**
- A standardized subject identity probe was successfully implemented for the Random Baseline Control analysis. By centralizing the evaluation procedure into a single reusable function that exactly matches the Stage 5A protocol, this block ensures that all control representations are assessed under identical experimental conditions, enabling valid and unbiased comparisons of subject identity leakage.
### Block 5RC.3 — Control 1: Subject Probe on Raw Scaled Features

**Purpose:** Evaluates whether subject identity is directly encoded in the raw 85-dimensional DE-LDS EEG features before any neural network training or feature learning.

**What this block does:**
- Uses the globally standardized **85-dimensional DE-LDS feature vectors** as the representation for analysis.
- Applies the identical subject identity probe protocol from Stage 5A:
  - **10 repeated stratified train/test splits (80/20)**.
  - Train-only feature standardization within each split.
  - Multinomial Logistic Regression classifier.
- Computes subject classification accuracy across all probe splits.
- Quantifies the degree of subject separability present in the raw EEG feature space.

**Key results:**
- Feature dimensionality: **85**
- Total EEG windows: **20,355**
- Probe protocol:
  - **16,284 training windows / 4,071 testing windows per split**
- Mean probe accuracy: **100.00% ± 0.00%**
- Chance accuracy: **4.76%**
- Performance above chance: **21.0×**
- One-sample t-test:
  - **t = ∞**
  - **p < 1 × 10⁻¹⁶** (reported as 0.0000e+00)
- Leakage tier: **STRONG**

**Conclusion:**
- The raw DE-LDS feature space alone enables **perfect subject identification (100% accuracy)** without any learned transformation. This demonstrates that subject identity is already linearly encoded in the input EEG features prior to model training. Consequently, the strong subject identity observed in the Stage 5A learned representations cannot be attributed solely to the MLP; instead, it primarily reflects information inherently present in the raw feature space. This finding indicates that subject identity leakage is fundamentally an **input-space property**, suggesting that feature engineering or subject-normalization techniques may be more effective than representation-level adversarial learning alone for mitigating subject-specific bias.

- ### Block 5RC.4 — Control 2: Subject Probe on Random Network Features

**Purpose:** Evaluates whether the MLP architecture itself, without any training, produces subject-discriminative representations by probing the penultimate-layer activations of a randomly initialized network.

**What this block does:**
- Implements a randomly initialized MLP using **Xavier uniform initialization**, matching the architecture used in Stage 1.
- Projects the standardized **85-dimensional DE-LDS features** through the untrained network to obtain **64-dimensional penultimate-layer representations**.
- Applies ReLU activation after each hidden layer, identical to the trained MLP architecture.
- Executes the identical subject identity probe protocol from Stage 5A:
  - **10 repeated stratified train/test splits (80/20)**.
  - Train-only feature standardization within each split.
  - Multinomial Logistic Regression classifier.
- Measures how well subject identity can be predicted from the random network representations.

**Key results:**
- Network architecture: **85 → 256 → 128 → 64**
- Representation dimensionality: **64**
- Representation matrix: **(20,355, 64)**
- Mean probe accuracy: **100.00% ± 0.01%**
- Chance accuracy: **4.76%**
- Performance above chance: **21.0×**
- One-sample t-test:
  - **t = 19,384.714**
  - **p = 1.32 × 10⁻³⁵**
- Leakage tier: **STRONG**

**Conclusion:**
- The randomly initialized MLP produced representations that enabled **near-perfect subject identification (≈100%)**, despite having **no learned parameters**. This demonstrates that the network architecture alone does not create subject-discriminative structure; rather, it preserves the highly separable subject information already present in the raw DE-LDS features. Together with the results of Block 5RC.3, this finding provides strong evidence that the subject identity leakage observed in Stage 5A originates from the **input feature space**, not from the learning process itself.

- ### Block 5RC.5 — Control 3: Subject Probe on PCA-Reduced Features

**Purpose:** Evaluates whether subject identity is preserved within the dominant linear variance of the raw EEG feature space by probing the top 64 principal components of the standardized DE-LDS features.

**What this block does:**
- Applies **Principal Component Analysis (PCA)** to the globally standardized 85-dimensional DE-LDS feature vectors.
- Reduces the feature space to **64 principal components**, matching the dimensionality of the Stage 5A MLP representations.
- Measures the proportion of total input variance retained after dimensionality reduction.
- Executes the identical subject identity probe protocol from Stage 5A:
  - **10 repeated stratified train/test splits (80/20)**.
  - Train-only feature standardization within each split.
  - Multinomial Logistic Regression classifier.
- Quantifies how well subject identity can be predicted from the PCA representations.

**Key results:**
- Input features: **20,355 windows × 85 features**
- PCA representation dimensionality: **64**
- Variance explained by the top 64 components: **99.9%**
- Mean probe accuracy: **100.00% ± 0.00%**
- Chance accuracy: **4.76%**
- Performance above chance: **21.0×**
- One-sample t-test:
  - **t = ∞**
  - **p < 1 × 10⁻¹⁶** (reported as 0.0000e+00)
- Leakage tier: **STRONG**

**Conclusion:**
- The PCA-reduced representations achieved **perfect subject identification (100%)** while retaining **99.9%** of the variance in the original feature space. This demonstrates that subject-discriminative information is concentrated within the dominant linear components of the raw DE-LDS features and is preserved almost entirely after linear dimensionality reduction. Combined with the results from the raw feature and random network controls, these findings confirm that the observed subject identity leakage is an inherent property of the input feature space rather than a consequence of model training or nonlinear feature learning.

- ### Block 5RC.6 — Quantitative Comparison of Subject Identity Leakage

**Purpose:** Consolidates the subject identity probe results from all control experiments and previously evaluated representations into a single comparison table using the identical evaluation protocol.

**What this block does:**
- Collects the probe statistics from all Random Baseline Control experiments:
  - Raw scaled features.
  - Random network representations.
  - PCA-reduced representations.
- Includes the trained MLP representation from **Stage 5A** for direct comparison.
- Attempts to include the post-DANN representation from **Stage 5B** if available; otherwise reports it as unavailable.
- Summarizes the mean probe accuracy, variability, statistical significance, leakage strength, and performance relative to chance for every representation.

**Key results:**

| Representation | Feature Dim. | Mean Probe Accuracy | Ratio vs Chance | Leakage Tier |
|---------------|-------------:|--------------------:|----------------:|:------------|
| Chance baseline | — | **4.76%** | **1.00×** | BASELINE |
| Raw scaled features | 85 | **100.00%** | **21.00×** | STRONG |
| Random network features | 64 | **100.00%** | **21.00×** | STRONG |
| PCA features | 64 | **100.00%** | **21.00×** | STRONG |
| Trained MLP representations | 64 | **100.00%** | **21.00×** | STRONG |
| Post-DANN representations | 64 | **N/A** | **N/A** | Stage 5B not available |

- Chance accuracy: **4.76%**

**Conclusion:**
- All evaluated representations—including the **raw EEG features**, **randomly initialized network outputs**, **PCA-reduced features**, and **trained MLP representations**—achieved essentially **100% subject identification accuracy**, representing approximately **21×** the theoretical chance level. The consistency of these results across both learned and non-learned representations demonstrates that subject identity is already fully encoded within the original DE-LDS feature space. Consequently, the strong subject identity leakage observed in the trained MLP cannot be attributed to the learning process itself but instead reflects an intrinsic property of the input features.

- ### Block 5RC.7 — t-SNE Visualization: Raw Features vs Trained MLP Representations

**Purpose:** Provides a qualitative comparison of the latent structure of the raw EEG feature space and the trained MLP representations by visualizing both with t-SNE, allowing subject identity and fatigue class distributions to be examined side by side.

**What this block does:**
- Randomly samples up to **200 EEG windows per subject** to ensure balanced visualization.
- Uses the same subset of windows for both representations to enable a fair comparison.
- Computes separate **2-dimensional t-SNE embeddings** for:
  - Raw standardized DE-LDS features (85 dimensions).
  - Trained MLP penultimate-layer representations (64 dimensions).
- Generates four visualization panels:
  - Raw features coloured by **subject ID**.
  - Raw features coloured by **fatigue class**.
  - Trained MLP representations coloured by **subject ID**.
  - Trained MLP representations coloured by **fatigue class**.
- Saves the complete comparison figure for inclusion in the dissertation.

**Key outputs:**
- Maximum samples per subject: **200**
- Two t-SNE embeddings generated:
  - Raw feature space.
  - Trained MLP representation space.
- Four-panel comparison figure produced.
- Output file:
  - `stage5RC_tsne_comparison.png`

**Conclusion:**
- The t-SNE visualizations provide a qualitative comparison between the raw EEG feature space and the learned MLP representation space using identical samples. Together with the quantitative probe results from Blocks 5RC.3–5RC.6, these visualizations facilitate assessment of whether the trained MLP merely preserves the strong subject-specific structure already present in the raw features or substantially alters the organization of the latent space while retaining subject separability.

- ### Block 5RC.9 — Interpretation and Verdict

**Purpose:** Interprets the results of all Random Baseline Control experiments to determine whether subject identity leakage originates from the input EEG feature space or is introduced during model training.

**What this block does:**
- Summarizes the subject identity probe accuracies for:
  - Chance baseline.
  - Raw scaled DE-LDS features.
  - Random network representations.
  - PCA-reduced representations.
  - Trained MLP representations.
  - Post-DANN representations (if available).
- Compares the probe accuracies against predefined interpretation criteria.
- Determines whether subject identity leakage is primarily:
  - Input-space driven.
  - Training-induced.
  - Amplified during learning.
- Explains the implications of the observed results for representation learning and subject-invariant EEG modelling.
- Saves the quantitative comparison table and visualization outputs generated throughout Stage 5RC.

**Key results:**
- Chance accuracy: **4.76%**
- Raw scaled features: **100.00% (21.0× chance)**
- Random network representations: **100.00% (21.0× chance)**
- PCA-reduced representations: **100.00% (21.0× chance)**
- Trained MLP representations: **100.00% (21.0× chance)**
- Post-DANN representations: **Not available**
- Final interpretation:
  - **Subject identity is primarily an input-space phenomenon.**
- Output files generated:
  - `stage5RC_comparison.csv`
  - `stage5RC_tsne_comparison.png`
  - `stage5RC_probe_comparison_bar.png`

**Conclusion:**
- The Random Baseline Control analysis demonstrates that subject identity is **fully encoded within the original DE-LDS EEG features before any model training occurs**. Raw features, random network representations, PCA-reduced features, and trained MLP representations all achieved **100% subject identification accuracy**, indicating that neither nonlinear learning nor network optimization is responsible for creating subject-discriminative information. Instead, the trained MLP simply preserves an already perfectly separable input structure. These findings establish that the dominant source of subject identity leakage is the **input feature space itself**, implying that future mitigation strategies should prioritize input-level preprocessing or subject-normalization methods rather than relying solely on representation-level adversarial learning.
- 
