# Stage 1

## Block 1.1: 
Load Stage 0 Output

What this block does?

Loads the processed dataset generated in Stage 0.<br>
Retrieves EEG features, PERCLOS labels, and metadata for all sessions.<br>
Verifies that every EEG feature vector has a corresponding fatigue label.<br>
Ensures the data is ready for baseline model training.<br>


Conclusions<br>
✅ Successfully loaded 23 recording sessions from Stage 0.<br>
✅ Each EEG sample contains 85 features (17 channels × 5 frequency bands).<br>
✅ Labels are continuous PERCLOS values (discrete labels are also available for classification).<br>
✅ Data integrity check passed, confirming no mismatch between features and labels.<br>
✅ The dataset is correctly prepared for LOSO baseline model training.<br>
<br>

## Block 1.2: Feature Normalization Strategy

What this block does?

Groups all recording sessions according to their subject IDs.<br>
Prepares the dataset for Leave-One-Subject-Out (LOSO) evaluation.<br>
Identifies how many sessions belong to each subject.<br>
Ensures feature normalization will later use only the training subjects, preventing data leakage.<br>

Conclusions<br>
✅ Identified 21 unique subjects for LOSO evaluation.<br>
✅ Total dataset contains 23 sessions, as Subjects 4 and 5 each have two sessions.<br>
✅ Every session contains 885 EEG time steps.<br>
✅ Subjects with two sessions contribute 1770 time steps, while the remaining subjects contribute 885 time steps each.<br>
✅ Dataset is correctly organized for subject-wise LOSO cross-validation without information leakage.<br>

Research Note (worth adding to your notebook)

This is actually a good sign. Since Subjects 4 and 5 have multiple sessions, your future temporal consistency analysis can also examine whether a model behaves consistently across different sessions of the same subject, which could become an interesting secondary observation in your paper. It's not your main contribution, but it's a useful point to keep in mind.



