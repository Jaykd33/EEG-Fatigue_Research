# Stage 5RC — Random Baseline Control (BiLSTM)

**Purpose:** Determines whether the subject identity leakage observed in the trained BiLSTM representations originates from the raw EEG feature space, the BiLSTM architecture itself, or the supervised training process.

**What this stage does:**
- Evaluates subject identity directly from the standardized **85-dimensional DE-LDS EEG features** before any model is applied.
- Extracts **64-dimensional representations from an untrained BiLSTM** with randomly initialized weights to determine whether the architecture alone preserves subject-discriminative information.
- Generates **64-dimensional PCA representations** of the raw EEG features to examine whether subject identity is contained within the dominant linear variance directions.
- Applies the **identical subject identity probe protocol from Stage 5A** to all control representations, ensuring direct quantitative comparison with the trained BiLSTM representations.
- Compares the probe accuracies of:
  - Raw EEG features.
  - Random BiLSTM representations.
  - PCA representations.
  - Trained BiLSTM representations (Stage 5A).
  - Post-DANN representations (Stage 5B), where available.
- Produces quantitative comparisons and visualizations to identify the origin of subject identity leakage.

**Key outputs:**
- Subject identity probe results for three control representations:
  - Raw scaled EEG features (85 dimensions).
  - Random BiLSTM representations (64 dimensions).
  - PCA-reduced representations (64 dimensions).
- Comparative analysis with Stage 5A and Stage 5B subject identity probes.
- Quantitative comparison table.
- t-SNE visualization comparing raw and trained representation spaces.
- Final interpretation identifying the primary source of subject identity leakage.

**Conclusion:**
- This stage provides a causal control experiment for the BiLSTM model by distinguishing whether subject identity leakage is an intrinsic property of the input EEG features or emerges through representation learning. Using the same evaluation protocol as Stage 5A ensures that all measured probe accuracies are directly comparable, enabling a rigorous interpretation of the source of subject-specific information in the learned representations.

- ### Block 5RC.1 — Imports and Global Feature Matrix Assembly

**Purpose:** Imports the required libraries and constructs a unified raw EEG feature matrix from the BiLSTM data pipeline, ensuring that all control analyses use the same window ordering and preprocessing as the Stage 5A representations.

**What this block does:**
- Imports the scientific computing, visualization, machine learning, and statistical analysis libraries required for the Random Baseline Control experiments.
- Defines the subject identity probe parameters identical to Stage 5A:
  - **10 repeated stratified train/test splits**.
  - **80/20 train-test ratio**.
  - **Random seed = 42**.
- Traverses the nested `features_dict` and `labels_dict` structures to assemble:
  - A global raw EEG feature matrix.
  - Fatigue class labels.
  - Subject identity labels.
- Verifies that the assembled feature, subject, and fatigue label ordering exactly matches the Stage 5A representation arrays.
- Fits a global `StandardScaler` to the complete raw feature matrix and generates standardized EEG features for subsequent control analyses.
- Encodes subject identifiers into integer class labels and computes the theoretical chance-level subject classification accuracy.

**Key outputs:**
- Ordering consistency with Stage 5A: **PASSED**
- Raw feature matrix: **(20,355, 85)**
- Number of subjects: **21**
- Total EEG windows: **20,355**
- Chance accuracy: **4.76%**
- Control representation dimensionality: **64**

**Conclusion:**
- The global feature matrix was successfully reconstructed from the BiLSTM data structures while preserving the exact window ordering used in Stage 5A. The successful consistency checks confirm that all subsequent control experiments operate on data directly aligned with the extracted BiLSTM representations, enabling fair and valid comparisons throughout Stage 5RC.

- ### Block 5RC.2 — Shared Subject Identity Probe Function

**Purpose:** Implements a reusable subject identity probe function that applies the identical evaluation protocol from Stage 5A to any feature representation, ensuring consistent and unbiased comparison across all BiLSTM Random Baseline Control experiments.

**What this block does:**
- Defines the `run_subject_probe()` function for evaluating subject identity from any feature representation.
- Uses the same probe protocol established in Stage 5A:
  - **10 repeated stratified train/test splits (80/20)**.
  - Train-only feature standardization within each split.
  - Multinomial Logistic Regression classifier (`lbfgs`, `max_iter = 2000`, `C = 1.0`).
- Computes the subject classification accuracy for every probe split.
- Calculates summary statistics, including:
  - Mean accuracy.
  - Standard deviation.
  - Standard error.
  - One-sample t-test against chance-level accuracy.
  - Ratio above chance performance.
- Categorizes the degree of subject identity leakage into predefined tiers (**NONE**, **WEAK**, **MODERATE**, or **STRONG**).
- Returns all probe statistics in a structured dictionary for use in subsequent comparisons.

**Key outputs:**
- `run_subject_probe()`
- Probe configuration:
  - Number of splits: **10**
  - Train/Test ratio: **80/20**
  - Random seed: **42**
  - Logistic Regression:
    - Solver: **lbfgs**
    - Maximum iterations: **2000**
    - Regularization parameter: **C = 1.0**

**Conclusion:**
- A standardized subject identity probe was successfully implemented for the BiLSTM Random Baseline Control analysis. By reusing the identical evaluation procedure from Stage 5A, this function ensures that every control representation is assessed under the same experimental conditions, allowing direct and statistically valid comparison of subject identity leakage across raw features, random BiLSTM representations, PCA representations, and the trained BiLSTM representations.

### Block 5RC.3 — Control 1: Subject Probe on Raw Scaled Features

**Purpose:** Evaluates whether subject identity is directly encoded in the raw 85-dimensional DE-LDS EEG features before any feature learning or BiLSTM processing.

**What this block does:**
- Uses the globally standardized **85-dimensional DE-LDS feature vectors** as the input representation.
- Applies the identical subject identity probe protocol from Stage 5A:
  - **10 repeated stratified train/test splits (80/20)**.
  - Train-only feature standardization within each split.
  - Multinomial Logistic Regression classifier.
- Computes subject classification accuracy across all probe splits.
- Establishes the baseline level of subject separability inherent in the raw EEG feature space.

**Key results:**
- Feature dimensionality: **85**
- Total EEG windows: **20,355**
- Probe protocol:
  - **16,284 training windows / 4,071 testing windows per split**
- Mean probe accuracy: **97.96% ± 0.17%**
- Chance accuracy: **4.76%**
- Performance above chance: **20.57×**
- One-sample t-test:
  - **t = 1678.889**
  - **p = 4.80 × 10⁻²⁶**
- Leakage tier: **STRONG**

**Conclusion:**
- The raw DE-LDS feature space alone achieved **97.96% subject identification accuracy**, demonstrating that subject identity is already highly separable before any BiLSTM processing or supervised learning. This strong baseline indicates that the EEG input features inherently contain substantial subject-specific information. Consequently, any subject identity observed in the learned BiLSTM representations must be interpreted relative to this pre-existing input-space structure rather than being attributed solely to the learning process.

- ### Block 5RC.4 — Control 2: Subject Probe on Random BiLSTM Representations

**Purpose:** Evaluates whether an untrained BiLSTM architecture preserves subject-discriminative information by probing the penultimate-layer representations generated from randomly initialized network weights.

**What this block does:**
- Instantiates an **untrained BiLSTMFatigueClassifier** with reproducible random initialization.
- Executes the model in **evaluation mode** without gradient computation.
- Registers a forward hook on **`classifier[1]` (ReLU)**, matching the representation extraction point used in Stage 5A.
- Processes every EEG session through the random BiLSTM to obtain **64-dimensional window-level representations**.
- Verifies that the extracted representation matrix matches the expected dimensions.
- Applies the identical subject identity probe protocol from Stage 5A:
  - **10 repeated stratified train/test splits (80/20)**.
  - Train-only feature standardization within each split.
  - Multinomial Logistic Regression classifier.
- Measures subject identification accuracy from the random BiLSTM representations.

**Key results:**
- Random BiLSTM representation matrix: **(20,355, 64)**
- Representation dimension verification: **PASSED**
- Mean probe accuracy: **95.63% ± 0.19%**
- Chance accuracy: **4.76%**
- Performance above chance: **20.08×**
- One-sample t-test:
  - **t = 1423.214**
  - **p = 2.13 × 10⁻²⁵**
- Leakage tier: **STRONG**

**Conclusion:**
- The untrained BiLSTM achieved **95.63% subject identification accuracy**, demonstrating that the BiLSTM architecture preserves a substantial amount of the subject-specific information already present in the raw EEG features, even without any learning. However, the probe accuracy remains slightly lower than the raw feature baseline (**97.96%**), indicating that the random recurrent transformation does not amplify subject identity but instead retains most of the intrinsic subject-discriminative structure. This suggests that the strong subject identity observed in the trained BiLSTM representations primarily originates from the input feature space rather than being created by the network architecture alone.

- ### Block 5RC.5 — Control 3: Subject Probe on PCA Representations

**Purpose:** Evaluates whether subject identity is preserved within the dominant linear variance of the raw EEG feature space by probing the top 64 principal components of the standardized DE-LDS features.

**What this block does:**
- Applies **Principal Component Analysis (PCA)** to the globally standardized **85-dimensional DE-LDS feature vectors**.
- Reduces the feature space to **64 principal components**, matching the dimensionality of the BiLSTM penultimate-layer representations from Stage 5A.
- Computes the proportion of total variance retained after dimensionality reduction.
- Applies the identical subject identity probe protocol from Stage 5A:
  - **10 repeated stratified train/test splits (80/20)**.
  - Train-only feature standardization within each split.
  - Multinomial Logistic Regression classifier.
- Measures the degree of subject separability present in the PCA representations.

**Key results:**
- Input feature matrix: **20,355 windows × 85 features**
- PCA representation dimensionality: **64**
- Variance explained: **100.0%**
- Mean probe accuracy: **99.58% ± 0.12%**
- Chance accuracy: **4.76%**
- Performance above chance: **20.91×**
- One-sample t-test:
  - **t = 2375.631**
  - **p = 2.11 × 10⁻²⁷**
- Leakage tier: **STRONG**

**Conclusion:**
- The PCA-reduced representations achieved **99.58% subject identification accuracy** while retaining virtually **100%** of the variance in the original feature space. This indicates that subject-specific information is concentrated within the dominant linear components of the DE-LDS features and is largely preserved after dimensionality reduction. Compared with the raw feature baseline (**97.96%**) and the random BiLSTM representations (**95.63%**), PCA retained the highest level of subject separability, demonstrating that the subject identity signal is primarily a property of the input feature space rather than a consequence of nonlinear representation learning.

- ### Block 5RC.6 — Quantitative Comparison of Subject Identity Leakage

**Purpose:** Consolidates the subject identity probe results from all Random Baseline Control experiments together with the trained BiLSTM and post-DANN representations, enabling direct comparison under an identical evaluation protocol.

**What this block does:**
- Combines the probe results from:
  - Raw scaled EEG features.
  - Random BiLSTM representations.
  - PCA-reduced representations.
  - Trained BiLSTM representations (Stage 5A).
  - Post-DANN BiLSTM representations (Stage 5B).
- Includes the theoretical chance-level baseline for reference.
- Summarizes the mean probe accuracy, variability, statistical significance, leakage strength, and performance relative to chance for every representation.
- Produces a unified comparison table for interpreting the source of subject identity leakage.

**Key results:**

| Representation | Feature Dim. | Mean Probe Accuracy | Ratio vs Chance | Leakage Tier |
|---------------|-------------:|--------------------:|----------------:|:------------|
| Chance baseline | — | **4.76%** | **1.00×** | BASELINE |
| Raw scaled features | 85 | **97.96% ± 0.17%** | **20.57×** | STRONG |
| Random BiLSTM representations | 64 | **95.63% ± 0.19%** | **20.08×** | STRONG |
| PCA representations | 64 | **99.58% ± 0.12%** | **20.91×** | STRONG |
| Trained BiLSTM representations | 64 | **76.37% ± 0.37%** | **16.04×** | STRONG |
| Post-DANN BiLSTM representations | 64 | **91.56% ± 0.35%** | **19.23×** | STRONG |

- Chance accuracy: **4.76%**

**Conclusion:**
- All evaluated representations exhibited **strong subject identity leakage**, substantially exceeding the theoretical chance level. Among them, the **PCA representations achieved the highest probe accuracy (99.58%)**, followed by the **raw EEG features (97.96%)** and the **random BiLSTM representations (95.63%)**, indicating that subject-specific information is already highly separable within the input feature space. In contrast, the **trained BiLSTM representations (76.37%)** showed considerably lower subject separability, suggesting that supervised training partially suppresses subject-specific information rather than amplifying it. The **post-DANN representations (91.56%)** retained stronger subject identity than the trained BiLSTM baseline, indicating that, in this experiment, adversarial training did not further reduce subject-specific information.

- ### Block 5RC.7 — t-SNE Visualization: Raw Features vs Trained BiLSTM Representations

**Purpose:** Generates a qualitative comparison of the geometric structure of the raw EEG feature space and the trained BiLSTM representation space using t-SNE projections coloured by both subject identity and fatigue class.

**What this block does:**
- Randomly samples up to **200 windows per subject**, using the same subset for all visualizations.
- Applies t-SNE separately to:
  - The **85-dimensional standardized raw DE-LDS features**.
  - The **64-dimensional trained BiLSTM representations** extracted in Stage 5A.
- Produces a four-panel visualization showing:
  - Raw features coloured by subject ID.
  - Raw features coloured by fatigue class.
  - Trained BiLSTM representations coloured by subject ID.
  - Trained BiLSTM representations coloured by fatigue class.
- Saves the generated figure for inclusion in the dissertation.

**Key outputs:**
- t-SNE projection of raw scaled EEG features.
- t-SNE projection of trained BiLSTM representations.
- Four-panel comparison figure:
  - **`bilstm_stage5RC_tsne_comparison.png`**
- Identical sampled windows used for both representation spaces to ensure a fair visual comparison.

**Conclusion:**
- A standardized t-SNE comparison was successfully generated for both the raw feature space and the trained BiLSTM representation space using identical sampled EEG windows. The resulting visualizations provide qualitative evidence of how subject identity and fatigue information are organized before and after BiLSTM representation learning, complementing the quantitative subject identity probe results presented in the preceding blocks.

- ### Block 5RC.8 — Summary Bar Chart of Subject Identity Probe Performance

**Purpose:** Visualizes and compares the subject identity probe accuracy across all evaluated representations using a unified bar chart with variability estimates and reference thresholds.

**What this block does:**
- Extracts the quantitative probe results from the comparison table.
- Excludes the chance baseline from the plotted bars while retaining it as a reference line.
- Plots the mean subject probe accuracy for:
  - Raw scaled features.
  - Random BiLSTM representations.
  - PCA representations.
  - Trained BiLSTM representations.
  - Post-DANN BiLSTM representations.
- Displays **±1 standard deviation** as error bars.
- Adds horizontal reference lines for:
  - Chance-level accuracy.
  - The **3× chance** leakage threshold.
- Saves the summary visualization for reporting.

**Key outputs:**
- Bar chart comparing subject probe accuracy across all evaluated representations.
- Error bars representing **±1 standard deviation**.
- Reference lines for chance accuracy (**4.76%**) and **3× chance threshold (14.29%)**.
- Saved figure:
  - **`bilstm_stage5RC_probe_comparison_bar.png`**

**Conclusion:**
- A consolidated visualization of subject identity leakage was successfully generated across all representation types. The chart highlights that every evaluated representation substantially exceeded the chance-level baseline, with **PCA representations exhibiting the highest subject separability**, followed by the **raw EEG features**, **random BiLSTM representations**, **post-DANN BiLSTM representations**, and finally the **trained BiLSTM representations**, providing a clear visual summary of the quantitative probe results obtained in Stage 5RC.

- ### Block 5RC.9 — Interpretation and Final Verdict

**Purpose:** Interprets the quantitative results from all control experiments to determine whether the subject identity leakage observed in the trained BiLSTM representations originates from the input feature space, the BiLSTM architecture, or the supervised training process.

**What this block does:**
- Summarizes the subject probe accuracy for:
  - Raw scaled features.
  - Random BiLSTM representations.
  - PCA representations.
  - Trained BiLSTM representations (Stage 5A).
  - Post-DANN BiLSTM representations (Stage 5B).
- Applies predefined interpretation rules to identify the primary source of subject identity leakage.
- Evaluates whether:
  - Subject identity is inherent in the input features.
  - The BiLSTM architecture amplifies subject-specific information.
  - Supervised training introduces additional subject identity leakage.
- Generates a paper-ready interpretation of the findings.
- Saves the quantitative comparison table and all Stage 5RC visualizations.

**Key results:**
- Raw scaled features: **97.96%**
- Random BiLSTM representations: **95.63%**
- PCA representations: **99.58%**
- Trained BiLSTM representations: **76.37%**
- Post-DANN BiLSTM representations: **91.56%**
- Final interpretation: **Subject identity is primarily an INPUT-SPACE phenomenon.**
- Saved outputs:
  - `bilstm_stage5RC_comparison.csv`
  - `bilstm_stage5RC_tsne_comparison.png`
  - `bilstm_stage5RC_probe_comparison_bar.png`

**Conclusion:**
- The control experiments demonstrate that subject identity is predominantly encoded within the original DE-LDS EEG feature space rather than being created by the BiLSTM architecture or the supervised learning process. The raw features (**97.96%**) and PCA representations (**99.58%**) exhibited even stronger subject separability than the trained BiLSTM representations (**76.37%**), while the random BiLSTM also retained high subject discrimination (**95.63%**). These findings indicate that the observed identity leakage originates primarily from intrinsic physiological characteristics of the input features. Consequently, improving subject invariance is likely to require input-level strategies, such as feature alignment or normalization, in addition to representation-level learning approaches.
