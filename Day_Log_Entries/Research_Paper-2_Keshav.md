"A regression method for EEG-based cross-dataset fatigue detection" (Frontiers Physiology 2023, PMC10266210)

Problem Statement:
How to build an EEG-based fatigue/drowsiness detection model that works on a completely new, unlabeled dataset (different subjects, different fatigue-inducing task, different electrode layout) without retraining or collecting large amounts of new labeled data — a problem the authors state had not been previously studied in the fatigue-detection literature.
Motivation
Fatigue causes dangerous errors in jobs requiring sustained attention (drivers, pilots, helmsmen). Existing within-subject and cross-subject EEG fatigue models work well but still require large labeled datasets for every new dataset/task they encounter — resource-consuming and impractical for real deployment. Additionally, fatigue is physiologically a continuous, gradually-evolving process (awake → high workload → fatigue → drowsiness), so the authors argue it should be modeled as regression, not the discrete classification used by most prior work.

Dataset:
SEED: 23 subjects, simulated daytime driving, 18 EEG channels (12 posterior + 6 temporal), labels via PERCLOS (eye-tracking-based), 3 classes (awake/fatigue/drowsy).
Multi-channel dataset (Cao et al. 2019): 27 subjects, 90-min night-time sustained-attention driving, 32 EEG channels, labels via reaction-time-derived Drowsiness Index, same 3-class scheme.
Channels matched one-to-one between datasets (17 common channels used); EEG segments sized 17×1024.

Methodology:
Pipeline: raw filtered EEG → (1) Pre-training with a domain-classification pretext task → (2) Domain-specific adaptation combining MMD-based distribution alignment with MLP-based fatigue-index regression.
Preprocessing: 1–50 Hz FIR filtering, downsampling to 128 Hz, channel matching, random-offset segmentation.
Features: no hand-crafted features — raw (filtered) EEG segments fed directly into the deep network.
Model: ResNet50 backbone + CBAM attention (channel + spatial) + GRU for temporal modeling, trained with combined MSE + α·MMD loss.

Key Innovation:
First study specifically targeting cross-dataset (not cross-subject) EEG fatigue detection.
Reframes fatigue detection as regression rather than classification.
Combines a self-supervised domain-discrimination pretext task with MMD-based domain alignment, attention, and recurrent temporal modeling — a more elaborate pipeline than the SVR/DE-feature approach used in the Zheng & Lu (2016) paper.

Results:
SEED→multi-channel: Accuracy 59.10%, RMSE 0.27 (best direction).
Multi-channel→SEED: Accuracy 45.21%, RMSE 0.29.
Outperforms TCA, MIDA, InstanceEasyTL, DDA, and ADAST on every metric in both directions.
Ablations show pre-training is critical for detecting the "drowsy" class specifically; GRU is critical for regression smoothness (RMSE).
With 10% labeled target data, accuracy rises to 66.21%.

Limitations (author-stated):
Untested generalization to non-driving fatigue causes (e.g., sleep deprivation).
Accuracy (59.10%) considered "a little low" by the authors themselves — partly attributed to imperfect/noisy ground-truth labels (PERCLOS, RT-derived DI).
Reaction-time-based fatigue labeling needs further methodological development.

Future Work (author-stated):
Investigate cross-dataset fatigue detection across genuinely different fatigue-inducing tasks (not just different driving paradigms).
