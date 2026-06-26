# Stage 0: Dataset audit — verify the data is what we think it is before building anything on top of it

## Block1: 
<br>
Simply loading the dataset, checking number of .mat files <br>
Datasets: EEG_Features_5bands, perclos_labels

This block checks for all .mat files and stores them in a list mat_files. 
46 Rows (.md files)

## Block2: <br>
Checks the sample .mat file from the list. Like mat_files[0] <br>
Python Opens the file like you double click an excel file. <br>
Finds the number of variables of the mat file. Variables can be understood as subsheets in an excel workbook. <br>
Detailed inspection: <br>
  <br> psd_movingAve: shape=(17, 885, 5)
  <br> psd_LDS: shape=(17, 885, 5)
  <br> de_movingAve: shape=(17, 885, 5)
  <br> de_LDS: shape=(17, 885, 5)


Why are there four variables?

The researchers extracted two different kinds of EEG features:

PSD (Power Spectral Density)
DE (Differential Entropy)

For each, they also produced two processed versions:

Moving Average smoothing, 
LDS (Linear Dynamical System) smoothing
<br>
purpose of Block 0.2 was simply to answer these questions:

<br>✅ Can we successfully open a .mat file?
<br>✅ What variables ("worksheets") are inside it?
<br>✅ Which variable should we use for our research?
<br>✅ What is its data shape?

You now know the answer: use de_LDS with shape (17, 885, 5) as your EEG feature data

## Block3:<br>
conclusion after Block 0.3

At this stage we can confidently write:

<br>✅ The EEG feature files are consistent across subjects.
<br>✅ Each session contains four precomputed feature representations.
<br>✅ The Differential Entropy feature (de_LDS) has dimensions (17, 885, 5) corresponding to 17 EEG channels, 885 temporal windows, and 5 frequency bands.
<br>✅ No labels are embedded within the EEG feature files; PERCLOS labels are stored separately.

## Block3.5: <br>
Inspecting one file from perclos_labels to find the features of that file. <br>
This file contains only 1 variable; perclos<br>
shape=(885,) means there are 885 PERCLOS values.<br>

<br>The PERCLOS label files contain a single variable named perclos, which stores the ground-truth fatigue labels.
<br>Each label file contains exactly 885 continuous PERCLOS values, matching the 885 EEG samples for that subject.
<br>The labels are continuous values (approximately 0.1–0.8) rather than pre-classified fatigue classes.
<br>Each PERCLOS value corresponds to one EEG feature sample, confirming a one-to-one mapping between features and labels.
<br>The dataset follows the SEED-VIG paper, where PERCLOS is used as the objective measure of driver fatigue.
<br>The continuous PERCLOS values can later be converted into Awake, Tired, and Drowsy classes using standard thresholds if required.
<br>The successful inspection confirms that the label files are correctly structured and ready to be paired with the EEG feature files for model development.

## Block 4: <br>
You can use the following checklist for your notebook after **Block 0.4**.

* ✅ Successfully matched **23 EEG feature files** with their corresponding **23 PERCLOS label files**.<br>
* ✅ Each EEG session now has its correct PERCLOS labels associated with it.<br>
* ✅ EEG features (`de_LDS`) were loaded successfully from all sessions.<br>
* ✅ PERCLOS labels were loaded successfully from all sessions.<br>
* ✅ EEG feature tensors were reshaped from **(17, 885, 5)** to **(885, 85)** for machine learning compatibility.<br>
* ✅ All sessions were synchronized so that each feature vector corresponds to the correct label.<br>
* ✅ Continuous PERCLOS values were preserved as the ground truth (`labels_raw`).<br>
* ✅ Discrete fatigue classes (Awake, Tired, Drowsy) were generated from PERCLOS for later classification experiments.<br>
* ✅ Subject IDs and session IDs were extracted from filenames for future LOSO (Leave-One-Subject-Out) evaluation.<br>
* ✅ A master `sessions` dataset was successfully created, containing features, labels, and metadata for every subject.<br>
* ✅ The dataset is now fully organized and ready for exploratory analysis and Stage 1 baseline model development.<br>

These conclusions clearly summarize what Block 0.4 accomplished and are suitable to keep as documentation in your notebook.

## Block 5: <br>
✅ Confirmed that SEED-VIG provides continuous PERCLOS values, not pre-classified fatigue labels.<br>
✅ Each session contains 885 unique PERCLOS values, representing a continuous fatigue progression.<br>
✅ PERCLOS values range approximately from 0.11 to 0.80, covering awake to drowsy states.<br>
✅ Continuous PERCLOS values were converted into three fatigue classes using standard thresholds (Awake, Tired, Drowsy).<br>
✅ Both continuous (labels_raw) and discrete (labels_discrete) labels were preserved for future analysis.<br>
✅ The dataset shows a reasonably balanced class distribution, making it suitable for model training and evaluation.<br>
✅ No fatigue class is severely underrepresented, reducing concerns about class imbalance.<br>
✅ The dataset is now prepared for both regression (continuous PERCLOS) and classification (three fatigue classes) experiments.<br>

## Block 6: <br>
This block checks whether the ground truth PERCLOS labels are naturally smooth or noisy over time, before training any machine learning model.

This is important because your research focuses on temporal inconsistency. If the dataset labels themselves fluctuate randomly, then inconsistent model predictions may simply reflect noisy labels rather than a model weakness.

To measure this, the block computes four metrics:

<br>Decrease Rate: Measures how often the fatigue level suddenly decreases from one time step to the next. A lower value indicates a smoother fatigue progression.
<br>Monotonicity Deviation: Measures how far the fatigue trajectory is from a perfectly increasing sequence. Lower values indicate a more monotonic (smooth) progression.
<br>Local Consistency: Compares each label with its neighboring labels. Values close to 1 indicate that nearby labels are highly consistent with each other.
<br>Sessions with High Irregularity: Counts how many sessions have excessive backward transitions (>30%), identifying unusually noisy recordings.

Together, these metrics determine whether the ground truth labels are reliable enough to study temporal inconsistency in machine learning models.

✅ Block 0.6 Conclusions<br>
✅ Evaluated the temporal smoothness of the ground truth PERCLOS labels before model development.<br>
✅ The average decrease rate (0.008) is extremely low, indicating fatigue rarely decreases over time.<br>
✅ The average monotonicity deviation (0.251) shows that fatigue trajectories are generally smooth with only minor natural variations.<br>
✅ The local consistency score (0.999) confirms that neighboring labels are highly consistent throughout the sessions.<br>
✅ None of the 23 sessions exhibited excessive temporal irregularity (>30% decrease rate).<br>
✅ The SEED-VIG ground truth labels are temporally stable and not inherently noisy.<br>
✅ Any temporal inconsistency observed in future model predictions is therefore more likely to originate from the model rather than the dataset itself.<br>
✅ The dataset is suitable for investigating temporal inconsistency as a genuine model limitation.<br>
<br>

## Block 7: <br>
Conclusions<br>
✅ Visualized six representative fatigue trajectories from the SEED-VIG dataset.<br>
✅ Included sessions spanning the full range of irregularity scores for comparison.<br>
✅ Observed that fatigue generally progresses smoothly over time across subjects.<br>
✅ The smoothed trajectories closely follow the original labels, indicating minimal noise.<br>
✅ Visual inspection supports the numerical findings from Block 0.6 regarding temporal stability.<br>
✅ Ground truth trajectory plots were successfully saved for future analysis and documentation.<br>
<br>

✅ Final Conclusions — Stage 0: Dataset Audit<br>
✅ Successfully explored and understood the complete structure of the SEED-VIG dataset.<br>
✅ Verified that EEG features and PERCLOS labels are correctly paired for all sessions.<br>
✅ Prepared a clean master dataset suitable for subsequent preprocessing and model development.<br>
✅ Confirmed that the ground truth fatigue labels are reliable and temporally stable.<br>
✅ Established confidence that Stage 1 (Baseline Model Training) can proceed on a scientifically validated dataset.<br>
✅ Completed the dataset audit without identifying any critical issues that would invalidate the planned temporal inconsistency research.<br>
