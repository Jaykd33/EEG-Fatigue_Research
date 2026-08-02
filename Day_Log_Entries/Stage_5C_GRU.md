# Stage 5C – Investigating Why Some Subjects Generalize Better Than Others

## Objective

After completing Stages 5A, 5B and 5RC, we had already established that subject identity leakage exists, originates from the raw DE features, and cannot be removed using Domain-Adversarial Neural Networks (DANN). However, one major question still remained unanswered.

If every subject exhibits strong identity leakage, why do some subjects achieve excellent LOSO performance (around 88%) while others perform extremely poorly (around 4%)?

The purpose of Stage 5C was to investigate whether any measurable subject-level property could explain this large variation in cross-subject performance.

Rather than introducing another model, this stage focused on analyzing the characteristics of each subject and determining whether those characteristics were related to the observed LOSO accuracy.

---

# Block 5C.2 – Label Distribution Shift Analysis

The first hypothesis was that some subjects might simply have a very different distribution of fatigue labels compared to the overall dataset.

To test this, the Total Variation Distance (TVD) was computed for every subject. TVD measures how different a subject's class distribution is from the overall population distribution.

The global class distribution of the dataset was:

- Awake: 36.4%
- Tired: 43.7%
- Drowsy: 19.9%

Each subject's label distribution was then compared against this global distribution.

For example, Subject 7 contained approximately 85% Tired samples and very few Awake or Drowsy samples, making it very different from the overall dataset. Such subjects obtained high TVD values, indicating a large distribution shift.

The relationship between TVD and LOSO accuracy was then analyzed using Spearman correlation, permutation testing, and bootstrap confidence intervals.

The results were:

- Spearman correlation = -0.3156
- Permutation p-value = 0.1662
- Bootstrap 95% Confidence Interval = [-0.4419, 0.4274]

Although the negative correlation suggests that subjects with larger label distribution shifts tend to have lower LOSO accuracy, the relationship was not statistically significant.

### Conclusion

Label distribution shift alone does not explain why certain subjects are difficult to generalize to. While there is a weak trend, the evidence is insufficient to conclude that differences in class proportions are responsible for the large variation in LOSO performance.

---

# Block 5C.3 – Representation Geometry Analysis

The second hypothesis was that some subjects might have cleaner or better-separated feature representations than others.

To investigate this, the latent representations produced by the trained GRU model were extracted for every subject. Three representation quality metrics were then computed:

- Mean Pairwise Centroid Distance (MPCD)
- Silhouette Score
- Fisher Discriminant Ratio (FDR)

These metrics measure how well the fatigue classes are separated in the learned feature space.

For each metric, its relationship with LOSO accuracy was evaluated using Spearman correlation, permutation testing, and bootstrap confidence intervals.

The results were:

### Mean Pairwise Centroid Distance (MPCD)

- Spearman correlation = 0.0818
- p-value = 0.7244

### Silhouette Score

- Spearman correlation = -0.0545
- p-value = 0.8143

### Fisher Discriminant Ratio (Representation FDR)

- Spearman correlation = -0.0714
- p-value = 0.7583

All confidence intervals contained zero and none of the metrics showed any statistically significant relationship with LOSO accuracy.

### Conclusion

The quality of the learned representation does not explain cross-subject performance differences.

Subjects with highly separated latent representations were not necessarily classified well, while some subjects with poorer representations still achieved high LOSO accuracy.

This indicates that representation geometry is not the primary factor governing subject-wise generalization performance.

---

# Block 5C.4 – Combined Predictor Analysis

Although none of the individual predictors showed significant correlations, it was still possible that a combination of predictors could jointly explain LOSO accuracy.

To investigate this, a multiple regression model was constructed using:

- Fisher Discriminant Ratio (FDR)
- Total Variation Distance (TVD)
- Mean Pairwise Centroid Distance (MPCD)

These three variables were jointly used to predict LOSO accuracy.

The regression analysis produced:

- Observed R² = 0.0088

Bootstrap analysis (10,000 iterations) was performed to estimate the stability of the regression coefficients.

None of the standardized regression coefficients were statistically significant, and every confidence interval crossed zero.

Partial correlation analysis also showed no significant relationship after controlling for the remaining predictors.

### Conclusion

Even when combined, these measurable subject-level properties explain less than 1% of the variation in LOSO accuracy.

This demonstrates that the large differences observed across subjects cannot be attributed to label distribution shift, feature separability, or representation geometry.

---

# Block 5C.5 – Final Visualization

The final figure summarized all findings from Stage 5C.

The visualization compared:

- Subject identity leakage
- Label distribution shift
- Representation geometry
- LOSO accuracy

This figure clearly demonstrated that although identity leakage is consistently present across all subjects, none of the measured data properties explain why some subjects generalize successfully while others fail.

The figure serves as the primary evidence supporting the conclusions of Stage 5C and is intended to be included directly in the research paper.

---

# Overall Findings from Stage 5C

Stage 5C attempted to explain the large variation in cross-subject LOSO performance by investigating multiple measurable characteristics of each subject.

Three independent hypotheses were tested:

1. Label distribution shift (TVD)
2. Representation geometry (MPCD, Silhouette Score, FDR)
3. A combined statistical model incorporating all predictors

None of these analyses produced statistically significant relationships with LOSO accuracy.

The strongest observed trend was for TVD (ρ = -0.3156), but this remained non-significant with a permutation p-value of 0.1662.

The combined regression model achieved an R² of only 0.0088, indicating that these predictors collectively explain virtually none of the variability in subject performance.

These findings demonstrate that the observed differences in LOSO accuracy cannot be explained by simple statistical properties of the data or by the geometry of the learned representations.

---

# Final Conclusion of Stage 5C

Stage 5C completes the investigation into the causes of cross-subject performance variation.

Previous stages established that subject identity leakage exists, originates in the raw DE features, and cannot be removed through representation-level adversarial learning.

Stage 5C extends these findings by showing that commonly measured subject-level characteristics—including label distribution shift, feature separability, and representation geometry—also fail to explain why certain subjects generalize well while others do not.

Taken together, these results indicate that cross-subject generalization failure in EEG fatigue detection is not driven by simple distributional differences or representation quality.

Instead, the remaining variation likely reflects deeper subject-specific neural characteristics that are not captured by current aggregate statistical measures.

This finding suggests that future improvements in cross-subject EEG fatigue detection may require fundamentally different approaches, such as subject-specific adaptation, personalized modeling, or feature-level disentanglement, rather than relying solely on representation-level domain adaptation techniques.
