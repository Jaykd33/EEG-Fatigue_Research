DeltaGateNet: Bidirectional Temporal Dynamics Modeling for EEG-based Driving Fatigue Recognition

1) Problem being solved:
Driving fatigue is a major cause of traffic accidents. Detecting it reliably in real time is hard because existing EEG-based methods have three specific weaknesses the paper targets directly:
EEG signals are strongly non-stationary — fatigue builds slowly and irregularly, not as a sudden state transition.
Fatigue-related brain dynamics are asymmetric — neural activation (arousal decline) and suppression (compensatory activation) do not follow symmetrical temporal patterns. Existing models ignore this.
Practical systems use limited EEG channels (wearables), so spatial information is scarce — robust channel-specific temporal modeling is needed.
Most prior architectures use amplitude-based features or generic temporal modeling and do not explicitly model the bidirectionality of neural changes or preserve channel-wise independence.

2) Datasets used:

SEED-VIG
23 subjects (11 M, 12 F, avg age 23.3 yr), virtual driving environment, ~120 min per trial, 17 EEG channels, 200 Hz, Fatigue label - PERCLOS (eye-tracking), 3 classes: awake (0–0.35), tired (0.35–0.7), drowsy (0.7–1.0) · 885 samples per trial, each 8 seconds.

SADT 2022 (balanced)
27 subjects, simulated driving up to 90 min, 30 EEG channels, 128 Hz, Label - reaction time to lane deviation, 2 classes (alert / drowsy), 2,022 samples from 11 subjects, 3 seconds per sample.

SADT 2952 (unbalanced)
Same protocol as SADT 2022, 2,952 samples from 11 subjects, 3 seconds per sample. Tests robustness to class imbalance.

3) Model Architecture: 

Stage 1
Bidirectional Delta
Computes first-order temporal difference Δx(t) = x(t) − x(t−1). Splits via ReLU into positive (Δ⁺) and negative (Δ⁻) components. Concatenates along channel dim → shape B×2C×T. No learnable parameters.

Stage 2
Gated Temporal Conv
1×1 depthwise projection to hidden dim D. Two residual blocks each with: 1D depthwise conv then BatchNorm then GELU gate then 1×1 channel mix then Dropout. Temporal average pooling and finally, per-channel LayerNorm.

Stage 3
Multilayer Perceptron
Flattens pooled features. Three blocks of Linear then BatchNorm then LeakyReLU then Dropout. Softmax output and finally k class probabilities (3 for SEED-VIG, 2 for SADT).

4) Result/Accuracy:

SEED-VIG
81.89% ±0.66 - F1 82.55%

SADT 2022
96.81% ±2.58 - F1 96.81%

SADT 2952
96.84% ±1.43 - F1 96.77%

5) Limitations mentioned by the authors:

- Inter-subject accuracy on SEED-VIG is only 55.55% — substantially lower than intra-subject (81.89%), showing that cross-subject generalization remains a major unsolved challenge.
- The framework does not incorporate multimodal physiological signals (e.g., ECG, EOG, GSR) — only EEG is used as input.
- The method does not integrate environmental context (road conditions, lighting, time-of-day) alongside physiological data.
- The model is evaluated only on two public datasets; real-world deployment with fully naturalistic driving data is not tested.
- The Bidirectional Delta module captures only first-order temporal differences (step size S=1); higher-order dynamics are not modeled.
- Transformer and large deep learning models underperform simpler time-series models on these datasets — the authors note that model size/depth does not directly correlate with performance on EEG fatigue data, suggesting the community may be over-investing in complexity.