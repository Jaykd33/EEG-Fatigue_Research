# Block 5C — Stage Introduction and Experimental Framework

## What this block does

- Introduces the redesigned **Stage 5C**, whose primary objective is to investigate whether the degree of subject identity encoded in the learned representation space predicts cross-subject generalisation performance.
- Shifts the focus from simply demonstrating the presence of subject identity leakage (already established in Stages 5A, 5B, and 5RC) to quantitatively evaluating its impact on LOSO performance at the individual subject level.
- Defines a geometry-based analysis framework that uses continuous representation-space metrics (e.g., silhouette score, probe confidence) instead of saturated probe recall values, enabling meaningful per-subject statistical analysis.
- Specifies the architecture-specific inputs required from previous stages while ensuring that the remaining analysis pipeline is architecture-independent and reusable across MLP, BiLSTM, and GRU models.
- Establishes the statistical methodology for the stage, including permutation testing, bootstrap confidence intervals, and multiple linear regression, providing more robust inference than conventional parametric tests for the small sample size.
- Serves as the methodological foundation for all subsequent analyses performed in Stage 5C.

## Findings

- This introductory block does not execute any computations or produce experimental results.
- No statistical analyses, numerical outputs, or visualisations are generated at this stage.
- The block formally defines the experimental hypothesis, required inputs, and statistical framework that will guide the remainder of the geometry-based subject leakage analysis.

## Conclusion

- Establishes a redesigned, statistically rigorous framework for analysing subject identity leakage at the per-subject level.
- Replaces the limitations of the previous probe recall-based analysis with continuous geometry-based leakage metrics that are better suited for correlation and regression analyses.
- Provides a common, architecture-independent methodology that enables fair comparison of subject leakage behaviour across the MLP, BiLSTM, and GRU models.
- Forms the conceptual and methodological foundation for investigating whether subject identity leakage contributes to cross-subject generalisation failure.

# Block 5C.0 — Imports, Configuration, and Per-Subject Data Assembly

## What this block does

- Imports all scientific computing, statistical analysis, machine learning, and visualisation libraries required for the redesigned Stage 5C.
- Initializes the random number generator using a fixed seed to ensure reproducibility of all subsequent statistical analyses.
- Aggregates the LOSO classification results from Stage 1 to compute the average LOSO accuracy for each subject.
- Computes the **balanced accuracy** for every subject, providing a class-balanced performance metric that is less sensitive to class imbalance than overall accuracy.
- Aggregates within-subject evaluation results from Stage 4 to obtain the average within-subject classification accuracy for each subject.
- Retrieves the per-subject LOSO accuracies obtained after DANN training (Stage 5B) and calculates the corresponding performance improvement or degradation relative to the baseline LOSO model.
- Constructs a unified per-subject DataFrame containing all baseline performance metrics required for the remainder of Stage 5C, including LOSO accuracy, balanced accuracy, within-subject accuracy, generalisation gap, DANN performance, and DANN performance change.

## Findings

- Successfully assembled a complete per-subject dataset containing **21 subjects**, providing one observation per subject for all subsequent statistical analyses.
- DANN performance results were available for **all 21 subjects**, allowing direct comparison between baseline and adversarially trained models.
- LOSO accuracy varied substantially across subjects, ranging from **0.1028 (Subject 17)** to **0.8531 (Subject 3)**, demonstrating considerable inter-subject variability in cross-subject generalisation.
- Within-subject accuracies were consistently much higher than LOSO accuracies for most subjects, resulting in noticeable generalisation gaps and reinforcing the challenge of cross-subject fatigue recognition.
- The effect of DANN was highly heterogeneous across subjects. Several subjects showed substantial improvements (e.g., Subject 2: **+0.5797**, Subject 13: **+0.4983**, Subject 18: **+0.4102**), whereas others experienced noticeable performance degradation (e.g., Subject 3: **−0.3548**, Subject 6: **−0.1955**, Subject 10: **−0.1910**).

## Conclusion

- Successfully established a comprehensive subject-level dataset that serves as the foundation for all subsequent geometry-based leakage analyses.
- Confirmed substantial variability in cross-subject generalisation performance across the 21 subjects, providing sufficient outcome variability for subject-level statistical modelling.
- Demonstrated that DANN does not affect all subjects uniformly, suggesting that subject-specific characteristics may influence the effectiveness of adversarial domain adaptation.
- Provides the complete baseline performance metrics against which representation geometry and subject identity leakage will be analysed in the subsequent blocks of Stage 5C.

# Block 5C.1 — Per-Subject Representation Geometry Metrics

## What this block does

- Computes continuous, geometry-based subject identity leakage metrics directly from the learned representation space without training any additional models.
- Normalises all learned representations to unit length so that cosine similarity and Euclidean distance describe the same underlying representation geometry.
- Uniformly subsamples up to **200 windows per subject** to ensure balanced and computationally efficient distance calculations.
- Computes three complementary per-subject representation geometry metrics:
  - **Silhouette Score:** Measures how compact and well-separated each subject's representation cluster is relative to other subjects.
  - **Intra-subject Cosine Similarity:** Measures how consistently windows from the same subject cluster together in the representation space.
  - **Centroid Distance:** Measures how far each subject's representation centroid lies from the average centroid of all remaining subjects, replacing the previous MMD metric with a simpler and fully reproducible distance measure.
- Integrates all geometry metrics into the per-subject analysis DataFrame for use in subsequent statistical correlation analyses.

## Findings

- Successfully computed geometry-based leakage metrics for **all 21 subjects**, providing continuous subject-level measures even when probe accuracy reaches saturation.
- Silhouette scores showed substantial inter-subject variability, ranging from **−0.1314 to 0.3572**, with an average of **0.0294 ± 0.1185**, indicating that some subjects form much more distinct representation clusters than others.
- Intra-subject cosine similarity remained consistently high across subjects (**mean = 0.7350 ± 0.0683**), demonstrating that representations belonging to the same subject are generally compact and internally consistent.
- Centroid distances also varied noticeably (**mean = 0.4191 ± 0.0718**), showing that certain subjects occupy representation regions much farther from the overall population than others.
- Subjects **7, 2, and 9** exhibited the highest silhouette scores, indicating the strongest subject-specific separation within the learned representation space.
- Subjects **4, 18, and 1** showed the lowest silhouette scores, indicating greater overlap with other subjects despite still maintaining relatively high intra-subject consistency.

## Conclusion

- Successfully replaced the saturated per-subject probe recall metric with continuous geometry-based leakage measures capable of distinguishing the degree of subject identity encoding across individual subjects.
- Confirmed that subject identity is not encoded equally across all subjects; instead, substantial variability exists in representation compactness and subject separability.
- Established silhouette score, cosine similarity, and centroid distance as robust subject-level leakage metrics for all subsequent correlation, regression, and statistical analyses performed in Stage 5C.
- Provides the quantitative representation geometry needed to investigate whether stronger subject identity encoding is associated with poorer cross-subject generalisation performance.

# Block 5C.2 — Per-Subject Probe Confidence (Continuous Leakage Measure)

## What this block does

- Computes a continuous measure of subject identity leakage based on the confidence of the trained subject classifier rather than simple classification accuracy.
- Re-runs the Stage 5A subject probe using a single deterministic 80/20 stratified train-test split to obtain calibrated softmax probability scores for every test window.
- Records, for each test window, the probability assigned to its true subject class and averages these probabilities separately for each subject.
- Produces a per-subject **probe confidence** metric that quantifies how confidently the learned representations identify each individual subject.
- Adds the probe confidence values to the per-subject analysis DataFrame for use in later correlation and regression analyses.

## Findings

- Successfully computed probe confidence scores for **all 21 subjects**.
- Probe confidence was consistently very high across all subjects, with a **mean of 0.9836 ± 0.0088**.
- Confidence values ranged from **0.9660 to 0.9964**, indicating only modest variation in the strength of subject identity encoding between individuals.
- Every subject exhibited confidence scores dramatically higher than the random baseline (**0.0476**), confirming extremely strong subject discrimination throughout the learned representation space.
- Subject **19** showed the highest probe confidence (**0.9964**), while Subject **21** showed the lowest (**0.9660**), although even the lowest value still reflects highly confident subject identification.

## Conclusion

- Confirms that the learned representations encode subject identity with extremely high confidence for every subject, not merely high classification accuracy.
- Provides a continuous leakage metric that captures subtle differences in identity encoding strength despite saturated probe accuracy.
- Demonstrates that subject identity is strongly embedded across the entire representation space, with only small variability between subjects.
- Supplies an additional quantitative predictor for subsequent analyses investigating the relationship between subject identity encoding and cross-subject generalisation performance.

- # Block 5C.3 — Core Correlation Analysis with Permutation Tests

## What this block does

- Performs the primary statistical analysis of Stage 5C by evaluating whether subject identity leakage metrics are associated with cross-subject generalisation performance.
- Correlates four representation geometry metrics (silhouette score, probe confidence, intra-subject cosine similarity, and centroid distance) with three performance outcomes (LOSO accuracy, balanced accuracy, and generalisation gap).
- Uses **10,000-permutation Spearman correlation tests** to obtain robust, distribution-free significance estimates suitable for the small sample size (21 subjects).
- Computes **10,000-bootstrap 95% confidence intervals** for every correlation coefficient to quantify estimation uncertainty.
- Produces a comprehensive statistical table summarising correlation coefficients, confidence intervals, permutation p-values, significance levels, and effect sizes for all predictor–outcome pairs.

## Findings

- **Silhouette score** showed no significant correlation with LOSO accuracy or balanced accuracy, but demonstrated a **moderate positive trend** with generalisation gap (*r* = +0.3948, *p* = 0.0802), suggesting that subjects with more separated representation clusters may experience larger cross-subject performance drops.
- **Probe confidence** emerged as the strongest predictor among all evaluated metrics:
  - Showed a **significant negative correlation** with balanced accuracy (*r* = −0.5377, permutation *p* = 0.0130).
  - Showed a **significant positive correlation** with generalisation gap (*r* = +0.4714, permutation *p* = 0.0359).
  - Displayed a moderate negative relationship with LOSO accuracy (*r* = −0.3247), although this did not reach statistical significance.
- **Intra-subject cosine similarity** exhibited only weak, non-significant relationships with all performance metrics.
- **Centroid distance** also showed weak, non-significant correlations with LOSO accuracy, balanced accuracy, and generalisation gap.
- Bootstrap confidence intervals generally remained wide, reflecting the uncertainty expected with a sample size of only 21 subjects.

## Conclusion

- Probe confidence was identified as the **most informative continuous measure of subject identity leakage**, outperforming the geometry-only metrics in predicting cross-subject generalisation behaviour.
- Subjects whose representations were recognised with higher confidence tended to exhibit **lower balanced accuracy** and **larger generalisation gaps**, providing quantitative evidence that stronger subject identity encoding is associated with poorer cross-subject generalisation.
- Silhouette score showed only marginal evidence of predicting generalisation gap, while cosine similarity and centroid distance contributed little predictive value.
- Overall, the results support the hypothesis that **the strength of subject identity encoding—particularly classifier confidence—is associated with reduced cross-subject generalisation performance**, although larger datasets would improve statistical certainty.

# Block 5C.4 — Joint OLS Regression

## What this block does

- Performs a multivariate analysis to determine the independent contribution of each representation geometry metric after controlling for the remaining predictors.
- Simultaneously models the effects of **silhouette score**, **probe confidence**, **intra-subject cosine similarity**, and **centroid distance** on each cross-subject performance outcome.
- Standardises all predictors and outcomes so that regression coefficients (β) are directly comparable across variables.
- Computes overall model fit using **R²** and **adjusted R²**.
- Uses **10,000-permutation tests** to obtain robust significance estimates for each regression coefficient without relying on normality assumptions.

## Findings

### LOSO Accuracy
- The regression model explained **20.4%** of the variance in LOSO accuracy (**R² = 0.204**), although the adjusted R² (**0.005**) indicated limited predictive power after accounting for model complexity.
- None of the four representation metrics independently predicted LOSO accuracy after controlling for the others.
- Silhouette score exhibited the largest negative regression coefficient (β = −0.5486), but this relationship was not statistically significant.

### Balanced Accuracy
- The regression model explained **47.2%** of the variance in balanced accuracy (**R² = 0.472**, adjusted **R² = 0.340**).
- **Probe confidence** was the **only significant independent predictor** of balanced accuracy (β = −0.5943, permutation *p* = 0.0068).
- Higher probe confidence was associated with lower balanced accuracy, indicating that stronger subject identity encoding negatively affects balanced cross-subject performance.
- Silhouette score, cosine similarity, and centroid distance did not contribute significant independent effects.

### Generalisation Gap
- The regression model explained **54.0%** of the variance in generalisation gap (**R² = 0.540**, adjusted **R² = 0.425**).
- **Probe confidence** showed a **marginal positive association** with generalisation gap (β = +0.4307, *p* = 0.0626).
- Silhouette score produced the largest positive regression coefficient (β = +0.6901), although it did not achieve statistical significance.
- Cosine similarity and centroid distance showed negligible independent effects.

## Conclusion

- Probe confidence emerged as the **strongest independent predictor** of cross-subject generalisation performance among all representation geometry metrics.
- After accounting for the overlap between predictors, stronger subject identity encoding remained significantly associated with reduced balanced accuracy and showed a marginal relationship with increased generalisation gap.
- The remaining geometry metrics contributed little additional explanatory power once probe confidence was included in the regression model.
- These findings reinforce the conclusion that **the confidence with which representations encode subject identity is the most informative indicator of cross-subject generalisation behaviour**.

- # Block 5C.5 — Cross-Stage Causal Analysis (DANN Delta Correlation)

## What this block does

- Performs the strongest causal analysis in Stage 5C by leveraging the intervention introduced through Stage 5B (DANN adversarial training).
- Computes, for every subject, the change in subject identity encoding after DANN using the difference in probe confidence (**ΔProbe Confidence**).
- Computes the corresponding change in cross-subject performance using the difference in LOSO accuracy (**ΔLOSO Accuracy**).
- Correlates these within-subject change scores using permutation-based Spearman correlation and bootstrap confidence intervals.
- Tests whether subjects experiencing greater reductions in subject identity leakage after DANN also experience greater improvements in cross-subject generalisation.

## Findings

- DANN successfully reduced subject identity encoding on average, with a **mean probe confidence reduction of −0.0339**.
- DANN also produced an overall improvement in cross-subject performance, with a **mean LOSO accuracy increase of +0.0771**.
- However, the relationship between leakage reduction and LOSO improvement was **very weak and non-significant**:
  - **Spearman correlation:** *r* = −0.0675
  - **95% Bootstrap CI:** [−0.508, +0.398]
  - **Permutation p-value:** 0.7711
- The confidence interval spanned both positive and negative values, indicating substantial uncertainty regarding the direction of the relationship.

## Conclusion

- Although DANN reduced subject identity encoding overall and improved average LOSO performance, these improvements did **not occur consistently at the individual subject level**.
- Subjects exhibiting larger reductions in identity leakage were **not consistently the same subjects** showing larger improvements in cross-subject generalisation.
- Consequently, this analysis **does not provide evidence for a direct causal relationship** between per-subject identity leakage reduction and per-subject LOSO improvement.
- The results suggest that while DANN benefits the model overall, **additional subject-specific factors beyond identity leakage likely influence cross-subject generalisation performance.**

# Block 5C.6 — Negative Control: Label Entropy

## What this block does

- Performs a negative control analysis to test whether the observed relationships between representation geometry and cross-subject performance could simply arise from unrelated subject-level characteristics.
- Computes the **fatigue label entropy** for each subject, measuring how balanced the Awake, Tired, and Drowsy labels are within that subject.
- Correlates per-subject label entropy with LOSO accuracy using **permutation-based Spearman correlation** and **bootstrap confidence intervals**.
- Compares the strength of the label entropy relationship against the primary representation-based metric (silhouette score) to evaluate potential confounding effects.
- Serves as a validity check for the Stage 5C interpretation by examining whether an annotation-based property predicts cross-subject performance as strongly as representation geometry.

## Findings

- The average fatigue label entropy across subjects was **1.1245 ± 0.2638**, indicating moderate variability in class balance between subjects.
- Label entropy showed a **moderate positive correlation** with LOSO accuracy:
  - **Spearman correlation:** *r* = +0.3766
  - **95% Bootstrap CI:** [−0.109, +0.714]
  - **Permutation p-value:** 0.0904 (marginal significance)
- The correlation between label entropy and LOSO accuracy was **stronger than the silhouette–LOSO correlation** observed earlier (*r* = −0.2818, *p* = 0.2206).
- Consequently, the negative control did **not clearly separate** annotation effects from representation geometry effects.

## Conclusion

- The negative control **did not fully support** the interpretation that representation geometry alone explains cross-subject generalisation performance.
- Fatigue label distribution showed a relationship with LOSO accuracy that was comparable to—or stronger than—the silhouette-based leakage metric.
- This suggests that **subject-specific label imbalance may partially confound the relationship between representation geometry and cross-subject performance.**
- Therefore, the interpretation of silhouette score as an independent predictor of cross-subject generalisation should be made cautiously, acknowledging that annotation characteristics may also contribute to observed performance differences.

# Block 5C.7 — Publication-Quality Six-Panel Correlation Figure

## What this block does

- Generates a **publication-quality six-panel figure** that visually summarizes all major findings from Stage 5C.
- Creates scatter plots with **subject-level annotations**, **ordinary least squares (OLS) regression lines**, and **95% bootstrap confidence intervals** for every relationship.
- Displays the corresponding **Spearman correlation coefficient** and **permutation-test p-value** directly on each subplot.
- Compares the primary representation geometry metric (silhouette score) against multiple performance measures and benchmark metrics.
- Includes a **negative control (label entropy)** to visually compare annotation-related effects with representation-based effects.
- Saves the complete figure for inclusion in the research paper.

## Findings

- **Panel A:** Silhouette score showed a weak negative relationship with LOSO accuracy, indicating that subjects with more distinct representation clusters tended to generalize slightly worse, although the relationship was not statistically significant.
- **Panel B:** Silhouette score exhibited only a weak relationship with balanced accuracy, suggesting that representation geometry alone was not a strong predictor of balanced classification performance.
- **Panel C:** Silhouette score demonstrated the strongest visual relationship with generalisation gap, showing a positive trend where more separated subject representations tended to correspond to larger generalisation gaps. This relationship reached marginal significance.
- **Panel D:** Centroid distance displayed only weak association with LOSO accuracy, indicating that simple distribution shift between subject centroids was not a major determinant of cross-subject performance.
- **Panel E:** Probe confidence showed a moderate negative trend with LOSO accuracy, supporting the observation that stronger subject-identifiable representations tended to reduce cross-subject generalisation, although the relationship was not statistically significant for LOSO accuracy.
- **Panel F:** Label entropy exhibited a moderate positive relationship with LOSO accuracy, performing similarly to or stronger than silhouette score, suggesting that subject-specific label distributions may also influence cross-subject performance.

## Conclusion

- The six-panel visualization provides a comprehensive graphical summary of the relationships between **representation geometry**, **subject identity leakage**, **distribution shift**, and **cross-subject generalisation**.
- Representation geometry metrics showed consistent directional trends with LOSO performance, but most relationships remained statistically weak because of the limited sample size (21 subjects).
- The strongest evidence was observed for the association between silhouette score and generalisation gap, supporting the hypothesis that more subject-specific representations tend to widen the gap between within-subject and cross-subject performance.
- The negative control demonstrated that label distribution characteristics also contribute to LOSO variability, indicating that both **representation geometry** and **dataset characteristics** should be considered when interpreting cross-subject generalisation behaviour.
- Overall, the figure visually consolidates the statistical analyses performed throughout Stage 5C and serves as the primary publication-ready summary of the geometry-based subject leakage analysis.

# Block 5C.8 — Per-Subject Ranked Summary Table

## What this block does

- Ranks all **21 subjects** from the hardest to the easiest to generalize based on their LOSO accuracy.
- Combines every important per-subject metric into a single publication-ready table, including LOSO accuracy, balanced accuracy, generalisation gap, silhouette score, probe confidence, centroid distance, and label entropy.
- Categorizes subjects into **Low**, **Mid**, and **High** identity leakage groups using silhouette-score tertiles instead of the previous probe recall metric.
- Computes and reports the average LOSO accuracy within each leakage tier to provide an overall comparison between groups.
- Saves the ranked summary table as a CSV file for inclusion in the paper or supplementary material.

## Findings

- All 21 subjects were successfully ranked according to their cross-subject generalisation performance.
- Silhouette scores varied across subjects, allowing meaningful separation into Low, Mid, and High leakage groups.
- The **High leakage** group achieved the lowest average LOSO accuracy (**0.3835**), followed by the **Mid leakage** group (**0.4155**), while the **Low leakage** group achieved the highest average LOSO accuracy (**0.4490**).
- Subjects with the poorest LOSO performance generally exhibited larger generalisation gaps, indicating substantial degradation when moving from within-subject to cross-subject evaluation.
- Considerable variability remained within each leakage tier, showing that identity leakage alone does not fully explain differences in subject-wise generalisation performance.

## Conclusion

- The ranked summary table provides a comprehensive per-subject overview of representation geometry and generalisation behaviour.
- Stratifying subjects using silhouette-score tertiles produces a meaningful leakage-based grouping that replaces the previous constant probe recall metric.
- Although the High leakage group demonstrated the lowest average LOSO accuracy, the differences between groups were moderate rather than definitive.
- These results support the observation that stronger subject-specific representation geometry tends to be associated with poorer cross-subject generalisation, while also indicating that additional subject-specific factors contribute to overall performance variability.
- The table serves as a concise publication-ready summary of all per-subject metrics generated throughout Stage 5C.

# Block 5C.9 — Final Statistics Table and Overall Verdict

## What this block does

- Consolidates all Stage 5C statistical results into a single publication-ready summary table.
- Summarizes every predictor–outcome relationship with its Spearman correlation coefficient, bootstrap 95% confidence interval, permutation-test p-value, statistical significance, and effect size.
- Automatically identifies the strongest predictor of LOSO accuracy among all evaluated representation geometry metrics.
- Compares the strongest representation-based predictor against the negative control (label entropy) to assess whether representation geometry provides stronger explanatory power than dataset characteristics.
- Generates an automated evidence-based verdict summarizing the overall findings of Stage 5C.
- Saves the final statistics table and references all generated outputs for inclusion in the research paper.

## Findings

- **Probe confidence** emerged as the strongest predictor of LOSO accuracy (**r = -0.3247**), although the relationship was **not statistically significant** (permutation p = **0.1581**).
- **Probe confidence** showed a **significant negative correlation** with balanced accuracy (**r = -0.5377**, p = **0.0130**) and a **significant positive correlation** with the generalisation gap (**r = +0.4714**, p = **0.0359**).
- **Silhouette score** demonstrated a moderate positive association with the generalisation gap (**r = +0.3948**), reaching marginal significance (p = **0.0802**), but did not significantly predict LOSO accuracy.
- Neither centroid distance nor intra-subject cosine similarity significantly predicted LOSO accuracy or the generalisation gap.
- The negative control (**label entropy**) showed a moderate correlation with LOSO accuracy (**r = +0.3766**, p = **0.0904**), indicating that subject-specific label distributions also contribute to differences in cross-subject performance.
- The strongest statistically reliable relationships were observed for **balanced accuracy** and **generalisation gap**, rather than raw LOSO accuracy.

## Conclusion

- Stage 5C demonstrates that **representation geometry is more strongly associated with the generalisation gap than with absolute LOSO accuracy**.
- Identity leakage does not significantly predict raw cross-subject accuracy at the individual-subject level, but it is associated with the increase in performance loss when moving from within-subject to cross-subject evaluation.
- Probe confidence emerged as the most informative leakage metric, providing the strongest evidence that more subject-specific representations correspond to poorer generalisation characteristics.
- The influence of the negative control suggests that dataset-specific factors, such as label distribution, also affect cross-subject performance and should be considered alongside representation geometry.
- Overall, Stage 5C refines the interpretation established in Stage 5A by showing that while subject identity leakage is clearly present, its per-subject variation primarily explains **generalisation degradation** rather than absolute LOSO accuracy.
- The publication-ready statistics table and automated verdict provide a comprehensive summary of the geometry-based subject leakage analysis for the paper.
  
