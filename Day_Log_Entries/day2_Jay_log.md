##Day 2 Objectives Achieved

Jay-

1. MNE Exploration
2. Understadning EEG Preprocessing
   a) Bandpass Filtering: To remove unnecesary frequencies and have those frequencies from the 5 Bands Frequency range (0.5Hz-50hz).
   b) Notch Filtering: To remove powerline frequency
   c) Artifacts Removal: using ICA (Independant Component Analysis)
   d) Epoching: Breaking down large continous data into imp chunks as required
   e) Differential Entropy: the amount of randomness and complexity in the signal
   f) feature extraction table
3. Differential Entropy Basics
4. Rough Understanding of SEED VIG datset and SEED Family Dataset Ecosystem

---

Jay-

Before we explore MNE, we need to have a clear understanding of what a ‘Channel’ means. In very simple terms for every EEG recording electrode there is a channel. For example: if the sampling frequency is 600Hz that means, an electrode takes 600 measurements in 1 second.

### 10-20 system

```text
              FRONT OF HEAD (NOSE)
                        Fp1  Fpz  Fp2
                     F7  F3   Fz  F4  F8
                  T7    C3   Cz   C4    T8
                     P7  P3   Pz  P4  P8
                        O1   Oz   O2
               BACK OF HEAD (OCCIPITAL)
```

### Location Codes:

* Fp = Frontopolar (forehead)      → attention, executive function
* F  = Frontal                     → cognitive control, working memory
* C  = Central                     → motor processing
* T  = Temporal                    → auditory processing, memory
* P  = Parietal                    → spatial attention, sensory integration
* O  = Occipital                   → visual processing

# Channels most important for COGNITIVE FATIGUE detection:

```text
==================================================
Region: Frontal (Fp1, Fp2, F3, F4, Fz)
  Brain function: Prefrontal cortex — attention, executive function
  Fatigue signature: Theta power INCREASES as fatigue builds
  Why it matters: Frontal theta is the most consistent EEG marker of fatigue

==================================================
Region: Parietal (P3, Pz, P4)
  Brain function: Attention switching, sensory integration
  Fatigue signature: Alpha power INCREASES as vigilance drops
  Why it matters: Posterior alpha increase = task disengagement

==================================================
Region: Occipital (O1, Oz, O2)
  Brain function: Visual processing
  Fatigue signature: Alpha power increases when visual attention drifts
  Why it matters: Key indicator of visual fatigue in driving scenarios

==================================================
Region: Central (C3, Cz, C4)
  Brain function: Sensorimotor integration
  Fatigue signature: Beta power DECREASES (reduced motor readiness)
  Why it matters: Relevant for driving task — reduced reaction readiness
```

### SEED-VIG uses 17 channels:

```python
['FP1', 'F3', 'FZ', 'F4', 'FP2', 'T7', 'C3', 'CZ', 'C4', 'T8', 'P7', 'P3', 'PZ', 'P4', 'P8', 'OZ', 'O1']
```

Coverage: All major cognitive fatigue-relevant regions

```text
==================================================
```

MNE stands for Magnetoencephalography and electroencephalography (EEG). It’s an open source python package, which is used for exploring, visualizing and analysing human neurophysiological data including from EEG.

It provides tools for various stages of EEG data analysis, such as preprocessing, source estimation, time-frequency analysis, etc.

### Step 1) In CMD

```bash
pip install –upgrade mne
```

### Step 2) In Google Colab Notebook, install and import

```python
import mne
print("Version of MNE:",mne.__version__)
```

**O/P:** Version of MNE: 1.12.1

---

# PART) Preprocessing:

## A. Artifacts

It is any electrical activity/ signal that does not originate from the brain.

Because the electrical signals from the brain are so incredibly tiny, the EEG electrodes easily pick up other, stronger electrical fields by accident.

Physiological artifacts come from your own body. For example, your eyes act like little batteries, so blinking or moving your eyes creates a massive electrical wave that distorts the data.

Muscle contractions (like clenching your jaw) or your heartbeat also create electrical signals that get mixed into the EEG.

Environmental artifacts come from the outside world. These include interference from the room's power lines, the patient moving, or a loose electrode wire popping.

The primary goal of preprocessing is to identify and remove these artifacts so they aren't mistaken for real brain waves.

### Methods:

**ICA (Independent Component Analysis):** Your EEG channels all pick up the same eye blink — because eye blink electrical activity spreads across the scalp. ICA is a mathematical technique that "unmixes" the signals, separating:

* brain activity
* eye activity
* muscle activity

into independent components.

WE then identify which components are eye blinks (not brain), and remove them. The remaining components are reconstructed back into channel space — this is artifact-cleaned EEG.

---

## B. Epoching

When we record an EEG, we may have a huge continuous file that is an hour long. Epoching is process of chopping the continuous dataset in manageable chunks of time-epochs.

### Reason for preprocessing:

```text
RAW EEG SIGNAL = TRUE BRAIN SIGNAL
                 + Eye blink artifacts (large spikes, 0–4 Hz)
                 + Muscle artifacts (high frequency, 30–100+ Hz)
                 + Electrode movement artifacts (DC shifts)
                 + Powerline interference (50 Hz in India / Europe)
                 + Amplifier drift (very slow baseline wander < 0.1 Hz)

Our job: Keep the brain signal. Remove everything else.
```

---

## C. Differential Entropy

### What is Differential Entropy (Diff Entropy)?

In simple terms, entropy is a mathematical measurement of chaos, randomness, or complexity in a signal. Differential Entropy (DE) is a specific formula used to calculate this complexity in continuous, wavy signals like EEGs.

If a brain wave is highly complex, unpredictable, and carries a lot of active information, its Differential Entropy score will be higher. If the wave is very rhythmic, synchronized, and slow, its Differential Entropy score will be lower.

### Why Diff Entropy is Crucial for EEG and Fatigue ?

Note that extracting statistical features and complexity measures from EEG data allows machine learning algorithms to successfully classify different mental states, such as whether a person is concentrating, relaxed, or mentally fatigued.

Diff Entropy is widely considered one of the absolute best features for this exact task.

### Here is why it is so relevant to datasets like SEED-VIG:

#### Tracking the "Idling" Brain:

As we established earlier, when you are highly alert, your brain actively processes information using fast, complex, unsynchronized Beta waves.

This highly active state produces a high Differential Entropy score.

#### The Fatigue Shift:

As cognitive fatigue sets in, the brain transitions into an "idling" state, replacing those complex Beta waves with slower, highly rhythmic, and synchronized Theta waves.

Because the signal becomes slower and more predictable, the Differential Entropy score drops.
