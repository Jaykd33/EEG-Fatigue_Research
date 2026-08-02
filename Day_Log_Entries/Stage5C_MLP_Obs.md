# Stage 5C — Per-Subject Correlation Analysis

## What this Stage Does

Stages 5A, 5B and 5RC established that subject identity is strongly encoded in the learned representations, that standard adversarial training (DANN) is largely ineffective at removing this information, and that much of the identity signal already exists in the raw DE-LDS feature space. However, these stages do not answer a more important scientific question:

> **Does subject identity leakage actually explain why some subjects generalise poorly during leave-one-subject-out (LOSO) evaluation?**

Stage 5C addresses this question by performing a subject-level statistical analysis across all 21 subjects.

Instead of analysing representations directly, this stage treats each subject as a single observation and investigates whether subjects exhibiting stronger identity leakage also exhibit poorer cross-subject generalisation.

Three quantities are analysed for every subject:

- **Subject probe recall (Stage 5A):** Measures how easily windows belonging to a subject can be recognised from the learned representation. Higher recall indicates stronger subject-specific encoding.
- **Maximum Mean Discrepancy (MMD) score (Stage 5A.5):** Measures how different a subject's representation distribution is from the remaining training subjects. Larger MMD indicates greater distribution shift.
- **LOSO accuracy (Stage 1):** Measures how accurately the fatigue classifier generalises to an unseen subject.

These subject-level measurements are then compared using correlation analysis to determine whether identity leakage or representation distribution shift better explains cross-subject performance.

To further isolate each factor, Stage 5C also performs:

- Partial correlation analysis to determine whether probe recall predicts LOSO accuracy independently of MMD (and vice versa).
- Generalisation-gap analysis to examine whether stronger subject identity encoding leads to a larger gap between within-subject and cross-subject performance.
- Subject-level clustering to identify whether high-leakage subjects exhibit systematic differences in fatigue label distributions or representation characteristics.

Unlike the previous stages, which focused on detecting and removing subject identity, Stage 5C evaluates its practical impact on model generalisation.

---

## What the Results Mean

The correlation analyses quantify how strongly subject identity leakage is associated with cross-subject fatigue classification performance.

Three possible outcomes are expected:

### Scenario 1 — Identity Leakage Dominates

If subjects with higher probe recall consistently achieve lower LOSO accuracy, a strong negative correlation will be observed.

This indicates that highly subject-specific representations reduce cross-subject generalisation, supporting the hypothesis that subject identity leakage is a major obstacle to subject-independent fatigue recognition.

---

### Scenario 2 — Distribution Shift Dominates

If MMD exhibits a stronger negative correlation with LOSO accuracy than probe recall, representation distribution shift becomes the primary explanation for poor generalisation.

In this case, identity leakage may exist but is not the principal factor limiting performance.

---

### Scenario 3 — Both Factors Contribute

If both probe recall and MMD correlate significantly with LOSO accuracy, and both remain significant under partial correlation analysis, then both subject identity leakage and representation distribution shift independently contribute to cross-subject performance degradation.

This would indicate that improving subject-independent fatigue recognition requires simultaneously reducing identity information while also aligning representation distributions across subjects.

---

## Scientific Contribution

Stage 5C provides the final quantitative evidence linking representation characteristics to real-world model performance.

Rather than simply demonstrating that subject identity leakage exists (Stage 5A), that adversarial training struggles to remove it (Stage 5B), or that leakage originates from the raw feature space (Stage 5RC), this stage evaluates whether those factors actually explain differences in subject-level generalisation.

The resulting correlation and partial-correlation analyses establish whether subject identity leakage, distribution shift, or both are statistically associated with LOSO accuracy.

Together with the previous stages, Stage 5C completes the investigation by connecting representation analysis with downstream fatigue classification performance, providing the strongest statistical evidence for the factors governing subject-independent EEG fatigue recognition.

## Block 5C.0 — Data Preparation

### Purpose

This block assembles the per-subject summary statistics generated in the previous stages into a single analysis table.

Unlike earlier stages, no model training or representation extraction is performed. Instead, the block gathers the summary metrics required for the correlation analyses from Stage 5A.

For every subject, the following quantities are collected:

- Subject identity probe performance (probe recall)
- LOSO fatigue classification accuracy
- Within-subject classification accuracy
- Maximum Mean Discrepancy (MMD)
- Generalisation gap (within-subject − LOSO)

The block also standardises column names across different versions of Stage 5A, removes incomplete subjects (if any), and constructs the working DataFrame used throughout Stage 5C.

### Findings

All 21 subjects contained complete measurements for every required metric.

The assembled table confirmed that no missing values were present, allowing every subject to be included in the subsequent statistical analyses.

However, inspection of the data revealed that the probe recall was identical (1.0000) for every subject.

### Interpretation

The identical probe recall values indicate that the current per-subject leakage metric contains no between-subject variability.

Because correlation analysis requires variation in both the predictor and outcome variables, this metric cannot explain differences in LOSO performance across subjects.

Consequently, the planned Pearson, Spearman and partial correlation analyses using this probe recall variable are statistically invalid in their current form.

To perform meaningful correlation analysis, the leakage metric must vary across subjects (for example, by using per-subject probe confidence, margin, entropy, average prediction probability, or another continuous subject-specific leakage measure rather than perfect recall).

## Block 5C.1 — Probe Recall vs LOSO Accuracy

### Purpose

This block performs the primary statistical analysis of Stage 5C by examining the relationship between subject identity leakage and cross-subject fatigue classification performance.

For each subject, the following two quantities are compared:

- **Probe recall (Stage 5A):** measures how strongly the learned representations encode subject identity.
- **LOSO accuracy (Stage 1):** measures how well the fatigue classifier generalises to that unseen subject.

Both **Spearman rank correlation** and **Pearson linear correlation** are computed to evaluate whether stronger subject identity encoding is associated with poorer cross-subject generalisation.

### Findings

The analysis produced:

- Spearman correlation: **NaN**
- Pearson correlation: **NaN**

The probe recall values were identical across all 21 subjects, resulting in no measurable variation for correlation analysis.

### Conclusion

Because the probe recall metric showed no variation between subjects, no valid correlation could be computed between subject identity leakage and LOSO accuracy.

Consequently, this analysis does not provide statistical evidence either supporting or rejecting an association between subject identity leakage and cross-subject generalisation using the current per-subject probe metric.

## Block 5C.2 — MMD Score vs LOSO Accuracy

### Purpose

This block evaluates whether representation distribution shift is associated with cross-subject fatigue classification performance.

For each subject, the Maximum Mean Discrepancy (MMD) score is compared with the corresponding LOSO accuracy to determine whether subjects whose feature distributions differ more from the training population are more difficult for the model to generalise to.

Both Spearman rank correlation and Pearson linear correlation are computed, allowing the predictive strength of MMD to be compared directly with that of the subject identity leakage metric from Block 5C.1.

### Findings

The analysis produced the following results:

- Spearman correlation: **−0.2987**
- Spearman p-value: **0.1884**
- Pearson correlation: **−0.2189**
- Pearson p-value: **0.3405**

Although both correlations were negative, neither reached statistical significance.

Comparison with the probe recall analysis indicated that MMD was the stronger predictor of LOSO accuracy, as the probe recall metric exhibited no measurable variation across subjects.

### Conclusion

No statistically significant relationship was observed between representation distribution shift (MMD) and LOSO accuracy.

The negative correlation suggests that subjects with larger representation shifts tended to achieve lower cross-subject classification accuracy, but this trend was not sufficiently strong to be considered statistically significant in the current dataset.

Overall, representation distribution shift alone did not provide a significant explanation for cross-subject generalisation performance.

## Block 5C.3 — Probe Recall vs Generalisation Gap

### Purpose

This block evaluates whether stronger subject identity leakage is associated with a larger generalisation gap.

The generalisation gap is defined as the difference between within-subject accuracy and LOSO accuracy, representing the extent to which model performance deteriorates when evaluated on previously unseen subjects.

In addition to probe recall, the analysis also examines the relationship between Maximum Mean Discrepancy (MMD) and the generalisation gap to assess whether representation distribution shift contributes to cross-subject performance degradation.

### Findings

The analysis produced the following results:

- Probe recall vs generalisation gap:
  - Spearman correlation: **NaN**
  - p-value: **NaN**
- MMD vs generalisation gap:
  - Spearman correlation: **0.3078**
  - p-value: **0.1747**

Neither relationship reached statistical significance.

### Conclusion

No statistically significant association was observed between the available subject identity leakage metric and the generalisation gap.

Similarly, although MMD exhibited a weak positive correlation with the generalisation gap, the relationship was not statistically significant. Based on the current measurements, neither subject identity leakage nor representation distribution shift showed a significant relationship with the magnitude of the cross-subject generalisation gap.

## Block 5C.4 — Partial Correlation Analysis

### Purpose

This block determines whether subject identity leakage and representation distribution shift explain independent components of cross-subject generalisation performance.

Partial correlation is used to measure the relationship between each predictor and LOSO accuracy while statistically controlling for the other predictor.

Two analyses are performed:

- **Probe recall vs LOSO accuracy, controlling for MMD**
- **MMD vs LOSO accuracy, controlling for probe recall**

This allows the independent contribution of each factor to be evaluated beyond their shared variation.

### Findings

The partial correlation analysis produced the following results:

- Probe recall vs LOSO accuracy (controlling for MMD):
  - Partial correlation: **−0.0317**
  - p-value: **0.8914**

- MMD vs LOSO accuracy (controlling for probe recall):
  - Partial correlation: **−0.2189**
  - p-value: **0.3405**

Neither partial correlation was statistically significant.

### Conclusion

After controlling for the alternative predictor, neither subject identity leakage nor representation distribution shift showed a statistically significant independent association with LOSO accuracy.

These results indicate that neither metric explained unique variation in cross-subject generalisation performance within the current dataset. Instead, both variables appeared to share limited explanatory power with the observed differences in LOSO accuracy across subjects.

## Block 5C.5 — Subject Stratification: High vs Low Leakage Groups

### Purpose

This block attempts to stratify subjects into **high** and **low** identity leakage groups using a median split of the per-subject probe recall values.

The objective is to compare cross-subject performance between these groups by examining:

- LOSO accuracy
- Maximum Mean Discrepancy (MMD)
- Generalisation gap

Group differences are intended to be evaluated using the non-parametric Mann–Whitney U test.

### Findings

The median probe recall was **1.0000**.

As every subject achieved the same probe recall value, all **21 subjects** were assigned to the high-leakage group, while **no subjects** were assigned to the low-leakage group.

Consequently, no statistical comparison between groups could be performed.

### Conclusion

Subject stratification based on probe recall was not feasible because the probe recall metric exhibited no variability across subjects.

Without distinct high- and low-leakage groups, Mann–Whitney U tests could not be conducted, and no conclusions regarding group differences in LOSO accuracy, MMD, or generalisation gap could be drawn using the current leakage metric.
## Block 5C.6 — Publication-Quality Correlation Figure

### Purpose

This block generates a publication-quality four-panel figure summarising the relationships between subject identity leakage, representation distribution shift, and cross-subject generalisation performance.

The figure includes:

- **Panel A:** Subject probe recall vs LOSO accuracy
- **Panel B:** MMD score vs LOSO accuracy
- **Panel C:** Subject probe recall vs generalisation gap
- **Panel D:** Subject probe recall vs MMD score

Each panel contains individual subject data points, subject identifiers, an ordinary least-squares regression line, a 95% confidence interval, and the corresponding Spearman correlation coefficient and p-value.

The figure provides a visual summary of the statistical analyses performed throughout Stage 5C.

### Findings

Visual inspection of the scatter plots showed no clear monotonic or linear relationship between subject probe recall and either LOSO accuracy or the generalisation gap.

This was expected because the probe recall metric exhibited virtually no variation across subjects, resulting in a near-vertical distribution of points for all probe-based analyses.

The MMD versus LOSO accuracy plot displayed a weak negative trend, consistent with the correlation analysis, although considerable variability remained between subjects and no statistically significant relationship was observed.

Similarly, the probe recall versus MMD plot showed no meaningful association because probe recall remained essentially constant across all subjects.

### Conclusion

The visualisations support the statistical findings obtained in Blocks 5C.1–5C.5.

No clear relationship was observed between the current subject identity leakage metric and cross-subject generalisation performance.

Likewise, representation distribution shift showed only a weak, non-significant association with LOSO accuracy.

Overall, the figure confirms that neither the available probe recall metric nor MMD provided a statistically significant predictor of subject-level LOSO performance in the present analysis.

## Block 5C.7 — Publication-Quality Summary Statistics Table

### Purpose

This block consolidates all correlation analyses performed throughout Stage 5C into a single publication-ready summary table.

For every investigated relationship, it reports:

- Spearman and Pearson correlation coefficients
- Statistical significance (p-values)
- Effect size classification
- Sample size
- Source analysis block

The table also includes the partial correlation results and exports all statistics as a CSV file for inclusion in the paper.

### Findings

The summary table confirms that none of the relationships involving subject probe recall were statistically meaningful because probe recall exhibited virtually no variability across subjects, resulting in undefined (NaN) correlation coefficients.

MMD score showed:

- A weak, non-significant negative relationship with LOSO accuracy (Spearman r = −0.299, p = 0.188).
- A moderate but non-significant positive relationship with the generalisation gap (Spearman r = 0.308, p = 0.175).
- A statistically significant positive relationship with within-subject accuracy (Spearman r = 0.638, p = 0.0019), representing the strongest association observed in Stage 5C.

Partial correlation analysis likewise showed no significant independent contribution of either probe recall or MMD toward LOSO accuracy after controlling for the other predictor.

### Conclusion

The comprehensive statistical summary demonstrates that neither subject identity leakage (as measured by the current probe recall metric) nor representation distribution shift significantly predicts subject-level LOSO performance.

The only statistically significant relationship identified was between MMD and within-subject accuracy, suggesting that subjects exhibiting greater representational divergence also tend to achieve higher within-subject performance.

Overall, Stage 5C provides no statistical evidence that either subject identity leakage or MMD independently explains the observed variability in cross-subject generalisation performance across individual subjects.

## Block 5C.8 — Per-Subject Ranked Summary Table

### Purpose

This block creates a publication-ready table ranking all 21 subjects from the hardest to the easiest to generalise based on their LOSO accuracy.

For each subject, the table reports:

- LOSO accuracy
- Subject probe recall
- MMD score
- Generalisation gap
- Leakage group (High/Low)

The ranked table is exported as a CSV file for inclusion in the paper or supplementary material.

### Findings

The ranking revealed substantial variability in cross-subject generalisation performance, with LOSO accuracy ranging from **10.3%** (Subject 17) to **85.3%** (Subject 3).

However, every subject exhibited an identical probe recall of **1.000**, causing:

- The median probe recall to equal 1.000.
- All 21 subjects to be assigned to the **High Leakage** group.
- No Low Leakage comparison group to exist.

The table therefore primarily highlights differences in LOSO accuracy, MMD score, and generalisation gap across subjects rather than differences in identity leakage.

### Conclusion

The ranked summary confirms that although cross-subject performance varies considerably between individuals, subject identity leakage is uniformly maximal across all subjects.

Since probe recall is identical for every subject, it cannot explain why some subjects are substantially harder to generalise to than others. Instead, the remaining subject-level variability must arise from factors other than the measured identity leakage, such as individual EEG characteristics, fatigue patterns, or residual distribution differences.

========================================================================
STAGE 5C — FINAL VERDICT
========================================================================

PRIMARY CORRELATIONS (Spearman, outcome = LOSO accuracy, N=21):
  Identity leakage (probe recall)  : r = +nan  p = nan
  Distribution shift (MMD)         : r = -0.2987  p = 0.1884

PARTIAL CORRELATIONS (after controlling for the other predictor):
  Probe recall | MMD               : r = -0.0317  p = 0.8914
  MMD          | probe recall      : r = -0.2189  p = 0.3405

CONCLUSION:

  Verdict: INCONCLUSIVE
  No predictor reaches conventional significance at N=21.
  The relationships may exist but this sample size (21 subjects)
  provides insufficient statistical power to detect medium-sized
  correlations (|r| ~ 0.35 requires N ≈ 64 for 80% power at α=0.05).

  Recommend: (1) report the effect sizes and confidence intervals
  rather than binary significance, and (2) frame Stage 5C as
  descriptive evidence rather than confirmatory.

  Stronger predictor by effect size: MMD (distribution shift)
  (|r_probe| = nan  vs  |r_mmd| = 0.2987)

────────────────────────────────────────────────────────────────────────
PAPER NARRATIVE — How Stage 5C fits the overall contribution:

  Stage 5A: Diagnosing subject identity leakage (probe accuracy far
            above chance for all three architectures).
  Stage 5B: Attempting to remove it via DANN-GRL (largely unsuccessful,
            because raw features already contain the subject signal).
  Stage 5RC: Confirming the raw-feature origin of leakage (DE-LDS
             features are inherently subject-discriminative).
  Stage 5C: Quantifying the relationship between leakage severity,
            distribution shift, and cross-subject failure at N=21.

  Together these stages constitute a complete diagnostic study of
  cross-subject generalisation failure — the kind of systematic
  analysis that is largely absent from the existing SEED-VIG literature.

Stage 5C outputs:
  Main figure      : /kaggle/working/stage5C_correlation_analysis.png
  Statistics table : /kaggle/working/stage5C_correlation_table.csv
  Per-subject table: /kaggle/working/stage5C_per_subject_ranked.csv

Stage 5C complete.
