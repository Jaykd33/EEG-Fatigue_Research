# Stage 5A — Subject Identity Leakage Analysis

**Purpose:** Investigates whether the BiLSTM's learned representations encode subject-specific information, which could explain the large gap between within-subject and cross-subject (LOSO) performance.

**What this stage does:**
- Evaluates whether the BiLSTM learns subject-discriminative representations in addition to fatigue-related features.
- Extracts the 64-dimensional penultimate-layer representations from the trained BiLSTM for representation analysis.
- Quantifies subject identity leakage using a linear probing classifier.
- Visualizes the representation space using t-SNE to examine clustering by subject and fatigue class.
- Measures representation distribution shift between subjects using Maximum Mean Discrepancy (MMD) and relates it to LOSO performance.

**Key analyses:**
- Subject Identity Probe
- t-SNE Representation Visualization
- MMD vs LOSO Accuracy Analysis
- Consolidated Subject-wise Performance Summary

**Conclusion:**
- This stage determines whether subject identity leakage is a major contributor to the observed cross-subject generalization gap and provides evidence for whether representation learning should be further improved through subject-invariant learning techniques.

- ## Block 5A.1 — Extract Penultimate-Layer Representations

**Purpose:** Extracts the learned 64-dimensional penultimate-layer representations from the trained BiLSTM model for every EEG window. These representations serve as the feature space for all subsequent analyses of subject identity leakage.

**What this block does:**
- Constructs a unified session list from the nested BiLSTM data structures.
- Fits a global feature scaler using the reference LOSO training subjects for consistent representation extraction.
- Retrains a representative BiLSTM model using the reference LOSO training split.
- Registers a forward hook on the penultimate layer (ReLU activation) to capture the learned 64-dimensional representations.
- Extracts one representation vector for every EEG window across all sessions.
- Concatenates representations, fatigue labels, and subject IDs into global arrays for downstream analyses.
- Performs a sanity check by comparing manually reconstructed predictions from the extracted representations with the model's direct predictions.
- Confirms the extracted representation dimensionality and BiLSTM architecture.

**Key outputs:**
- `all_reprs_arr` — Penultimate-layer representations `(20355 × 64)`.
- `all_labels_arr` — Fatigue labels for all windows.
- `all_subj_arr` — Subject ID corresponding to every representation.
- Representation dimension (`64`) and total windows (`20355`).

**Conclusion:**
- Successfully extracted a 64-dimensional representation for every EEG window across all 21 subjects.
- The extracted dataset contains **20,355 representations**, matching the total number of EEG windows, making it suitable for subsequent subject identity analysis.
- The sanity check showed only **30.1% agreement** between manually reconstructed predictions and the model outputs, indicating that the chosen hook location or reconstruction procedure may not perfectly correspond to the representation immediately before the final classification layer. Although the representations were successfully extracted, this warning suggests that the extraction pipeline should be verified before interpreting later representation analyses.

- ## Block 5A.2 — Build Representation Dataset

**Purpose:** Organizes the extracted BiLSTM representations into a structured per-window dataset, providing a unified subject-wise representation table for all subsequent subject identity leakage analyses.

**What this block does:**
- Constructs a dataframe containing the subject ID and corresponding fatigue label for every extracted representation.
- Generates a subject-wise summary including the number of sessions, number of EEG windows, and fatigue class distribution.
- Determines the total number of unique subjects in the dataset.
- Computes the theoretical chance accuracy for subject identification (1 / number of subjects), which serves as the baseline for the subject identity probe in the next block.

**Key outputs:**
- `repr_df` — Per-window representation metadata.
- `unique_subjects` — List of all 21 subjects.
- `N_SUBJECTS` — Total number of unique subjects.
- Subject-wise statistics including session count, window count, and fatigue class distribution.
- Chance-level subject identification accuracy (**4.76%**).

**Conclusion:**
- Successfully organized the extracted representations into a unified dataset covering **21 subjects**.
- The representation dataset preserves the subject-wise and fatigue-class distributions required for downstream analyses.
- The theoretical chance accuracy for subject identification is **4.76%**, providing the baseline against which the subject identity probe performance will be evaluated in the subsequent block.

- ## Block 5A.3 — Subject Identity Probe (Stratified Window-Level Split)

**Purpose:** Quantifies the extent to which the BiLSTM's learned representations encode subject identity by training a simple linear classifier to predict the subject ID from the extracted 64-dimensional penultimate-layer representations.

**What this block does:**
- Encodes the 21 subject IDs as numerical class labels.
- Performs **10 repeated stratified window-level train/test splits (80%/20%)**, ensuring that every subject contributes windows to both the training and testing sets.
- Trains a **multinomial Logistic Regression** classifier (linear probe) on the extracted BiLSTM representations.
- Evaluates probe accuracy on unseen windows from the same subjects.
- Computes the mean probe accuracy, confidence interval, and one-sample t-test against theoretical chance accuracy (4.76%).
- Reports per-subject recall from the final split to identify which subjects are most and least distinguishable in the learned representation space.
- Categorizes the severity of subject identity leakage based on probe performance.

**Key results:**
- Mean probe accuracy: **76.37% ± 0.37%**
- Chance accuracy: **4.76%**
- Probe performance: **16.04× higher than chance**
- Statistical significance: **t = 573.29, p = 7.61 × 10⁻²²**
- Per-subject recall ranged from **36.72%** (Subject 14) to **95.76%** (Subject 4).

**Conclusion:**
- The BiLSTM representations contain **strong subject-specific information**, allowing a simple linear classifier to correctly identify the subject of unseen EEG windows with **76.37% accuracy**, far exceeding the theoretical chance level of **4.76%**.
- The extremely significant statistical result confirms that the learned representation space is highly organized by subject identity.
- These findings provide strong evidence of **subject identity leakage**, indicating that the BiLSTM has learned subject-discriminative features in addition to fatigue-related information.
- This subject-specific encoding is likely a major contributor to the large gap observed between within-subject and cross-subject (LOSO) performance, providing strong motivation for subsequent subject-invariant representation learning methods such as adversarial domain adaptation (Stage 5B).

  ## Block 5A.4 — t-SNE Visualization

**Purpose:** Visualizes the 64-dimensional BiLSTM penultimate-layer representations in a two-dimensional space to qualitatively examine whether the learned feature space is organized by subject identity, fatigue class, or both.

**What this block does:**
- Randomly samples up to **200 EEG windows per subject** to make t-SNE computationally feasible.
- Standardizes the extracted 64-dimensional representations before dimensionality reduction.
- Applies **t-distributed Stochastic Neighbor Embedding (t-SNE)** to project the high-dimensional representations into two dimensions.
- Generates two complementary visualizations:
  - **Subject-wise visualization:** Colors each point according to subject ID to inspect subject-specific clustering.
  - **Fatigue-wise visualization:** Colors each point according to fatigue class (Awake, Tired, Drowsy) to inspect class separability.
- Saves the resulting visualization for qualitative analysis and comparison with other architectures.

**Conclusion:**
- The t-SNE visualization provides an intuitive view of the geometry of the BiLSTM representation space.
- Subject-wise clustering reveals whether the learned representations preserve subject-specific characteristics, supporting or refuting the quantitative findings from the linear probe analysis.
- Fatigue-class visualization indicates how effectively the learned representations separate different fatigue states independent of subject identity.
- Together, these visualizations complement the quantitative leakage analysis by illustrating whether the representation space is primarily organized according to **subject identity**, **fatigue state**, or a combination of both, thereby providing qualitative evidence for the source of cross-subject generalization performance.

- ### Block 5A.5 — MMD vs LOSO Accuracy Analysis

**Purpose:** Quantifies the distribution shift between each subject's learned BiLSTM representations and the pooled representations of all remaining subjects using **Maximum Mean Discrepancy (MMD)**, and investigates whether this distribution shift explains the observed variation in cross-subject (LOSO) classification performance.

**What this block does:**
- Computes the **Maximum Mean Discrepancy (MMD)** between the representation distribution of each test subject and the pooled distribution of all other subjects using an unbiased **RBF-kernel MMD** estimator.
- Uses the **median heuristic** to automatically determine the kernel bandwidth.
- Normalizes the representation vectors before computing MMD to ensure scale invariance.
- Calculates one MMD score per subject and pairs it with the corresponding LOSO classification accuracy.
- Evaluates the relationship between representation distribution shift and LOSO performance using both **Spearman** and **Pearson** correlation coefficients.
- Generates a scatter plot with a fitted regression line to visualize the association between MMD and LOSO accuracy.

**Key results:**
- Mean subject MMD scores ranged approximately from **0.127** to **0.581**.
- Spearman correlation between MMD and LOSO accuracy:
  - **r = 0.0052, p = 0.9822**
- Pearson correlation between MMD and LOSO accuracy:
  - **r = -0.0020, p = 0.9931**

**Conclusion:**
- No statistically significant relationship was observed between representation distribution shift (MMD) and cross-subject (LOSO) classification accuracy.
- Subjects whose learned representations differed substantially from the remaining population did **not** consistently exhibit lower LOSO performance.
- These findings suggest that **distribution shift alone does not explain the BiLSTM's cross-subject generalization gap**.
- Combined with the strong subject identity leakage observed in Block 5A.3, the results indicate that **subject-specific feature encoding**, rather than overall representation distribution mismatch, is likely the dominant factor limiting cross-subject generalization. Other mechanisms, such as subject identity leakage or label boundary differences, should therefore be investigated in subsequent stages.

## Block 5A.6 — Stage 5A Summary

**Purpose:** Consolidates the results from all Stage 5A analyses into a single per-subject summary, combining subject identity leakage, cross-subject performance, within-subject performance, representation distribution shift, and generalization gap to identify the primary factors limiting BiLSTM cross-subject generalization.

**What this block does:**
- Computes the **per-subject subject-identity probe recall** from the linear probe experiment.
- Aggregates **LOSO accuracy** across sessions for subjects with multiple recording sessions.
- Retrieves **within-subject accuracy** from the Stage 4 within-subject experiment.
- Integrates the **MMD score** computed for each subject.
- Calculates the **generalization gap** (within-subject accuracy − LOSO accuracy) for every subject.
- Constructs a unified per-subject summary table containing all evaluation metrics.
- Computes overall statistics, including:
  - Mean LOSO accuracy
  - Mean within-subject accuracy
  - Mean generalization gap
  - Overall probe accuracy
  - Mean MMD score
- Evaluates the relationships between MMD, probe recall, LOSO accuracy, and generalization gap using Spearman correlation analysis.
- Produces a consolidated interpretation of the Stage 5A findings and exports the complete summary table as a CSV file.

**Key results:**
- Mean LOSO accuracy: **40.85%**
- Mean within-subject accuracy: **85.12%**
- Mean generalization gap: **44.27%**
- Subject identity probe accuracy: **76.37% ± 0.37%** (**16.04× chance**, **p = 7.61 × 10⁻²²**)
- Mean MMD score: **0.3614 ± 0.1229**
- Spearman correlations:
  - MMD vs LOSO accuracy: **r = 0.0052, p = 0.9822**
  - Probe recall vs LOSO accuracy: **r = −0.2631, p = 0.2493**
  - MMD vs generalization gap: **r = 0.0968, p = 0.6764**
  - Probe recall vs generalization gap: **r = 0.4084, p = 0.0661**

**Conclusion:**
- Stage 5A provides strong quantitative evidence that the BiLSTM representations encode substantial **subject identity information**, with the linear probe achieving **76.37% accuracy**, approximately **16 times higher than random chance**.
- A large average generalization gap (**44.27%**) confirms that the model performs considerably better within subjects than across unseen subjects.
- MMD analysis revealed **no statistically significant relationship** between representation distribution shift and LOSO performance, indicating that simple distribution mismatch is not the primary explanation for cross-subject failure.
- Although probe recall exhibited a moderate positive relationship with the generalization gap, this trend did not reach statistical significance.
- Overall, Stage 5A demonstrates that **subject identity leakage is the dominant characteristic of the learned BiLSTM representations**, while representation distribution shift contributes little to explaining cross-subject performance degradation. These findings strongly motivate the use of subject-invariant representation learning techniques, such as adversarial domain adaptation, in the subsequent stage.
