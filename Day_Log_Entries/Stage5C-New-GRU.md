# Stage 5C – Understanding the Remaining Sources of Cross-Subject Generalization Failure (GRU)

## Objective

After completing Stage 5A and Stage 5B, we had already established two important findings:

1. The learned GRU representations contain extremely strong subject identity information.
2. Domain-Adversarial Neural Networks (DANN) failed to remove this identity information or improve cross-subject performance.

Although identity leakage had been confirmed, one important question still remained unanswered.

**Why do some subjects achieve very high LOSO accuracy (around 88%) while others achieve extremely poor performance (around 4%)?**

If subject identity leakage exists for every subject, then why are only some subjects difficult for cross-subject prediction?

Stage 5C was designed to answer this question.

The objective of this stage was to investigate whether any measurable subject-level property could explain the large variation in LOSO performance across different individuals.

---

# Motivation

The previous stages proved that identity leakage exists.

However, identity leakage alone cannot explain why some subjects are significantly easier than others.

To investigate this, Stage 5C measured several subject-specific characteristics extracted from the learned GRU representations and tested whether these characteristics correlate with cross-subject classification performance.

Instead of proposing another model, this stage focuses entirely on understanding the behaviour of the existing model.

The analysis is completely model-independent after feature extraction and is based entirely on statistical testing.

---

# Block 5C.0 – Per-Subject Data Assembly

The first step was to collect every piece of information available for each subject from all previous stages.

For each of the 21 subjects, the following information was assembled:

- LOSO accuracy
- Balanced accuracy
- Within-subject accuracy
- Generalization gap
- DANN accuracy
- Improvement (or degradation) after DANN

This produced a single subject-level dataframe containing one row per subject.

This dataframe became the foundation for every remaining analysis in Stage 5C.

---

# Block 5C.1 – Representation Geometry Analysis

The first hypothesis was that some subjects might naturally form cleaner representation clusters than others.

To investigate this, three representation-space metrics were computed.

## 1. Silhouette Score

The silhouette score measures how well the representation vectors of one subject are grouped together while remaining separated from other subjects.

A higher value indicates better cluster separation.

Across all subjects:

- Mean silhouette score = **0.1267**
- Standard deviation = **0.1865**
- Range = **-0.1533 to 0.5357**

Some subjects formed well-separated clusters while others showed considerable overlap.

---

## 2. Cosine Similarity

Cosine similarity measures how similar representation vectors are within the same subject.

Higher similarity indicates that the GRU generates more consistent latent representations for that individual.

Results:

- Mean cosine similarity = **0.5956**
- Standard deviation = **0.1780**

---

## 3. Centroid Distance

Each subject's average representation (centroid) was computed.

The Euclidean distance between each subject's centroid and the average centroid of all remaining subjects was then measured.

Results:

- Mean centroid distance = **0.7170**
- Standard deviation = **0.1161**

This metric estimates how different an individual's representation is compared to the overall population.

---

# Block 5C.2 – Probe Confidence

Stage 5A already showed that subject identity could be recovered with approximately **100% accuracy**.

Since classification accuracy had saturated, it could no longer distinguish between subjects.

Instead, this block measured the **confidence** of the linear probe.

Rather than asking whether the probe predicts the correct subject, it asked:

> **How confident is the probe when making the correct prediction?**

Results showed:

- Mean confidence = **0.9932**
- Standard deviation = **0.0048**
- Range = **0.9788 – 0.9990**

For comparison:

- Chance confidence = **0.0476**

These results indicate that the probe is not only correct but also extremely confident for every subject.

Identity leakage therefore appears uniformly strong across the entire dataset.

---

# Block 5C.3 – Correlation Analysis

The next step was to determine whether any representation property predicts cross-subject performance.

For every metric, Spearman rank correlation, permutation testing (10,000 permutations), and bootstrap confidence intervals (10,000 resamples) were computed.

The tested predictors were:

- Silhouette score
- Probe confidence
- Cosine similarity
- Centroid distance

The evaluated outcomes were:

- LOSO accuracy
- Balanced accuracy
- Generalization gap

---

## Relationship with LOSO Accuracy

None of the representation metrics showed a statistically significant relationship with LOSO accuracy.

The strongest trend was observed for cosine similarity:

- Spearman correlation = **−0.4182**
- Permutation p-value = **0.0625**

Although this suggests that subjects with more internally consistent representations may perform worse under LOSO evaluation, the result did not reach statistical significance.

Silhouette score showed only a weak relationship:

- Spearman correlation = **−0.2584**
- p = **0.2612**

Probe confidence showed almost no relationship:

- Spearman correlation = **0.0779**
- p = **0.7405**

Centroid distance also showed no significant relationship:

- Spearman correlation = **0.1286**
- p = **0.5808**

Overall, none of the tested representation characteristics could reliably explain cross-subject accuracy differences.

---

## Relationship with Balanced Accuracy

Balanced accuracy produced stronger correlations.

Silhouette score showed a significant negative correlation:

- Spearman correlation = **−0.6528**
- p = **0.0022**

Cosine similarity also showed a significant negative correlation:

- Spearman correlation = **−0.5398**
- p = **0.0131**

Probe confidence showed a moderate trend:

- Spearman correlation = **−0.4261**
- p = **0.0569**

These findings indicate that representation geometry influences balanced class performance more strongly than overall LOSO accuracy.

---

# Block 5C.4 – Joint Regression Analysis

Simple correlations do not account for relationships between predictors.

Therefore, a multiple linear regression model was constructed using:

- Silhouette score
- Probe confidence
- Cosine similarity
- Centroid distance

The goal was to determine whether any predictor independently explains LOSO performance after controlling for the others.

Results showed:

For LOSO accuracy:

- R² = **0.229**
- Adjusted R² = **0.036**

For Balanced Accuracy:

- R² = **0.394**
- Adjusted R² = **0.243**

For Generalization Gap:

- R² = **0.180**
- Adjusted R² = **−0.026**

None of the standardized regression coefficients were statistically significant.

This indicates that no individual representation property independently predicts subject performance.

---

# Block 5C.5 – DANN Causal Analysis

The next question investigated whether DANN reduced subject identity for the subjects whose cross-subject accuracy improved.

For each subject, two quantities were measured:

- Change in probe confidence after DANN
- Change in LOSO accuracy after DANN

If DANN successfully removed identity information, these quantities should be positively correlated.

Results showed:

- Mean probe confidence change = **0.0053**
- Mean LOSO accuracy change = **−0.0218**

Correlation:

- Spearman correlation = **−0.0078**
- p = **0.9755**

No relationship was observed.

This confirms the conclusion from Stage 5B that DANN does not meaningfully reduce identity information in the learned representations.

---

# Block 5C.6 – Negative Control

To ensure that the observed relationships were not caused simply by any arbitrary subject-level property, a negative control experiment was performed.

Label entropy was computed for every subject.

This measures how evenly fatigue labels are distributed within that subject.

Correlation with LOSO accuracy:

- Spearman correlation = **0.4169**
- p = **0.0569**

Although this trend was slightly stronger than the silhouette score, it was still not statistically significant.

This result suggests that differences in label distribution may influence performance to some extent, but they cannot fully explain cross-subject failure.

---

# Block 5C.7 – Publication Figures

All findings were summarized into a six-panel publication-quality figure.

The figure illustrates relationships between:

- Silhouette score and LOSO accuracy
- Silhouette score and balanced accuracy
- Silhouette score and generalization gap
- Centroid distance and LOSO accuracy
- Probe confidence and LOSO accuracy
- Label entropy and LOSO accuracy

Each panel includes:

- Scatter plot
- Linear trend line
- Bootstrap confidence interval
- Spearman correlation
- Permutation p-value

This figure serves as the primary visualization of Stage 5C.

---

# Block 5C.8 – Per-Subject Ranking

Every subject was ranked from the hardest to the easiest according to LOSO accuracy.

For each subject, the following quantities were summarized:

- LOSO accuracy
- Balanced accuracy
- Generalization gap
- Silhouette score
- Probe confidence
- Centroid distance
- Label entropy

Subjects were additionally categorized into Low, Medium, and High representation leakage groups according to silhouette score.

Interestingly, average LOSO accuracy did not consistently increase across these groups, providing further evidence that representation geometry alone cannot explain subject difficulty.

---

# Overall Findings

Stage 5C attempted to determine whether measurable properties of the learned GRU representations explain why some subjects generalize well while others fail.

The analyses showed that:

- Probe confidence remains extremely high for every subject (mean = 0.9932), confirming uniformly strong identity leakage.
- None of the representation-space metrics significantly predict LOSO accuracy.
- Multiple regression confirms that no metric independently explains subject performance.
- DANN-induced changes in representation confidence are unrelated to changes in LOSO accuracy.
- Label entropy also fails to provide a statistically significant explanation.

Although balanced accuracy exhibits stronger relationships with some representation metrics, these relationships do not translate into reliable prediction of cross-subject generalization.

---

# Final Conclusion

Stage 5C demonstrates that the large variation in cross-subject performance cannot be explained by simple representation geometry, probe confidence, centroid distance, or label entropy.

These findings suggest that the remaining differences between subjects arise from more complex subject-specific neural characteristics that are not captured by these aggregate statistics.

Together with Stages 5A and 5B, Stage 5C strengthens the overall conclusion of this work.

The evidence indicates that subject identity leakage is pervasive throughout the learned representations, yet differences in cross-subject performance cannot be explained solely by measurable geometric properties.

This suggests that future research should move beyond representation-level analyses and investigate deeper physiological or subject-specific mechanisms responsible for individual variability in EEG-based fatigue detection.
