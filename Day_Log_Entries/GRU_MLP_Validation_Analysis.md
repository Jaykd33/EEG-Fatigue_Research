GRU Validation Study

After completing the GRU-based fatigue detection pipeline on the SEED-VIG dataset, a complete validation study was performed to verify whether the relatively 
low Leave-One-Subject-Out (LOSO) accuracy was caused by implementation errors or by genuine cross-subject generalization difficulty. The purpose of this 
validation was to thoroughly check every stage of the pipeline before proceeding towards a new research direction.

The first step was to verify the integrity of the dataset and preprocessing pipeline. The original DE-LDS features were reshaped from 17 channels, 885 timesteps and 
5 frequency bands into 85-dimensional feature vectors for every timestep. Several checks were performed to ensure that the feature ordering remained correct and
that no mismatch occurred between EEG features and labels during preprocessing. Variance analysis and feature-time correlation checks did not reveal any 
abnormalities. All integrity checks passed successfully, confirming that the dataset loading and preprocessing stages were functioning correctly.

The next step was to validate the LOSO evaluation protocol. The dataset contains 23 sessions belonging to 21 subjects, with subjects 4 and 5 contributing two 
sessions each. The validation confirmed that every subject was used as a test subject exactly once and that multi-session subjects were held out completely 
during testing. Although the validation script initially displayed a failure warning because subjects 4 and 5 appeared twice in the results, further inspection 
showed that both sessions were correctly held out together. Therefore, the LOSO implementation was confirmed to be correct and free from subject leakage.

Feature normalization was then examined. The StandardScaler was fitted only on training subjects and subsequently applied to the unseen test subject. The training 
data achieved a mean close to zero and a standard deviation close to one after normalization, while the test subject retained different statistical properties. 
This confirmed that no information from the test subject was used during scaling. The analysis also revealed noticeable distribution shifts between training and 
test subjects, suggesting substantial inter-subject variability in EEG features.

Prediction behaviour was then analysed to determine whether the model was producing meaningful outputs. The GRU predicted all three fatigue classes throughout 
evaluation and did not collapse to a single dominant class. The overall LOSO accuracy achieved by the model was 42.8%. The prediction distribution was reasonably
close to the true class distribution, indicating that the model learned meaningful decision boundaries. However, performance varied considerably between subjects.
The best-performing subject achieved an accuracy of 87.6%, while the worst-performing subject achieved only 4.3%. This large variation suggested that some 
subjects generalize well whereas others remain highly challenging.

To determine whether the low LOSO accuracy was caused by a faulty implementation or genuine cross-subject difficulty, a within-subject experiment was conducted. 
In this experiment, the model was trained and tested using data from the same individual. The average within-subject accuracy reached 83.2%, compared to only 
42.8% under LOSO evaluation. This corresponds to an average performance gap of 40.4 percentage points. Several subjects exhibited extremely large gaps, including 
Subject 19 with a 95.7% gap and Subject 17 with an 86.6% gap. These results demonstrate that the model is capable of learning fatigue patterns effectively, but 
the learned representations often fail to transfer to unseen individuals. Therefore, the low LOSO performance is not caused by a bug in the implementation but 
rather by genuine cross-subject generalization difficulty.

A literature comparison was also conducted to understand the discrepancy between our results and published SEED-VIG papers. Most recent works report subject-
dependent or intra-subject accuracies rather than strict LOSO performance. When the GRU was evaluated under a subject-dependent protocol, it achieved 81.7% 
accuracy. This result is substantially closer to published values such as AMD-GCN at approximately 89.9% and DeltaGateNet at approximately 81.9%. The comparison 
showed that a large portion of the performance gap originates from differences in evaluation methodology rather than implementation issues.

Overall, the validation study confirms that the GRU pipeline is correct and scientifically sound. No evidence of data leakage, preprocessing mistakes or 
implementation errors was found. The model achieved 42.8% LOSO accuracy and 83.2% within-subject accuracy, revealing a substantial 40.4% performance gap.
The most important conclusion is that fatigue recognition itself is not the primary challenge; rather, the dominant challenge is transferring learned fatigue
representations across unseen subjects. This finding motivates future work on improving cross-subject generalization rather than focusing solely on classifier
accuracy.


MLP Validation Study

After completing the MLP-based fatigue detection pipeline on the SEED-VIG dataset, a comprehensive validation study was performed to determine whether the 
relatively low Leave-One-Subject-Out (LOSO) accuracy was caused by implementation errors or by genuine cross-subject generalization difficulty. The objective 
of this validation was to systematically verify every component of the pipeline before proceeding toward a new research direction.

The first step was to verify the integrity of the dataset and preprocessing pipeline. The original DE-LDS features were reshaped from 17 channels, 885 timesteps
and 5 frequency bands into 85-dimensional feature vectors for each timestep. Multiple checks were conducted to ensure that the feature ordering remained correct 
and that the labels were properly aligned with the EEG features throughout preprocessing. Variance analysis and feature-time correlation checks did not reveal any
abnormalities. All data integrity checks passed successfully, confirming that the dataset loading and preprocessing stages were functioning correctly.

The next step was to validate the LOSO evaluation protocol. The dataset consists of 23 sessions belonging to 21 unique subjects, with subjects 4 and 5 contributing
two sessions each. The validation confirmed that every subject was used as a test subject exactly once and that all sessions belonging to a particular subject 
were held out together during testing. Although the validation script initially displayed a failure warning because subjects 4 and 5 appeared twice in the results, 
further inspection showed that this was expected behaviour due to their multiple sessions. No subject overlap was observed between training and testing folds. 
Therefore, the LOSO implementation was confirmed to be correct and free from subject leakage.

Feature normalization was then examined to ensure that no information from the test subject leaked into the training process. The StandardScaler was fitted
exclusively on training subjects and then applied to the unseen test subject. The training data achieved a mean close to zero and a standard deviation close to 
one after scaling, while the test subject maintained different statistical characteristics. This confirmed that the scaler had not seen the test data during 
fitting. The analysis also revealed noticeable distribution shifts between training and testing subjects, indicating significant inter-subject variability within 
the dataset.

The prediction behaviour of the MLP model was then analysed. The model produced predictions across all three fatigue classes and did not collapse to a single 
dominant class. The predicted class distribution was 34.0% Awake, 42.2% Tired and 23.7% Drowsy, which was reasonably close to the true dataset distribution of 
36.4% Awake, 43.7% Tired and 19.9% Drowsy. The overall LOSO accuracy achieved by the MLP was 41.6%. While the model performed better than random guessing, 
performance varied substantially across subjects. The best-performing subject achieved an accuracy of 85.3%, while the worst-performing subject achieved only 1
0.3%. The standard deviation of subject-level accuracies was 20.0%, indicating considerable variability in how well the model generalized across individuals.

To determine whether the low LOSO accuracy was caused by a faulty implementation or genuine cross-subject difficulty, a within-subject experiment was performed. 
In this experiment, the model was trained and tested using data from the same individual. The average within-subject accuracy reached 83.2%, compared to only 41.6%
under LOSO evaluation. This corresponds to an average performance gap of 41.6 percentage points. Several subjects exhibited extremely large gaps between 
within-subject and LOSO performance. Subject 17 showed a gap of 89.7%, Subject 20 showed a gap of 77.9%, Subject 19 showed a gap of 73.8%, and Subject 2 showed 
a gap of 74.4%. These findings demonstrate that the MLP can successfully learn fatigue-related patterns when training and testing occur on the same person. 
However, the learned representations often fail to transfer effectively to unseen subjects. Therefore, the low LOSO accuracy is not caused by implementation 
errors but by genuine cross-subject generalization difficulty.

A literature comparison was then conducted to understand the difference between our results and those reported in recent SEED-VIG studies. Most published works 
evaluate models using subject-dependent or intra-subject protocols rather than strict LOSO evaluation. To enable a fair comparison, a subject-dependent evaluation
was performed using the same MLP model. Under this setting, the model achieved an accuracy of 81.7%, compared to only 41.6% under LOSO evaluation. Published 
methods such as AMD-GCN report approximately 89.9% subject-dependent accuracy, while DeltaGateNet reports approximately 81.9% intra-subject accuracy and 55.6% 
inter-subject accuracy. The comparison showed that a major portion of the apparent performance gap originates from differences in evaluation methodology rather 
than implementation issues. The remaining difference can largely be attributed to architectural improvements used by modern graph-based and transformer-based 
approaches.

Overall, the validation study confirms that the MLP pipeline is correct and scientifically sound. No evidence of data leakage, preprocessing mistakes or implementation
errors was found. The model achieved 41.6% LOSO accuracy and 83.2% within-subject accuracy, resulting in a performance gap of 41.6 percentage points. The most 
important conclusion is that fatigue recognition itself is not the primary challenge in SEED-VIG. Instead, the dominant challenge is transferring learned fatigue 
representations across unseen subjects. This finding strongly suggests that future work should focus on improving cross-subject generalization rather than solely
attempting to improve classifier accuracy.
