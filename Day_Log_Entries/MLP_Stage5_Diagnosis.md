### **Block 5A.1 – Extract Penultimate-Layer Representations**

#### **What this block does**

* Extracts the **64-dimensional penultimate-layer (latent) representations** from the trained MLP model for every EEG window.
* Manually reconstructs the forward pass using the learned weights and biases of the `MLPClassifier`, stopping before the final classification layer.
* Stores the extracted representations along with their corresponding fatigue labels and subject IDs.
* Validates the extraction by comparing manually computed predictions with the model's original predictions.

#### **Key Findings**

* Successfully extracted representations for **20,355 EEG windows** across **21 subjects**.
* Obtained a **64-dimensional latent representation** for each window.
* Manual forward pass achieved **100% agreement (1.0000)** with `MLPClassifier.predict()`, confirming correct representation extraction.
* Verified the trained MLP architecture:

  * Input: **85 features**
  * Hidden layers: **256 → 128 → 64 neurons**
  * Output: **3 fatigue classes**
* The extracted representations are validated and ready for subsequent analyses, including **subject identity probing**, **t-SNE visualization**, and **subject separability analysis**.

### **Block 5A.2 – Build Representation Dataset**

#### **What this block does**

* Organizes the extracted latent representations into a structured dataset indexed by **subject ID** and **fatigue label**.
* Computes the number of EEG windows and fatigue class distribution for each subject.
* Determines the total number of unique subjects and establishes the **chance-level accuracy** for subject identification.

#### **Key Findings**

* Constructed a representation dataset containing **21 unique subjects**.
* Total chance-level accuracy for subject identification is **4.76% (1/21)**.
* Most subjects contributed **885 EEG windows**, while Subjects **4** and **5** contributed **1,770 windows** each (two recording sessions).
* Fatigue class distributions vary considerably across subjects, indicating substantial subject-specific label imbalance.
* The representation dataset is correctly organized and ready for **LOSO subject identity probing** in the next stage.

This experiment is now **conceptually correct**, and the result is actually **very important**.

For your GitHub `.md`, you can write:

---

### **Block 5A.3 – Subject Identity Probe (Linear Probe Analysis)**

#### **What this block does**

* Evaluates whether the learned **64-dimensional latent representations encode subject identity**.
* Trains a **linear Logistic Regression probe** to predict the subject ID from the extracted representations.
* Uses **10 repeated stratified window-level train/test splits (80%/20%)**, ensuring every subject appears in both training and testing.
* Compares probe performance against the **chance level (1/21 = 4.76%)** to quantify subject identity leakage.

#### **Key Findings**

* The linear probe achieved **100.0% ± 0.0%** subject identification accuracy across all 10 splits.
* Subject identification accuracy is **21× higher than chance (4.76%)**.
* The improvement over chance is **highly statistically significant** (**p < 0.0001**).
* Every subject achieved **100% recall**, indicating that the learned representations perfectly preserve subject identity.
* **Strong subject identity leakage** was detected, demonstrating that the MLP representations are highly organized by **subject-specific EEG characteristics** rather than being purely fatigue-discriminative.

#### **Conclusion**

* The learned latent representations contain an exceptionally strong **subject-specific fingerprint**.
* This provides strong evidence that **subject identity leakage is a major contributor to the poor LOSO cross-subject generalization performance**.
* The results strongly motivate exploring **subject-invariant representation learning** (e.g., adversarial domain adaptation or domain generalization methods) in subsequent stages.

* ### **Block 5A.4 – t-SNE Visualization of Learned Representations**

#### **What this block does**

* Projects the **64-dimensional penultimate-layer representations** into a **2D space using t-SNE** for visual interpretation.
* Generates two visualizations of the same representation space:

  * **By Subject ID:** to examine whether representations cluster according to individual subjects.
  * **By Fatigue Class:** to examine whether representations separate according to fatigue states (Awake, Tired, Drowsy).
* Provides a qualitative assessment of whether the model primarily learns **subject-specific** or **fatigue-specific** features.

#### **Key Findings**

* The **Subject ID visualization** shows several **distinct subject-specific clusters**, indicating that representations retain strong information about individual subjects.
* The **Fatigue Class visualization** also exhibits meaningful organization:

  * **Awake (blue)** samples are predominantly concentrated on the left.
  * **Tired (orange)** samples occupy the central region.
  * **Drowsy (red)** samples are largely grouped toward the right.
* While some overlap exists between neighbouring fatigue states, the three fatigue classes exhibit a noticeable global separation.
* The representation space simultaneously preserves **subject identity** and **fatigue-related information**, rather than being exclusively organized by one factor.

#### **Conclusion**

* The t-SNE visualization provides qualitative evidence that the learned latent representations encode **both subject identity and fatigue state**.
* The presence of clear subject-wise clusters supports the **subject identity leakage** observed in the linear probe analysis.
* At the same time, the emergence of fatigue-based grouping indicates that the MLP has learned meaningful fatigue-related features, although these coexist with strong subject-specific characteristics that can hinder cross-subject generalization.

### **Block 5A.5 – MMD vs LOSO Accuracy Analysis**

#### **What this block does**

* Computes the **Maximum Mean Discrepancy (MMD)** between each test subject's learned representation distribution and the pooled representation distribution of all remaining subjects.
* Uses an **RBF-kernel MMD** with the **median heuristic** for bandwidth selection to quantify the degree of representation distribution shift.
* Examines whether subjects that are more dissimilar from the training distribution also exhibit lower LOSO classification accuracy by computing **Spearman** and **Pearson** correlations between MMD and LOSO accuracy.
* Visualizes the relationship using a scatter plot with a fitted regression line.

#### **Key Findings**

* MMD scores varied across subjects, indicating different levels of representation distribution shift between individual subjects and the pooled training distribution.
* A **weak negative correlation** was observed between MMD and LOSO accuracy:

  * **Spearman correlation:** **−0.299** (*p* = **0.188**)
  * **Pearson correlation:** **−0.219** (*p* = **0.341**)
* Although the correlation direction agrees with the hypothesis that larger distribution shifts reduce generalization performance, the relationship was **not statistically significant**.
* Subjects with relatively high MMD did not consistently achieve low LOSO accuracy, and conversely, some subjects with moderate MMD still exhibited poor performance.

#### **Conclusion**

* The learned representations exhibit measurable distribution shifts across subjects; however, these shifts **alone do not sufficiently explain** the observed degradation in cross-subject LOSO performance.
* The weak, non-significant negative correlation suggests that **representation distribution shift is only a contributing factor rather than the primary cause** of the generalization gap.
* Combined with the findings from Blocks **5A.3** and **5A.4**, this indicates that while the MLP representations strongly encode subject identity, **additional factors** such as subject-specific fatigue patterns, label boundary variations, or other forms of domain shift are also likely responsible for the reduced cross-subject generalization.

### Block 5A.6 — Stage 5A Summary

**Purpose:** Consolidates the findings from Stage 5A into a single per-subject summary table and produces the overall interpretation of the subject identity leakage analysis.

**What this block does:**
- Aggregates per-subject metrics including probe recall (last split), LOSO accuracy, within-subject accuracy, MMD score, and the resulting generalization gap.
- Computes overall statistics for subject probe performance, MMD, and within-/cross-subject performance.
- Evaluates correlations between representation distribution shift (MMD) and generalization performance.
- Generates a consolidated scientific verdict on whether subject identity leakage and distribution shift explain the observed LOSO performance gap.
- Saves the complete per-subject summary as a CSV file for further analysis and reporting.

**Key outputs:**
- Per-subject summary table.
- Overall subject identity leakage statistics.
- MMD vs LOSO correlation analysis.
- Final Stage 5A interpretation and conclusions.
