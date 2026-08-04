# Block 5C.0 — Imports, Configuration, and Per-Subject Data Assembly

## What this block does

- Collects and aggregates all previously computed subject-level results into a single analysis DataFrame without performing any additional model training.
- Combines metrics from Stage 1 (LOSO evaluation), Stage 4 (within-subject evaluation), and Stage 5B (DANN evaluation) for each of the 21 subjects.
- Computes per-subject performance measures including LOSO accuracy, balanced accuracy, within-subject accuracy, generalisation gap, post-DANN LOSO accuracy, and DANN-induced performance change (LOSO delta).
- Prepares the consolidated per-subject dataset that serves as the foundation for all subsequent Stage 5C representation geometry analyses.

## Findings

- Successfully assembled a complete per-subject dataset containing **21 subjects** with no missing LOSO performance values.
- Post-DANN LOSO accuracies were available for **all 21 subjects**, enabling later analyses of DANN-induced performance changes.
- LOSO accuracies exhibited substantial inter-subject variability, ranging from **0.0859** (Subject 17) to **0.8215** (Subject 7), confirming considerable differences in cross-subject generalisation performance.
- Within-subject accuracies remained consistently high for most subjects, producing large generalisation gaps for several individuals.
- DANN performance changes varied considerably across subjects, with some subjects showing noticeable improvements (e.g., Subject 4: **+0.2260**, Subject 1: **+0.0972**) while others experienced slight decreases, indicating heterogeneous responses to adversarial training.

## Conclusion

- Block 5C.0 successfully constructs the complete subject-level dataset required for all subsequent correlation and geometry analyses.
- The wide variation in LOSO accuracy and generalisation gap across subjects provides sufficient variability for investigating factors associated with cross-subject generalisation performance.
- The availability of both baseline and post-DANN subject-level results enables subsequent analyses to examine whether changes in representation geometry correspond to improvements in cross-subject performance.
- This consolidated DataFrame forms the primary input for the remainder of Stage 5C.

# Block 5C.1 — Per-Subject Representation Geometry Metrics

## What this block does

- Computes continuous representation geometry metrics for every subject directly from the learned BiLSTM representation space without any additional model training.
- Calculates the **silhouette score** for each subject to quantify how well-separated and compact each subject's representation cluster is.
- Computes the **intra-subject cosine similarity** to measure the consistency and compactness of representations belonging to the same subject.
- Calculates the **centroid distance** between each subject's representation centroid and the centroid of all remaining subjects as a measure of representation-space distribution shift.
- Produces subject-level geometry metrics that replace the previous constant probe recall measure and provide continuous leakage estimates for subsequent correlation analyses.

## Findings

- Successfully computed representation geometry metrics for **all 21 subjects** using a balanced subsample of **4,200 windows** (maximum 200 windows per subject).
- The **average silhouette score was -0.2701**, with values ranging from **-0.4747** to **0.2643**, indicating that most subjects exhibited overlapping rather than well-separated representation clusters.
- Only **Subjects 2 and 7** achieved positive silhouette scores, suggesting stronger subject-specific clustering than the remaining subjects.
- The **average intra-subject cosine similarity was 0.7193**, indicating generally high within-subject representation consistency despite overlapping subject clusters.
- The **average centroid distance was 0.3182**, with moderate variability across subjects, reflecting differences in how far each subject's representation distribution deviated from the overall population.

## Conclusion

- Block 5C.1 successfully establishes continuous geometry-based measures of subject identity leakage within the BiLSTM representation space.
- Unlike the MLP implementation, the BiLSTM representations exhibited predominantly **negative silhouette scores**, indicating substantially greater overlap between subject clusters despite maintaining relatively high within-subject representation consistency.
- The observed variability in silhouette score, cosine similarity, and centroid distance provides meaningful continuous leakage metrics for evaluating their relationship with cross-subject generalisation performance in subsequent Stage 5C analyses.
- These geometry metrics form the primary representation-level predictors used throughout the remainder of the BiLSTM Stage 5C experiments.

# Block 5C.2 — Per-Subject Probe Confidence (Continuous Leakage Measure)

## What this block does

- Computes a continuous **probe confidence** score for every subject using the trained BiLSTM representations.
- Trains a logistic regression subject classifier on a deterministic 80/20 stratified split and records the probability assigned to the correct subject class for every test window.
- Averages the true-class probabilities across all test windows belonging to each subject to obtain a subject-specific confidence score.
- Produces a continuous measure of subject identity encoding that captures how confidently the learned representations identify each subject, even when classification accuracy is high.
- Establishes probe confidence as a complementary leakage metric alongside the geometry-based measures computed in Block 5C.1.

## Findings

- Successfully computed probe confidence values for **all 21 subjects** using the same deterministic stratified evaluation split.
- The **average probe confidence was 0.5629**, substantially above the chance confidence level of **0.0476**, confirming that the BiLSTM representations retain strong subject-identifiable information.
- Probe confidence exhibited considerable variability across subjects, ranging from **0.2629** (Subject 21) to **0.8438** (Subject 4).
- Several subjects, including **Subjects 4, 20, 7, 17, 2, and 3**, achieved particularly high confidence values, indicating highly distinctive subject-specific representations.
- The larger standard deviation (**0.1660**) compared to the MLP implementation demonstrates greater variability in subject identity encoding across individuals within the BiLSTM representation space.

## Conclusion

- Block 5C.2 successfully generates a continuous subject leakage metric based on classifier confidence rather than binary classification accuracy.
- The consistently high confidence scores confirm that the BiLSTM representations preserve substantial subject identity information despite the overlapping representation geometry observed in Block 5C.1.
- The broad distribution of confidence values provides meaningful subject-level variation that can be used to investigate whether stronger subject identity encoding predicts poorer cross-subject generalisation in subsequent analyses.
- Probe confidence serves as one of the primary continuous leakage measures throughout the remaining BiLSTM Stage 5C analyses.

# Block 5C.3 — Core Correlation Analysis with Permutation Tests

## What this block does

- Performs the primary statistical analysis of Stage 5C by evaluating whether subject leakage metrics are associated with cross-subject generalisation performance.
- Correlates four representation-based predictors (silhouette score, probe confidence, intra-subject cosine similarity, and centroid distance) with three subject-level outcomes (LOSO accuracy, balanced accuracy, and generalisation gap).
- Uses **10,000-permutation Spearman correlation tests** to obtain robust significance estimates without relying on parametric assumptions.
- Computes **10,000-bootstrap 95% confidence intervals** for every correlation coefficient to quantify estimation uncertainty.
- Reports correlation strength, permutation p-values, confidence intervals, and effect-size classifications for every predictor–outcome pair.

## Findings

- None of the representation-based leakage metrics showed a statistically significant relationship with **LOSO accuracy** under permutation testing.
- **Silhouette score** exhibited a weak positive correlation with LOSO accuracy (r = +0.2883), but the relationship was not statistically significant (p = 0.2067).
- **Probe confidence** showed a weak negative correlation with LOSO accuracy (r = −0.2013), although this relationship was also not significant (p = 0.3783).
- **Intra-subject cosine similarity** demonstrated a weak positive association with LOSO accuracy (r = +0.2909), but failed to reach statistical significance.
- **Centroid distance** showed only a negligible relationship with LOSO accuracy (r = +0.1403).
- None of the predictors significantly explained **balanced accuracy** across subjects.
- The strongest trend was observed between **probe confidence and generalisation gap** (r = +0.3371), indicating that subjects with stronger identity encoding tended to exhibit larger within-to-cross-subject performance drops, although this trend did not reach statistical significance.
- Similarly, **intra-subject cosine similarity** showed a moderate negative relationship with generalisation gap (r = −0.3397), but this effect was also not statistically significant.
- Bootstrap confidence intervals for all correlations included zero, indicating considerable uncertainty around the estimated effect sizes.

## Conclusion

- No representation geometry metric significantly predicted cross-subject LOSO performance for the BiLSTM model at the subject level.
- Although several weak-to-moderate trends were observed, none survived permutation-based statistical testing, indicating insufficient evidence that subject-specific representation geometry alone explains differences in cross-subject performance.
- The results suggest that any relationship between subject leakage and cross-subject generalisation in the BiLSTM model is relatively weak or limited by the small sample size (21 subjects).
- These findings motivate the use of multivariate analyses and causal investigations in subsequent blocks to determine whether combinations of leakage metrics provide stronger explanatory power than individual metrics alone.

# Block 5C.4 — Joint OLS Regression

## What this block does

- Performs a multivariate analysis to determine whether representation leakage metrics independently explain cross-subject performance when considered together.
- Fits separate **Ordinary Least Squares (OLS)** regression models for three outcome variables:
  - LOSO accuracy
  - Balanced accuracy
  - Generalisation gap
- Uses four representation-based predictors simultaneously:
  - Silhouette score
  - Probe confidence
  - Intra-subject cosine similarity
  - Centroid distance
- Standardises all variables before regression, allowing direct comparison of predictor effect sizes through standardised beta coefficients.
- Evaluates predictor significance using **10,000 permutation tests** instead of conventional parametric tests, providing more reliable inference for the small sample size (N = 21).
- Reports overall model fit using both **R²** and **Adjusted R²**.

## Findings

### LOSO Accuracy Model

- The regression model explained only **18.0%** of the variance in LOSO accuracy (R² = 0.180), while the adjusted R² became negative (−0.025), indicating poor explanatory performance after accounting for model complexity.
- None of the four predictors significantly contributed to LOSO accuracy.
- Probe confidence showed the largest negative effect (β = −0.2822), while silhouette score showed a small positive effect (β = +0.2915), but neither was statistically significant.

### Balanced Accuracy Model

- The model explained **17.8%** of the variance in balanced accuracy (R² = 0.178), with a negative adjusted R² (−0.028).
- None of the predictors reached statistical significance.
- Intra-subject cosine similarity exhibited the largest positive standardized coefficient (β = +0.4684), whereas silhouette score showed the largest negative coefficient (β = −0.4428), although both remained non-significant.

### Generalisation Gap Model

- The regression model explained **17.3%** of the variance in the generalisation gap (R² = 0.173), with an adjusted R² of −0.033.
- None of the representation geometry metrics independently predicted the generalisation gap.
- Probe confidence produced the largest positive coefficient (β = +0.3560), indicating a tendency for stronger subject identity encoding to increase the within-to-cross-subject performance gap, but this relationship was not statistically significant.

## Conclusion

- Joint modelling of all four representation geometry metrics did not significantly explain variation in LOSO accuracy, balanced accuracy, or generalisation gap for the BiLSTM model.
- The consistently low R² values and negative adjusted R² values indicate that these predictors collectively account for only a small proportion of subject-to-subject performance variability.
- No individual representation geometry metric demonstrated an independent contribution after controlling for the remaining predictors.
- Overall, the multivariate analysis supports the earlier correlation results, indicating that subject-level representation geometry alone is insufficient to explain cross-subject generalisation performance in the BiLSTM model.

# Block 5C.5 — Cross-Stage Causal Analysis (DANN Delta Correlation)

## What this block does

- Evaluates whether reducing subject identity information through DANN training leads to improvements in cross-subject generalisation.
- Computes the change in probe confidence (ΔConfidence) for each subject before and after DANN training as a measure of identity leakage reduction.
- Computes the corresponding change in LOSO accuracy (ΔLOSO) after DANN training.
- Performs a permutation-based Spearman correlation between ΔConfidence and ΔLOSO to assess whether subjects experiencing greater reductions in subject identity also achieve larger improvements in LOSO performance.
- Uses bootstrap confidence intervals to quantify the uncertainty of the estimated correlation.

## Findings

- DANN increased the average probe confidence rather than reducing it, with a mean ΔConfidence of **+0.2226**, indicating that subject identity information was generally not suppressed.
- The average improvement in LOSO accuracy after DANN was very small (**ΔLOSO = +0.0070**), suggesting minimal overall benefit from adversarial training.
- The correlation between changes in probe confidence and changes in LOSO accuracy was weak and negative (**r = -0.1433**).
- The relationship was **not statistically significant** (permutation **p = 0.5414**).
- The bootstrap confidence interval **[-0.615, +0.366]** crossed zero, indicating substantial uncertainty regarding the direction and magnitude of the relationship.

## Conclusion

- No evidence was found that changes in subject identity encoding after DANN were associated with improvements in cross-subject LOSO performance.
- The DANN intervention did not consistently reduce subject-specific representations across subjects.
- Consequently, this analysis does **not support a causal relationship** between DANN-induced changes in identity leakage and cross-subject generalisation performance for the BiLSTM model.

# Block 5C.6 — Negative Control: Label Entropy

## What this block does

- Performs a negative control analysis to verify that any observed relationships between representation geometry and cross-subject performance are not simply caused by differences in fatigue label distributions across subjects.
- Computes the Shannon entropy of the fatigue class distribution for each subject as a measure of label diversity.
- Correlates per-subject label entropy with LOSO accuracy using a permutation-based Spearman correlation test.
- Compares the strength of this annotation-based relationship with the representation-based silhouette score to determine whether representation geometry provides stronger explanatory power.
- Uses bootstrap confidence intervals to quantify uncertainty in the estimated correlation.

## Findings

- The average label entropy across subjects was **1.1245 ± 0.2638**, indicating moderate variability in fatigue label distributions.
- Label entropy showed a **very weak negative correlation** with LOSO accuracy (**r = -0.0727**).
- This relationship was **not statistically significant** (permutation **p = 0.7530**).
- The bootstrap confidence interval **[-0.582, +0.425]** included zero, indicating no reliable association between label entropy and LOSO performance.
- Compared with the silhouette score (**r = +0.2883**), label entropy exhibited a substantially weaker relationship with LOSO accuracy.

## Conclusion

- The negative control successfully demonstrated that subject-level label distribution alone does not explain cross-subject generalisation performance.
- Representation geometry showed a stronger relationship with LOSO accuracy than the annotation-based control variable, despite not reaching statistical significance.
- These findings indicate that the observed representation geometry effects are unlikely to be confounded by differences in fatigue label distributions across subjects, supporting the validity of the Stage 5C representation-based analyses.

# Block 5C.8 — Per-Subject Ranked Summary Table

## What this block does

- Produces a comprehensive per-subject summary table by ranking all 21 subjects from the hardest to the easiest according to LOSO accuracy.
- Combines every major metric computed throughout Stage 5C into a single table, including:
  - LOSO accuracy
  - Balanced accuracy
  - Generalisation gap
  - Silhouette score
  - Probe confidence
  - Centroid distance
  - Label entropy
- Categorises subjects into **Low**, **Mid**, and **High** leakage groups using silhouette score tertiles.
- Summarises the average LOSO accuracy within each leakage tier to evaluate whether subjects with stronger representation leakage consistently exhibit poorer cross-subject performance.
- Saves the ranked summary as a CSV file for inclusion in supplementary material or further statistical analysis.

## Findings

- The ranked table revealed substantial variability in LOSO performance across the 21 subjects, ranging from **0.0859** to **0.8215**.
- Subjects were evenly divided into three leakage tiers (Low, Mid, High), each containing seven subjects.
- Average LOSO accuracy differed across the leakage tiers:
  - **Low leakage:** 0.3102 ± 0.2325
  - **Mid leakage:** 0.4228 ± 0.2356
  - **High leakage:** 0.4927 ± 0.2504
- Contrary to the original hypothesis, the **High leakage** group achieved the highest average LOSO accuracy, while the **Low leakage** group exhibited the lowest average performance.
- The ranked table showed that both high- and low-performing subjects were distributed across different leakage tiers, indicating no consistent ordering between silhouette-based leakage and cross-subject performance.

## Conclusion

- The per-subject ranking did not reveal a monotonic relationship between representation leakage and LOSO accuracy.
- Subjects with higher silhouette-based leakage were **not consistently harder** to generalise to; in fact, the highest leakage tier showed the highest average LOSO accuracy.
- These observations agree with the earlier correlation and regression analyses, which found no statistically significant subject-level relationship between representation geometry and cross-subject performance in the BiLSTM model.
- The ranked summary therefore serves primarily as a descriptive overview of subject-level variability rather than evidence supporting subject-level prediction of LOSO generalisation from representation leakage metrics.

# Block 5C.9 — Final Statistics Table and Overall Verdict

## What this block does

- Consolidates all Stage 5C statistical results into a single publication-ready summary table.
- Reports the Spearman correlation coefficient, bootstrap 95% confidence interval, permutation-based p-value, statistical significance, and effect size for every predictor–outcome relationship.
- Identifies the strongest representation-based predictor of LOSO accuracy based on the largest absolute correlation coefficient.
- Compares this strongest predictor against the negative control (label entropy) to evaluate whether representation geometry provides greater explanatory power than annotation properties.
- Automatically generates an overall interpretation of the Stage 5C analysis based on the combined statistical evidence.
- Saves the final statistics table, publication-quality figure, and ranked per-subject summary table for inclusion in the dissertation or research paper.

## Findings

- None of the representation geometry metrics significantly predicted LOSO accuracy at the subject level.
- The strongest relationship with LOSO accuracy was observed for **intra-subject cosine similarity** (**r = +0.2909**), but this relationship was **not statistically significant** (permutation **p = 0.1987**).
- The negative control (**label entropy**) exhibited an even weaker relationship with LOSO accuracy (**r = -0.0727**, **p = 0.7530**), indicating that annotation properties contributed very little to cross-subject performance differences.
- All bootstrap confidence intervals for LOSO correlations included zero, reflecting considerable uncertainty in the estimated effects.
- No representation geometry metric reached statistical significance for LOSO accuracy, balanced accuracy, or generalisation gap.
- The final outputs—including the publication figure, statistics table, and ranked subject table—were successfully generated and saved.

## Conclusion

- The comprehensive Stage 5C analysis found **no statistically significant per-subject predictor** of cross-subject LOSO performance for the BiLSTM architecture.
- Although some representation geometry metrics exhibited small-to-moderate effect sizes, none demonstrated reliable predictive power under permutation testing.
- The weaker correlation of the negative control compared with the representation metrics supports the validity of the analysis, but the evidence remains insufficient to establish a subject-level relationship between representation geometry and LOSO accuracy.
- Overall, the results suggest that while subject identity leakage exists (as established in Stage 5A), the **degree of leakage does not vary sufficiently across subjects to explain individual differences in cross-subject generalisation performance** for the BiLSTM model.
- These findings are consistent with either limited statistical power due to the small sample size (N = 21) or a relatively uniform distribution of subject identity leakage across participants, making subject-level prediction of LOSO performance difficult.

