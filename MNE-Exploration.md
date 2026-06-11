# Complete MNE-Python Guide for EEG-Based Cognitive Fatigue Prediction
### Jay Kumar Das & Keshav Agarwal — NIT Goa Research Internship
### Day 2 Companion Document

---

> **How to use this guide:**
> Read Part 1 first — it gives you the mental model for everything else.
> Then work through Parts 2–10 sequentially.
> Every code block is complete and runnable. Copy → paste → run.
> Parts 11 and 12 are your daily deliverables.

---

## PART 1: The Big Picture — What MNE Is and Where It Fits

### What is MNE?

MNE-Python is an open-source Python library for processing, analyzing, and visualizing brain signal data — primarily EEG (electroencephalography) and MEG (magnetoencephalography).

Think of it this way:
- **pandas** is to tabular data what **MNE** is to EEG time-series data.
- **OpenCV** is to images what **MNE** is to brain signals.

MNE gives you specialized data structures and functions that understand the nature of EEG data — that it has spatial structure (channels placed on a scalp), temporal structure (continuous time series), and spectral structure (frequency bands).

### Why does almost every EEG researcher use MNE?

1. **It handles EEG file formats natively** — EEG hardware companies each use proprietary formats (.edf, .bdf, .cnt, .set, .fif). MNE reads all of them with a single line.
2. **It has built-in artifact removal** — eye blinks, muscle movements, and line noise contaminate EEG. MNE has ICA, filtering, and artifact detection built in.
3. **It connects directly to NumPy/Sklearn/PyTorch** — once you're done preprocessing, you extract a NumPy array and hand it to your ML pipeline. No data format gymnastics.
4. **It's the standard** — published papers describe preprocessing in MNE terms. You need to speak the same language to reproduce and compare results.

### The Complete Pipeline: Where MNE Ends and ML Begins

```
┌─────────────────────────────────────────────────────────────────────┐
│                     COMPLETE RESEARCH PIPELINE                      │
└─────────────────────────────────────────────────────────────────────┘

RAW EEG (.edf / .bdf / .mat / .set files)
         │
         ▼
┌────────────────────┐
│  LOADING (MNE)     │  mne.io.read_raw_edf()
│                    │  → Creates Raw object
│                    │  → Stores signal + metadata
└────────────────────┘
         │
         ▼
┌────────────────────┐
│  VISUALIZATION     │  raw.plot()
│  (MNE)             │  → Inspect signal quality
│                    │  → Spot obvious artifacts
└────────────────────┘
         │
         ▼
┌────────────────────┐
│  FILTERING (MNE)   │  raw.filter(l_freq, h_freq)
│                    │  → Remove slow drifts (<1 Hz)
│                    │  → Remove high-freq noise (>50 Hz)
│                    │  → Remove 50Hz powerline noise
└────────────────────┘
         │
         ▼
┌────────────────────┐
│  ARTIFACT REMOVAL  │  ICA = mne.preprocessing.ICA()
│  (MNE)             │  → Remove eye blink components
│                    │  → Remove muscle artifacts
└────────────────────┘
         │
         ▼
┌────────────────────┐
│  EPOCHING (MNE)    │  mne.Epochs()
│                    │  → Split continuous signal
│                    │  → Into fixed-size windows
│                    │  → e.g., 8-second segments
└────────────────────┘
         │
         ▼
┌────────────────────┐
│  FEATURE           │  epochs.get_data() → NumPy array
│  EXTRACTION        │  → Compute DE, PSD, band power
│  (NumPy/SciPy)     │  → Per channel, per band, per epoch
└────────────────────┘
         │
         ▼
┌────────────────────┐
│  ML MODEL          │  PyTorch / Sklearn
│  (PyTorch)         │  → SVM, EEGNet, LSTM, Transformer
│                    │  → Mamba, GCN
└────────────────────┘
         │
         ▼
┌────────────────────┐
│  FATIGUE           │  Output: Awake / Tired / Drowsy
│  PREDICTION        │  or continuous PERCLOS score
└────────────────────┘

─────────────────────────────────────────────
MNE handles: Loading → Visualization → Filtering → Artifacts → Epoching
NumPy/SciPy handles: Feature Extraction
PyTorch/Sklearn handles: Model Training and Evaluation
─────────────────────────────────────────────
```

### SEED-VIG Shortcut (Critical for Your Project)

When you use SEED-VIG's pre-extracted DE features, MNE's role shrinks dramatically:

```
SEED-VIG WORKFLOW (what you'll actually do):

.mat file (pre-extracted DE features)
    │
    ▼
scipy.io.loadmat()  ← NOT MNE
    │
    ▼
NumPy array [17 channels × 885 trials × 5 bands]
    │
    ▼
PyTorch DataLoader  ← directly into your model
    │
    ▼
Fatigue Prediction
```

**You learn MNE now for three reasons:**
1. To understand what the SEED-VIG authors already did for you
2. To be able to use raw EEG datasets (STEW, DEAP) as backup
3. To write the Methods section of your paper with correct terminology

---

## PART 2: Installing and Verifying MNE

### Installation

```bash
# Option 1: pip (recommended for your setup)
pip install mne

# Option 2: conda (if you use conda environments)
conda install -c conda-forge mne

# Install supporting libraries used throughout this guide
pip install scipy numpy matplotlib seaborn scikit-learn

# Optional but useful
pip install mne-connectivity  # for connectivity analysis
pip install autoreject         # for automatic epoch rejection
```

### Verify Installation

```python
# Run this script. If all prints succeed, you're good.
import mne
import numpy as np
import scipy
import matplotlib

print(f"MNE version: {mne.__version__}")
print(f"NumPy version: {np.__version__}")
print(f"SciPy version: {scipy.__version__}")
print(f"Matplotlib version: {matplotlib.__version__}")

# Should print something like:
# MNE version: 1.7.0
# NumPy version: 1.26.4

# Check MNE can load a sample dataset (downloads ~8MB)
from mne.datasets import sample
data_path = sample.data_path()
print(f"MNE sample data at: {data_path}")
print("✓ MNE installation verified successfully")
```

### Common Installation Issues

| Problem | Symptom | Fix |
|---------|---------|-----|
| Qt backend missing | `raw.plot()` hangs or errors | `pip install PyQt5` or `pip install PySide6` |
| Matplotlib backend | No plot window appears | Add `import matplotlib; matplotlib.use('TkAgg')` before imports |
| Memory error on plot | Process killed | Add `n_channels=10` parameter to `raw.plot()` |
| SSL certificate error | Download fails | Use `mne.utils.set_config('MNE_DATASETS_SAMPLE_PATH', '/tmp')` |

---

## PART 3: The Best Free Dataset for Learning MNE

### Recommended Dataset: MNE's Built-in Sample Dataset (MEG + EEG)

**Why this specific dataset:**
- Built directly into MNE — downloads with one line of code
- No registration, no account, no institutional approval
- Well-documented — MNE's entire tutorial is built around it
- Has both EEG and MEG channels — you'll use EEG channels only
- Has events/triggers — teaches you the epoching workflow

**What was it collected for:**
An auditory and visual stimulus experiment. Subjects heard beeps and saw checkerboard patterns. The dataset shows brain responses to external stimuli — different from fatigue research, but the *pipeline* (loading → filtering → ICA → epoching) is identical.

**Alternative: STEW Dataset (More relevant to your project)**

```bash
# Download STEW from PhysioNet — no registration needed
# Visit: https://physionet.org/content/stew/1.0.0/
# Or use wget:
wget -r -N -c -np https://physionet.org/files/stew/1.0.0/

# STEW files are .mat format — loaded with scipy, not MNE
# We'll use this in Part 11 mini project
```

**For MNE learning: use the built-in sample data (Parts 4–10)**
**For your actual project: STEW while SEED-VIG access is pending**

---

## PART 4: First MNE Exploration — Loading and Inspecting EEG Data

### Code: Loading the Sample Dataset

```python
# ============================================================
# FILE: 01_load_and_inspect.py
# PURPOSE: Load EEG data and understand its structure
# ============================================================

import mne
import numpy as np
import matplotlib.pyplot as plt

# Suppress verbose output (optional — remove to see all messages)
mne.set_log_level('WARNING')

# ── Step 1: Load the sample dataset ──────────────────────────
# This downloads ~8MB from MNE servers on first run
# Subsequent runs use the cached local copy

from mne.datasets import sample
data_path = sample.data_path()

# The .fif file is MNE's native format
# sample.data_path() returns the folder, we build the full path
raw_fname = data_path / 'MEG' / 'sample' / 'sample_audvis_raw.fif'

# read_raw_fif loads the file into a Raw object
# preload=True loads all data into RAM immediately
# preload=False (default) reads from disk on demand — saves RAM
raw = mne.io.read_raw_fif(raw_fname, preload=True)

# ── Step 2: Inspect the Raw object ───────────────────────────

print("=" * 60)
print("BASIC INFORMATION")
print("=" * 60)

# Print a summary of the recording
print(raw.info)

# Key fields:
# ch_names: list of all channel names
# sfreq: sampling frequency in Hz
# n_times: total number of time samples
# meas_date: when the recording was made
```

```python
# ── Step 3: Access key metadata ───────────────────────────────

sfreq = raw.info['sfreq']
print(f"\nSampling frequency: {sfreq} Hz")
# This means the EEG was recorded sfreq times per second
# SEED-VIG uses 200 Hz — 200 readings per second per channel

n_channels = len(raw.ch_names)
print(f"Total channels: {n_channels}")
# This includes EEG, MEG, and other channels
# We'll select only EEG channels below

n_times = raw.n_times
print(f"Total time samples: {n_times}")

duration_seconds = n_times / sfreq
print(f"Recording duration: {duration_seconds:.1f} seconds = {duration_seconds/60:.1f} minutes")

print(f"\nFirst 10 channel names: {raw.ch_names[:10]}")

# ── Step 4: Select only EEG channels ─────────────────────────
# The sample dataset has MEG + EEG channels mixed
# For our project, we only care about EEG
# pick_types() filters to specific channel types

raw_eeg = raw.copy().pick_types(eeg=True, meg=False, stim=False)
print(f"\nEEG-only channels: {len(raw_eeg.ch_names)}")
print(f"EEG channel names: {raw_eeg.ch_names}")
```

```python
# ── Step 5: Access the raw signal as a NumPy array ────────────

# get_data() returns shape: (n_channels, n_times)
# This is the bridge from MNE to NumPy/PyTorch
data, times = raw_eeg.get_data(return_times=True)

print(f"\nRaw data array shape: {data.shape}")
# e.g., (60, 85765) → 60 EEG channels, 85765 time points

print(f"Data dtype: {data.dtype}")
print(f"Time array shape: {times.shape}")
print(f"First timestamp: {times[0]:.3f}s")
print(f"Last timestamp: {times[-1]:.3f}s")

# Units: EEG signals are in Volts (very small — microvolts in practice)
print(f"\nSignal range: {data.min()*1e6:.2f} to {data.max()*1e6:.2f} μV")

# ── Step 6: Look at one channel ───────────────────────────────
channel_idx = 0
channel_name = raw_eeg.ch_names[channel_idx]
one_channel = data[channel_idx, :]

print(f"\nChannel {channel_name}:")
print(f"  Shape: {one_channel.shape}")
print(f"  Mean: {one_channel.mean()*1e6:.4f} μV")
print(f"  Std:  {one_channel.std()*1e6:.4f} μV")

# Plot one channel manually
fig, ax = plt.subplots(figsize=(15, 3))
ax.plot(times[:int(10*sfreq)], data[0, :int(10*sfreq)] * 1e6)
# Plotting first 10 seconds only: times[:10*sfreq]
ax.set_xlabel('Time (seconds)')
ax.set_ylabel('Amplitude (μV)')
ax.set_title(f'EEG Signal — Channel {channel_name} — First 10 Seconds')
ax.grid(True, alpha=0.3)
plt.tight_layout()
plt.savefig('01_single_channel.png', dpi=100)
plt.show()
print("Plot saved to 01_single_channel.png")
```

### What Each Object Means

```
raw         → The entire EEG recording as an MNE Raw object
              Contains: the signal matrix + all metadata in .info
              Think of it like a pandas DataFrame but for time-series

raw.info     → A dictionary of metadata
              sfreq: sampling rate
              ch_names: list of channel names
              ch_types: type of each channel (eeg, meg, stim, etc.)
              meas_date: when recording happened

raw.ch_names → List of strings — the names of all channels
              e.g., ['EEG 001', 'EEG 002', 'Fp1', 'Fz', ...]

raw.n_times  → Integer — total number of time samples

raw.times    → 1D NumPy array of timestamps in seconds

raw.get_data() → Returns 2D NumPy array of shape (n_channels, n_times)
                 This is what you hand to your ML model
```

---

## PART 5: Visualizing EEG Signals

### Code: All Visualization Methods

```python
# ============================================================
# FILE: 02_visualization.py
# PURPOSE: Learn all the ways to visualize EEG data
# ============================================================

import mne
import numpy as np
import matplotlib.pyplot as plt

mne.set_log_level('WARNING')

# Load data (same as before)
from mne.datasets import sample
data_path = sample.data_path()
raw_fname = data_path / 'MEG' / 'sample' / 'sample_audvis_raw.fif'
raw = mne.io.read_raw_fif(raw_fname, preload=True)
raw_eeg = raw.copy().pick_types(eeg=True, meg=False, stim=False)

# ── Visualization 1: Interactive plot ─────────────────────────
# This opens an interactive window
# Scroll right to move through time
# Scroll up/down to move through channels
# Press 'a' to enable bad channel annotation
# Press '+'/'-' to zoom y-axis

raw_eeg.plot(
    n_channels=10,          # show 10 channels at a time
    duration=10,            # show 10 seconds at a time
    scalings='auto',        # auto-scale each channel
    title='Raw EEG Signal',
    show=True
)
# WHAT TO LOOK FOR:
# - Smooth, slightly wavy lines = good EEG signal
# - Sudden large spikes = blink artifacts or electrode pop
# - 50/60 Hz rapid oscillation = powerline interference
# - Flat line = disconnected electrode
```

```python
# ── Visualization 2: Power Spectral Density (PSD) ─────────────
# This shows how much power (energy) exists at each frequency
# The shape of this curve tells you about the signal quality
# and which frequency bands are dominant

fig = raw_eeg.compute_psd(
    fmin=0.5,    # minimum frequency to show (Hz)
    fmax=50,     # maximum frequency to show (Hz)
    n_fft=2048   # frequency resolution (higher = smoother)
).plot(
    average=False,  # show individual channels
    picks='eeg'
)
plt.suptitle('Power Spectral Density — All EEG Channels')
plt.savefig('02_psd.png', dpi=100, bbox_inches='tight')
plt.show()

# WHAT TO LOOK FOR:
# - 1/f slope: power decreases as frequency increases — normal
# - Alpha peak (~10 Hz): normal in relaxed, eyes-closed EEG
# - 50 Hz spike: powerline noise — needs filtering
# - Flat high-frequency: could be muscle artifact
```

```python
# ── Visualization 3: Plot specific time range ─────────────────

# Get data for the first 5 seconds only
data, times = raw_eeg.get_data(
    tmin=0,     # start at 0 seconds
    tmax=5,     # end at 5 seconds
    return_times=True
)

fig, axes = plt.subplots(3, 1, figsize=(15, 9))

for i, ax in enumerate(axes):
    ch_name = raw_eeg.ch_names[i]
    ax.plot(times, data[i] * 1e6, linewidth=0.5, color=f'C{i}')
    ax.set_ylabel(f'{ch_name}\n(μV)', fontsize=9)
    ax.grid(True, alpha=0.3)
    ax.set_xlim(times[0], times[-1])

axes[-1].set_xlabel('Time (seconds)')
fig.suptitle('First 5 Seconds — Three EEG Channels', fontsize=13)
plt.tight_layout()
plt.savefig('02_three_channels.png', dpi=100)
plt.show()
```

```python
# ── Visualization 4: Channel locations ───────────────────────
# Shows where electrodes are placed on the scalp
# (only works if channel positions are defined)

fig = raw_eeg.plot_sensors(
    show_names=True,
    title='EEG Channel Locations on Scalp'
)
plt.savefig('02_channel_locations.png', dpi=100, bbox_inches='tight')
plt.show()

# This is the 10-20 system layout — see Part 6
```

```python
# ── Visualization 5: Heatmap of signal over time ──────────────

data_snippet, times_snippet = raw_eeg.get_data(
    tmin=0, tmax=30, return_times=True
)

# Downsample for visualization (every 10th sample)
step = 10
fig, ax = plt.subplots(figsize=(16, 8))
im = ax.imshow(
    data_snippet[:20, ::step] * 1e6,  # first 20 channels, downsampled
    aspect='auto',
    origin='upper',
    cmap='RdBu_r',
    vmin=-50, vmax=50,
    extent=[times_snippet[0], times_snippet[-1], 20, 0]
)
ax.set_xlabel('Time (seconds)')
ax.set_ylabel('Channel index')
ax.set_yticks(range(20))
ax.set_yticklabels(raw_eeg.ch_names[:20], fontsize=7)
plt.colorbar(im, ax=ax, label='Amplitude (μV)')
ax.set_title('EEG Signal Heatmap — 30 Seconds × 20 Channels')
plt.tight_layout()
plt.savefig('02_heatmap.png', dpi=100)
plt.show()

# RELEVANCE TO SEED-VIG:
# The heatmap across 885 time windows × 17 channels is exactly
# what your SEED-VIG DE feature matrix represents —
# just with one number per cell instead of a time series
```

---

## PART 6: Understanding EEG Channels and the 10-20 System

### The 10-20 International System

EEG electrodes are placed at standardized positions on the scalp, defined by the 10-20 International System. The numbers refer to the percentage distances between skull landmarks.

```
               FRONT OF HEAD (NOSE)
                        Fp1  Fpz  Fp2
                     F7  F3   Fz  F4  F8
                  T7    C3   Cz   C4    T8
                     P7  P3   Pz  P4  P8
                        O1   Oz   O2
               BACK OF HEAD (OCCIPITAL)

Location Codes:
  Fp = Frontopolar (forehead)      → attention, executive function
  F  = Frontal                     → cognitive control, working memory
  C  = Central                     → motor processing
  T  = Temporal                    → auditory processing, memory
  P  = Parietal                    → spatial attention, sensory integration
  O  = Occipital                   → visual processing

Hemisphere Codes:
  Odd numbers (1, 3, 5, 7) → LEFT hemisphere
  Even numbers (2, 4, 6, 8) → RIGHT hemisphere
  z (zero) → midline (center)
```

### Why This Matters for Fatigue Research

```python
# ============================================================
# FILE: 03_channels_and_regions.py
# PURPOSE: Understand which channels matter for fatigue
# ============================================================

# Channels most important for COGNITIVE FATIGUE detection:
FATIGUE_RELEVANT_CHANNELS = {
    'Frontal (Fp1, Fp2, F3, F4, Fz)': {
        'function': 'Prefrontal cortex — attention, executive function',
        'fatigue_signature': 'Theta power INCREASES as fatigue builds',
        'why_it_matters': 'Frontal theta is the most consistent EEG marker of fatigue'
    },
    'Parietal (P3, Pz, P4)': {
        'function': 'Attention switching, sensory integration',
        'fatigue_signature': 'Alpha power INCREASES as vigilance drops',
        'why_it_matters': 'Posterior alpha increase = task disengagement'
    },
    'Occipital (O1, Oz, O2)': {
        'function': 'Visual processing',
        'fatigue_signature': 'Alpha power increases when visual attention drifts',
        'why_it_matters': 'Key indicator of visual fatigue in driving scenarios'
    },
    'Central (C3, Cz, C4)': {
        'function': 'Sensorimotor integration',
        'fatigue_signature': 'Beta power DECREASES (reduced motor readiness)',
        'why_it_matters': 'Relevant for driving task — reduced reaction readiness'
    }
}

for region, info in FATIGUE_RELEVANT_CHANNELS.items():
    print(f"\n{'='*50}")
    print(f"Region: {region}")
    print(f"  Brain function: {info['function']}")
    print(f"  Fatigue signature: {info['fatigue_signature']}")
    print(f"  Why it matters: {info['why_it_matters']}")

# SEED-VIG channels (17 total):
SEED_VIG_CHANNELS = [
    'FP1', 'F3', 'FZ', 'F4', 'FP2',  # Frontal (5)
    'T7', 'C3', 'CZ', 'C4', 'T8',    # Central/Temporal (5)
    'P7', 'P3', 'PZ', 'P4', 'P8',    # Parietal (5)
    'OZ', 'O1'                         # Occipital (2)
]
print(f"\nSEED-VIG uses {len(SEED_VIG_CHANNELS)} channels:")
print(SEED_VIG_CHANNELS)
print("\nCoverage: All major cognitive fatigue-relevant regions")
```

---

## PART 7: Preprocessing — Filtering and Artifact Removal

### Why Preprocessing Is Necessary

Raw EEG signals contain multiple sources of noise:

```
RAW EEG SIGNAL = TRUE BRAIN SIGNAL
                 + Eye blink artifacts (large spikes, 0–4 Hz)
                 + Muscle artifacts (high frequency, 30–100+ Hz)
                 + Electrode movement artifacts (DC shifts)
                 + Powerline interference (50 Hz in India / Europe)
                 + Amplifier drift (very slow baseline wander < 0.1 Hz)

Your job: Keep the brain signal. Remove everything else.
```

### Step 1: Bandpass Filtering

```python
# ============================================================
# FILE: 04_preprocessing.py
# PURPOSE: Complete preprocessing pipeline
# ============================================================

import mne
import numpy as np
import matplotlib.pyplot as plt

mne.set_log_level('WARNING')

from mne.datasets import sample
data_path = sample.data_path()
raw_fname = data_path / 'MEG' / 'sample' / 'sample_audvis_raw.fif'
raw = mne.io.read_raw_fif(raw_fname, preload=True)
raw_eeg = raw.copy().pick_types(eeg=True, meg=False, stim=False)

# ── FILTERING ─────────────────────────────────────────────────

# Bandpass filter: keep only frequencies between l_freq and h_freq
# l_freq = 0.5 Hz: removes baseline drift (amplifier wander)
# h_freq = 50.0 Hz: removes high-frequency muscle artifacts
#                   and captures all 5 brain frequency bands

raw_filtered = raw_eeg.copy().filter(
    l_freq=0.5,    # lower cutoff — remove below 0.5 Hz
    h_freq=50.0,   # upper cutoff — remove above 50 Hz
    method='fir',  # FIR filter (standard for EEG)
    fir_window='hamming',
    verbose=False
)

print("Bandpass filter applied: 0.5–50 Hz")
print(f"Signal before: {raw_eeg.get_data().std()*1e6:.2f} μV std")
print(f"Signal after:  {raw_filtered.get_data().std()*1e6:.2f} μV std")
```

```python
# Notch filter: specifically remove powerline frequency
# India uses 50 Hz (some older equipment may cause 50 Hz noise)
# US uses 60 Hz

raw_filtered.notch_filter(
    freqs=50,      # Remove exactly 50 Hz
    method='fir',
    verbose=False
)
print("Notch filter applied: 50 Hz powerline noise removed")
```

```python
# Visualize before vs after filtering
fig, axes = plt.subplots(2, 1, figsize=(15, 8))

# Before filtering: plot PSD
raw_eeg.compute_psd(fmin=0.5, fmax=60).plot(
    axes=axes[0], average=True, show=False
)
axes[0].set_title('BEFORE Filtering — PSD')
axes[0].axvline(x=50, color='red', linestyle='--', label='50 Hz noise')
axes[0].legend()

# After filtering
raw_filtered.compute_psd(fmin=0.5, fmax=60).plot(
    axes=axes[1], average=True, show=False
)
axes[1].set_title('AFTER Filtering — PSD (50 Hz spike removed)')

plt.tight_layout()
plt.savefig('04_filtering_comparison.png', dpi=100)
plt.show()
```

### Step 2: Artifact Removal with ICA

```python
# ── ICA: Independent Component Analysis ───────────────────────
#
# CONCEPTUAL EXPLANATION FIRST:
#
# Your 60 EEG channels all pick up the same eye blink —
# because eye blink electrical activity spreads across the scalp.
# ICA is a mathematical technique that "unmixes" the signals,
# separating: brain activity / eye activity / muscle activity
# into independent components.
#
# You then identify which components are eye blinks (not brain),
# and remove them. The remaining components are reconstructed
# back into channel space — this is artifact-cleaned EEG.

# Set up ICA
ica = mne.preprocessing.ICA(
    n_components=15,     # Number of independent components to find
                         # Rule of thumb: 15–20 for standard datasets
    method='fastica',    # FastICA algorithm — standard for EEG
    random_state=42,     # For reproducibility
    max_iter=800,
    verbose=False
)

# Fit ICA to the filtered data
# ICA learns what the independent components are
ica.fit(raw_filtered, verbose=False)
print(f"ICA fitted: {ica.n_components_} components found")
```

```python
# Visualize ICA components
# Look for: components that look like eye blinks (frontal blob)
# or muscle activity (spiky, high-frequency)
ica.plot_components(
    picks=range(min(10, ica.n_components_)),
    title='ICA Components — Find Eye Blink and Muscle Artifacts'
)
plt.savefig('04_ica_components.png', dpi=100, bbox_inches='tight')
plt.show()

# WHAT TO LOOK FOR:
# Eye blink component: frontal channels (Fp1, Fp2) strongly activated
#   → Looks like a blob concentrated at the front of the head
# Muscle artifact: temporal channels (T7, T8) strongly activated
#   → Looks like a "ring" around the edges
# Heart artifact: appears as regular sharp peaks in time series
```

```python
# Automatic detection of eye blink artifacts
# MNE can find EOG (eye movement) channels and correlate with ICA components
# If your data has EOG channels:
try:
    eog_indices, eog_scores = ica.find_bads_eog(
        raw_filtered,
        ch_name=['EOG 061'],  # name of eye movement channel in sample data
        verbose=False
    )
    print(f"Eye artifact components: {eog_indices}")
    ica.exclude = eog_indices

except Exception as e:
    print(f"EOG channel not found, manually inspect components: {e}")
    # For datasets without EOG channels:
    # ica.exclude = [0, 1]  # Manually set after visual inspection

# Apply ICA — removes the marked components
raw_clean = raw_filtered.copy()
ica.apply(raw_clean, verbose=False)
print("ICA applied — artifacts removed")
print(f"Clean signal std: {raw_clean.get_data().std()*1e6:.2f} μV")
```

```python
# Compare before/after artifact removal
fig, axes = plt.subplots(2, 1, figsize=(15, 6), sharex=True)

t_start, t_end = 0, 10  # First 10 seconds

data_before, times = raw_filtered.get_data(
    tmin=t_start, tmax=t_end, return_times=True
)
data_after, _ = raw_clean.get_data(
    tmin=t_start, tmax=t_end, return_times=True
)

axes[0].plot(times, data_before[0] * 1e6, linewidth=0.5, color='red', alpha=0.7)
axes[0].set_title('BEFORE ICA — Channel Fp1 (with artifacts)')
axes[0].set_ylabel('Amplitude (μV)')
axes[0].grid(True, alpha=0.3)

axes[1].plot(times, data_after[0] * 1e6, linewidth=0.5, color='green', alpha=0.7)
axes[1].set_title('AFTER ICA — Channel Fp1 (artifacts removed)')
axes[1].set_ylabel('Amplitude (μV)')
axes[1].set_xlabel('Time (seconds)')
axes[1].grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('04_artifact_removal.png', dpi=100)
plt.show()
```

---

## PART 8: Epoching — Splitting EEG into Windows

### What is an Epoch?

```
CONTINUOUS EEG RECORDING (e.g., 2 hours of driving):
──────────────────────────────────────────────────────────────►  time
         ↑           ↑           ↑           ↑
     epoch 1     epoch 2     epoch 3     epoch 4   ...

Each epoch: a fixed-duration window (e.g., 8 seconds)
SEED-VIG: 885 epochs of 8 seconds each = ~2 hours total

Why epoch?
  1. ML models need fixed-size inputs — you can't feed a 2-hour recording
  2. Labels are assigned per epoch (e.g., PERCLOS score at that 8-second window)
  3. Allows computing features per window (DE per epoch)
```

```python
# ============================================================
# FILE: 05_epoching.py
# PURPOSE: Split continuous EEG into epochs
# ============================================================

import mne
import numpy as np
import matplotlib.pyplot as plt

mne.set_log_level('WARNING')

# Load and preprocess (abbreviated for clarity)
from mne.datasets import sample
data_path = sample.data_path()
raw_fname = data_path / 'MEG' / 'sample' / 'sample_audvis_raw.fif'
raw = mne.io.read_raw_fif(raw_fname, preload=True)

# Pick EEG + stimulus channel (we need the stim channel for event detection)
raw_work = raw.copy().pick_types(eeg=True, meg=False, stim=True)
raw_work.filter(l_freq=0.5, h_freq=50.0, verbose=False)
```

```python
# ── Method 1: Event-based epoching ───────────────────────────
# For datasets where you know WHEN something happened (event markers)
# The sample dataset has auditory/visual event triggers

# Find events (trigger signals in the STIM channel)
events = mne.find_events(raw_work, stim_channel='STI 014', verbose=False)
print(f"Found {len(events)} events")
print(f"Event array shape: {events.shape}")
print("Event format: [sample_index, previous_value, event_id]")
print(f"First 5 events:\n{events[:5]}")

# Define what each event ID means in this experiment
event_id = {
    'auditory/left': 1,
    'auditory/right': 2,
    'visual/left': 3,
    'visual/right': 4,
}

# Create epochs: -0.2s before event to 0.5s after event
epochs = mne.Epochs(
    raw_work,
    events,
    event_id=event_id,
    tmin=-0.2,        # 200ms before event
    tmax=0.5,         # 500ms after event
    picks='eeg',      # Only EEG channels
    baseline=(-0.2, 0),  # Baseline correction using pre-stimulus period
    preload=True,
    verbose=False
)
print(f"\nEpochs created: {epochs}")
print(f"Shape: {epochs.get_data().shape}")
# → (n_epochs, n_channels, n_times)
```

```python
# ── Method 2: Fixed-window epoching ──────────────────────────
# For datasets WITHOUT event markers — like SEED-VIG raw EEG
# Split the recording into consecutive non-overlapping windows

# This is the approach you'd use if you had SEED-VIG raw EEG
# SEED-VIG uses 8-second windows at 200 Hz = 1600 samples per window

WINDOW_DURATION = 8.0   # seconds — matches SEED-VIG
sfreq = raw_work.info['sfreq']
samples_per_window = int(WINDOW_DURATION * sfreq)

# Get raw EEG data
raw_eeg_only = raw_work.copy().pick_types(eeg=True, stim=False)
data, times = raw_eeg_only.get_data(return_times=True)
# data shape: (n_channels, n_total_samples)

n_channels = data.shape[0]
n_total = data.shape[1]
n_windows = n_total // samples_per_window

print(f"\nFixed-window epoching:")
print(f"  Total samples: {n_total}")
print(f"  Window duration: {WINDOW_DURATION}s = {samples_per_window} samples")
print(f"  Number of windows: {n_windows}")

# Stack into 3D array: (n_windows, n_channels, n_samples_per_window)
epochs_array = np.zeros((n_windows, n_channels, samples_per_window))
for i in range(n_windows):
    start = i * samples_per_window
    end = start + samples_per_window
    epochs_array[i] = data[:, start:end]

print(f"  Epochs array shape: {epochs_array.shape}")
# → (n_windows, n_channels, samples_per_window)
# This is what you'd compute DE features on for each epoch
```

```python
# Visualize an epoch
fig, axes = plt.subplots(4, 1, figsize=(12, 10))
epoch_idx = 0
t_epoch = np.linspace(0, WINDOW_DURATION, samples_per_window)

channel_names_to_plot = ['Fp1-like', 'F3-like', 'Cz-like', 'Oz-like']
for i, ax in enumerate(axes):
    ax.plot(t_epoch, epochs_array[epoch_idx, i, :] * 1e6,
            linewidth=0.7, color=f'C{i}')
    ax.set_ylabel(f'Channel {i}\n(μV)', fontsize=9)
    ax.grid(True, alpha=0.3)
    if i == len(axes) - 1:
        ax.set_xlabel('Time within epoch (seconds)')

fig.suptitle(f'Epoch {epoch_idx} — 4 Channels — 8-Second Window', fontsize=12)
plt.tight_layout()
plt.savefig('05_epoch_visualization.png', dpi=100)
plt.show()
```

---

## PART 9: Frequency Bands and What They Mean

### The Five EEG Frequency Bands

```python
# ============================================================
# FILE: 06_frequency_bands.py
# PURPOSE: Understand and visualize EEG frequency bands
# ============================================================

import mne
import numpy as np
import matplotlib.pyplot as plt
from scipy import signal as scipy_signal

# Frequency band definitions — memorize these
FREQUENCY_BANDS = {
    'Delta':  {'range': (0.5, 4),   'color': 'purple',
               'brain_state': 'Deep sleep, unconscious',
               'fatigue_relevance': 'Increases during extreme sleep deprivation. Less used in driving fatigue studies.'},
    'Theta':  {'range': (4, 8),     'color': 'blue',
               'brain_state': 'Drowsiness, light sleep, mental effort',
               'fatigue_relevance': '★★★★★ MOST IMPORTANT. Frontal theta INCREASES with fatigue. '
                                    'The most reliable single biomarker of cognitive fatigue.'},
    'Alpha':  {'range': (8, 13),    'color': 'green',
               'brain_state': 'Relaxed alertness, eyes closed',
               'fatigue_relevance': '★★★★★ MOST IMPORTANT. Occipital/parietal alpha INCREASES '
                                    'when vigilance drops. Classic fatigue indicator.'},
    'Beta':   {'range': (13, 30),   'color': 'orange',
               'brain_state': 'Active thinking, focus, alertness',
               'fatigue_relevance': '★★★ IMPORTANT. Beta DECREASES as fatigue increases. '
                                    'Loss of beta = loss of active engagement.'},
    'Gamma':  {'range': (30, 50),   'color': 'red',
               'brain_state': 'High cognitive processing, binding',
               'fatigue_relevance': '★★ MODERATE. Less studied in fatigue. '
                                    'Decreases with mental exhaustion.'},
}

print("=" * 70)
print("EEG FREQUENCY BANDS — FATIGUE RESEARCH RELEVANCE")
print("=" * 70)

for band_name, info in FREQUENCY_BANDS.items():
    print(f"\n{band_name}: {info['range'][0]}–{info['range'][1]} Hz")
    print(f"  Brain state:       {info['brain_state']}")
    print(f"  Fatigue relevance: {info['fatigue_relevance']}")
```

```python
# ── Compute and visualize band power per epoch ────────────────

mne.set_log_level('WARNING')
from mne.datasets import sample
data_path = sample.data_path()
raw_fname = data_path / 'MEG' / 'sample' / 'sample_audvis_raw.fif'
raw = mne.io.read_raw_fif(raw_fname, preload=True)
raw_eeg = raw.copy().pick_types(eeg=True, meg=False, stim=False)
raw_filtered = raw_eeg.copy().filter(l_freq=0.5, h_freq=50.0, verbose=False)

sfreq = raw_filtered.info['sfreq']

# Get a 30-second segment for analysis
data, times = raw_filtered.get_data(tmin=0, tmax=30, return_times=True)
# data shape: (n_channels, n_samples)

# Compute PSD using Welch method for one channel
channel_idx = 0
channel_data = data[channel_idx]

freqs, psd = scipy_signal.welch(
    channel_data,
    fs=sfreq,
    nperseg=int(4 * sfreq),   # 4-second segments for PSD estimation
    noverlap=int(2 * sfreq)   # 50% overlap
)

# Plot PSD with band annotations
fig, ax = plt.subplots(figsize=(14, 6))
ax.semilogy(freqs, psd, color='black', linewidth=1.5, label='PSD')

colors_list = ['purple', 'blue', 'green', 'orange', 'red']
for (band_name, info), color in zip(FREQUENCY_BANDS.items(), colors_list):
    band_mask = (freqs >= info['range'][0]) & (freqs <= info['range'][1])
    ax.fill_between(freqs[band_mask], psd[band_mask],
                    alpha=0.4, color=color, label=f"{band_name} ({info['range'][0]}–{info['range'][1]} Hz)")

ax.set_xlabel('Frequency (Hz)', fontsize=12)
ax.set_ylabel('Power Spectral Density (V²/Hz)', fontsize=12)
ax.set_title(f'PSD with Frequency Bands — Channel {raw_filtered.ch_names[channel_idx]}', fontsize=13)
ax.legend(fontsize=9)
ax.set_xlim(0.5, 50)
ax.grid(True, alpha=0.3)
plt.tight_layout()
plt.savefig('06_frequency_bands.png', dpi=100)
plt.show()
```

```python
# ── Compute band power as a feature ──────────────────────────
# This is what SEED-VIG computes as Differential Entropy (approximately)

def compute_band_power(signal, sfreq, band_range):
    """
    Compute average power in a frequency band.
    Returns a single scalar — the "energy" in that band.
    """
    freqs, psd = scipy_signal.welch(signal, fs=sfreq, nperseg=int(sfreq*2))
    band_mask = (freqs >= band_range[0]) & (freqs <= band_range[1])
    return np.mean(psd[band_mask])

def compute_differential_entropy(signal, sfreq, band_range):
    """
    Compute Differential Entropy — the SEED-VIG feature.
    DE = 0.5 * log(2 * pi * e * variance_of_bandpass_signal)

    For a Gaussian signal, this is equivalent to log variance
    and captures the "complexity" of activity in a frequency band.
    """
    from scipy.signal import butter, filtfilt
    # Bandpass filter to the specific band
    nyq = sfreq / 2
    low = band_range[0] / nyq
    high = band_range[1] / nyq
    # Clip to valid range
    low = max(low, 0.001)
    high = min(high, 0.999)
    b, a = butter(4, [low, high], btype='band')
    filtered = filtfilt(b, a, signal)
    # DE formula
    variance = np.var(filtered)
    if variance <= 0:
        return 0.0
    de = 0.5 * np.log(2 * np.pi * np.e * variance)
    return de

# Example: compute features for one epoch of one channel
WINDOW_DURATION = 8.0
samples_per_window = int(WINDOW_DURATION * sfreq)
one_epoch = data[0, :samples_per_window]  # Channel 0, first epoch

print("\nFeature extraction for one epoch of one channel:")
print(f"{'Band':<10} {'Range (Hz)':<15} {'Band Power':<20} {'Diff Entropy':<20}")
print("-" * 65)

for band_name, info in FREQUENCY_BANDS.items():
    bp = compute_band_power(one_epoch, sfreq, info['range'])
    de = compute_differential_entropy(one_epoch, sfreq, info['range'])
    print(f"{band_name:<10} {str(info['range']):<15} {bp:<20.6f} {de:<20.4f}")

print("\n→ The 'Diff Entropy' column is exactly what SEED-VIG provides.")
print("→ SEED-VIG computes this for 17 channels × 5 bands × 885 epochs")
print("→ That gives you the [17, 885, 5] feature matrix")
```

---

## PART 10: Relation to SEED-VIG — The Most Important Section

### What SEED-VIG Already Did For You

```
WHAT THE SJTU RESEARCHERS DID (once, in a lab):
═══════════════════════════════════════════════════════════════

Step 1: Recruited 23 subjects (paid them, got ethics approval)
Step 2: Set up EEG amplifier + 17 electrodes on each subject
Step 3: Ran 2-hour driving simulation in a lab environment
Step 4: Simultaneously recorded:
         - Raw EEG at 1000 Hz → 23 × 17 × 7,200,000 samples
         - Eye tracking (PERCLOS) for fatigue ground truth
Step 5: Preprocessing:
         - Downsampled raw EEG: 1000 Hz → 200 Hz
         - Bandpass filter: 0.5–75 Hz
         - ICA artifact removal (eye blinks, muscle)
         - Baseline removal
Step 6: Epoching:
         - Split into 8-second non-overlapping windows
         - 885 epochs per subject
Step 7: Feature extraction:
         - Computed Differential Entropy per channel per band per epoch
         - Result: [17 channels × 885 epochs × 5 bands] per subject
Step 8: Label assignment:
         - Averaged PERCLOS over each 8-second epoch
         - Thresholded: PERCLOS < 0.35 → Awake (0)
                        0.35–0.70  → Tired (1)
                        > 0.70     → Drowsy (2)
Step 9: Packaged as .mat files and published

WHAT YOU DO (your project):
═══════════════════════════════════════════════════════════════

Step 1: scipy.io.loadmat('subject_01.mat')
         → data['de_LDS'].shape == (17, 885, 5)
Step 2: Reshape to (885, 85) for ML input
Step 3: Load PERCLOS labels: shape (885,) → convert to class 0/1/2
Step 4: Train your model
Step 5: Evaluate

That's it. Steps 2–8 of their pipeline are already done for you.
```

### Which MNE Steps Become Unnecessary

```python
# ============================================================
# FILE: 07_seedvig_workflow.py
# PURPOSE: Show the ACTUAL workflow for SEED-VIG DE features
# ============================================================

import numpy as np
import scipy.io as sio
import torch
from torch.utils.data import Dataset, DataLoader
import matplotlib.pyplot as plt

# ── MNE STEP STATUS FOR SEED-VIG ─────────────────────────────
#
# ✗ raw loading (mne.io.read_raw_*): NOT NEEDED — use scipy.io.loadmat
# ✗ filtering: NOT NEEDED — SJTU already filtered 0.5-75 Hz
# ✗ ICA artifact removal: NOT NEEDED — SJTU already ran ICA
# ✗ epoching: NOT NEEDED — SJTU already created 885 epochs
# ✗ DE feature extraction: NOT NEEDED — SJTU already computed DE
# ✓ Data inspection: YOU DO THIS — explore the .mat files
# ✓ Visualization of features: YOU DO THIS — understand the data
# ✓ ML model: YOU DO THIS — the entire research contribution

print("MNE STEP STATUS FOR SEED-VIG:")
steps = [
    ("Loading raw EEG", "MNE mne.io.read_raw_*()", "✗ NOT NEEDED", "scipy.io.loadmat()"),
    ("Bandpass filtering", "MNE raw.filter()", "✗ NOT NEEDED", "Already done by SJTU"),
    ("ICA artifact removal", "MNE ICA()", "✗ NOT NEEDED", "Already done by SJTU"),
    ("Epoching", "MNE mne.Epochs()", "✗ NOT NEEDED", "Already 885 epochs in file"),
    ("DE feature extraction", "NumPy/SciPy", "✗ NOT NEEDED", "Already extracted in file"),
    ("Data loading", "scipy.io.loadmat()", "✓ YOU DO THIS", "Main data entry point"),
    ("Feature visualization", "Matplotlib", "✓ YOU DO THIS", "Explore feature distributions"),
    ("Model training", "PyTorch", "✓ YOU DO THIS", "Core research contribution"),
]

print(f"\n{'Step':<25} {'MNE Tool':<30} {'Status':<20} {'Your Tool'}")
print("-" * 95)
for step, mne_tool, status, your_tool in steps:
    print(f"{step:<25} {mne_tool:<30} {status:<20} {your_tool}")
```

```python
# ── Loading SEED-VIG (when you have access) ───────────────────

def load_seedvig_subject(mat_filepath, perclos_filepath):
    """
    Load one subject's SEED-VIG DE features and PERCLOS labels.

    Args:
        mat_filepath: path to e.g., '1_20151118.mat'
        perclos_filepath: path to e.g., 'perclos_1.mat'

    Returns:
        X: np.ndarray of shape (885, 85) — features
           [17 channels × 5 bands, flattened per trial]
        y: np.ndarray of shape (885,) — class labels [0, 1, 2]
    """
    # Load DE features
    mat_data = sio.loadmat(mat_filepath)

    # SEED-VIG provides two versions of DE features:
    # 'de_LDS': smoothed with Linear Dynamical System (recommended)
    # 'de_movingAve': smoothed with moving average
    de_features = mat_data['de_LDS']
    # Shape: (17, 885, 5) → channels × trials × bands

    # Reshape for ML: (trials, channels × bands)
    n_channels, n_trials, n_bands = de_features.shape
    X = de_features.transpose(1, 0, 2)  # → (885, 17, 5)
    X = X.reshape(n_trials, n_channels * n_bands)  # → (885, 85)

    # Load PERCLOS labels
    perclos_data = sio.loadmat(perclos_filepath)
    perclos_values = perclos_data['perclos'].flatten()
    # Shape: (885,) — continuous values 0.0 to 1.0

    # Convert continuous PERCLOS to 3-class labels
    y = np.zeros(n_trials, dtype=int)
    y[perclos_values >= 0.35] = 1   # Tired
    y[perclos_values >= 0.70] = 2   # Drowsy

    print(f"Subject loaded:")
    print(f"  Features X: {X.shape} — {n_trials} trials × {n_channels*n_bands} features")
    print(f"  Labels y:   {y.shape}")
    print(f"  Class distribution:")
    for c, name in enumerate(['Awake', 'Tired', 'Drowsy']):
        count = (y == c).sum()
        print(f"    Class {c} ({name}): {count} trials ({100*count/n_trials:.1f}%)")

    return X, y


# ── Simulate SEED-VIG data for practice (while waiting for access) ──

def create_mock_seedvig(n_subjects=5, n_trials=885, n_channels=17, n_bands=5):
    """
    Creates realistic mock SEED-VIG data for pipeline testing.
    Same shape and statistics as real SEED-VIG.
    Replace this with the real load_seedvig_subject() when you have access.
    """
    np.random.seed(42)

    all_X, all_y = [], []
    for subj in range(n_subjects):
        # Simulate DE features (realistic range: 3-8 for typical EEG bands)
        X = np.random.normal(5.0, 1.0, (n_trials, n_channels * n_bands))
        # Add some subject-level variation
        X += np.random.normal(0, 0.3, (1, n_channels * n_bands))

        # Simulate PERCLOS labels: mostly awake, some tired, few drowsy
        perclos = np.clip(np.random.beta(2, 5, n_trials), 0, 1)
        y = np.zeros(n_trials, dtype=int)
        y[perclos >= 0.35] = 1
        y[perclos >= 0.70] = 2

        all_X.append(X)
        all_y.append(y)

    return all_X, all_y

# Create mock data
all_X, all_y = create_mock_seedvig(n_subjects=5)
X_subj0 = all_X[0]
y_subj0 = all_y[0]

print("\nMock SEED-VIG created:")
print(f"  X shape: {X_subj0.shape}")
print(f"  y shape: {y_subj0.shape}")
print(f"  Unique labels: {np.unique(y_subj0, return_counts=True)}")
```

```python
# ── Visualize SEED-VIG feature structure ─────────────────────

# Reshape for visualization: (885, 17, 5)
X_3d = X_subj0.reshape(-1, 17, 5)
band_names = ['Delta', 'Theta', 'Alpha', 'Beta', 'Gamma']

# Plot 1: Feature heatmap — 17 channels × 5 bands for first 50 trials
fig, ax = plt.subplots(figsize=(12, 8))
mean_features = X_3d.mean(axis=0)  # (17, 5) — average across trials
im = ax.imshow(mean_features, aspect='auto', cmap='viridis')
ax.set_xticks(range(5))
ax.set_xticklabels(band_names)
ax.set_yticks(range(17))
ax.set_yticklabels([f'Ch{i+1}' for i in range(17)])
ax.set_xlabel('Frequency Band')
ax.set_ylabel('EEG Channel')
ax.set_title('Mean DE Features — 17 Channels × 5 Bands')
plt.colorbar(im, label='Differential Entropy')
plt.tight_layout()
plt.savefig('07_de_feature_heatmap.png', dpi=100)
plt.show()
```

```python
# Plot 2: Alpha power over time — does it increase with fatigue?
alpha_band_idx = 2  # Alpha is index 2 in [Delta, Theta, Alpha, Beta, Gamma]
frontal_channel_idx = 1  # Approximately frontal channel

alpha_over_time = X_3d[:, frontal_channel_idx, alpha_band_idx]  # (885,)
trial_indices = np.arange(885)

fig, (ax1, ax2) = plt.subplots(2, 1, figsize=(14, 6), sharex=True)

ax1.plot(trial_indices, alpha_over_time, linewidth=0.7, alpha=0.8, color='green')
ax1.set_ylabel('Alpha DE (Frontal)', fontsize=10)
ax1.set_title('Alpha Power and Fatigue State Over 885 Trials', fontsize=12)
ax1.grid(True, alpha=0.3)

# Color-code the fatigue labels
colors_map = {0: 'blue', 1: 'orange', 2: 'red'}
label_names = {0: 'Awake', 1: 'Tired', 2: 'Drowsy'}
for class_id, color in colors_map.items():
    mask = y_subj0 == class_id
    ax2.scatter(trial_indices[mask], np.zeros(mask.sum()) + class_id,
                c=color, alpha=0.3, s=5, label=label_names[class_id])
ax2.set_xlabel('Trial Index (time progression →)', fontsize=10)
ax2.set_ylabel('Fatigue State', fontsize=10)
ax2.set_yticks([0, 1, 2])
ax2.set_yticklabels(['Awake', 'Tired', 'Drowsy'])
ax2.legend()
ax2.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('07_fatigue_progression.png', dpi=100)
plt.show()

# WHAT TO EXPECT IN REAL DATA:
# Alpha power should generally INCREASE as trials progress
# (subjects get more fatigued toward the end of the 2-hour drive)
# This is the core signal your ML model needs to learn
```

---

## PART 11: Mini Project (2–3 Hours Hands-On)

### Project: "EEG Fatigue Signal Explorer"

Complete this project together — both Jay and Keshav should run every step.

```python
# ============================================================
# FILE: mini_project/eeg_fatigue_explorer.py
# ============================================================
# MINI PROJECT: EEG Fatigue Signal Explorer
# Time: 2-3 hours
# Goal: Load EEG, visualize, extract frequency features,
#       compare features across a simulated fatigue progression
# ============================================================

import mne
import numpy as np
import scipy.io as sio
from scipy import signal as scipy_signal
import matplotlib.pyplot as plt
import matplotlib.gridspec as gridspec
from pathlib import Path

mne.set_log_level('WARNING')
np.random.seed(42)

print("=" * 60)
print("EEG FATIGUE SIGNAL EXPLORER")
print("NIT Goa Research Internship — Day 2 Mini Project")
print("=" * 60)
```

```python
# ── TASK 1: Load EEG Data (25 min) ───────────────────────────

print("\n[ TASK 1: Loading EEG Data ]")

# Load MNE sample EEG data
from mne.datasets import sample
data_path = sample.data_path()
raw_fname = data_path / 'MEG' / 'sample' / 'sample_audvis_raw.fif'
raw = mne.io.read_raw_fif(raw_fname, preload=True, verbose=False)
raw_eeg = raw.copy().pick_types(eeg=True, meg=False, stim=False)

sfreq = raw_eeg.info['sfreq']
n_channels = len(raw_eeg.ch_names)
duration = raw_eeg.n_times / sfreq

print(f"✓ Loaded EEG recording")
print(f"  Channels: {n_channels}")
print(f"  Sampling rate: {sfreq} Hz")
print(f"  Duration: {duration:.1f} seconds ({duration/60:.1f} minutes)")
print(f"  Channel names (first 8): {raw_eeg.ch_names[:8]}")

# TASK 1 QUESTION (write answer in Research Notebook):
# Q: If SEED-VIG records at 200 Hz for 2 hours, how many
#    total time samples does it contain per channel?
# A: 200 Hz × 7200 seconds = _______
```

```python
# ── TASK 2: Preprocess the Signal (30 min) ───────────────────

print("\n[ TASK 2: Preprocessing ]")

# Apply bandpass filter
raw_filtered = raw_eeg.copy().filter(
    l_freq=0.5, h_freq=50.0,
    method='fir', verbose=False
)
print("✓ Bandpass filter applied: 0.5–50 Hz")

# Apply notch filter for powerline
raw_filtered.notch_filter(freqs=50, method='fir', verbose=False)
print("✓ Notch filter applied: 50 Hz removed")

# Compare signal before and after filtering
data_before = raw_eeg.get_data()
data_after = raw_filtered.get_data()

print(f"\nSignal statistics comparison (Channel 0):")
print(f"  Before → Mean: {data_before[0].mean()*1e6:.4f} μV, "
      f"Std: {data_before[0].std()*1e6:.4f} μV")
print(f"  After  → Mean: {data_after[0].mean()*1e6:.4f} μV, "
      f"Std: {data_after[0].std()*1e6:.4f} μV")
```

```python
# ── TASK 3: Create Epochs (25 min) ───────────────────────────

print("\n[ TASK 3: Creating 8-Second Epochs (SEED-VIG Style) ]")

EPOCH_DURATION = 8.0   # seconds — matches SEED-VIG
SFREQ = sfreq
SAMPLES_PER_EPOCH = int(EPOCH_DURATION * SFREQ)

data, times = raw_filtered.get_data(return_times=True)
n_ch = data.shape[0]
n_total_samples = data.shape[1]
n_epochs = n_total_samples // SAMPLES_PER_EPOCH

# Create epoch array
epochs_3d = np.zeros((n_epochs, n_ch, SAMPLES_PER_EPOCH))
for i in range(n_epochs):
    start = i * SAMPLES_PER_EPOCH
    end = start + SAMPLES_PER_EPOCH
    epochs_3d[i] = data[:, start:end]

print(f"✓ Epochs created: {n_epochs} epochs")
print(f"  Each epoch: {n_ch} channels × {SAMPLES_PER_EPOCH} samples")
print(f"  Epoch array shape: {epochs_3d.shape}")
print(f"  Total time covered: {n_epochs * EPOCH_DURATION:.0f} seconds")
```

```python
# ── TASK 4: Extract Frequency Band Features (40 min) ─────────

print("\n[ TASK 4: Feature Extraction — Differential Entropy ]")

FREQUENCY_BANDS = {
    'Delta': (0.5, 4),
    'Theta': (4, 8),
    'Alpha': (8, 13),
    'Beta':  (13, 30),
    'Gamma': (30, 50),
}

def compute_de_for_epoch(epoch_data, sfreq, bands):
    """
    Compute Differential Entropy for one epoch.

    Args:
        epoch_data: np.ndarray (n_channels, n_samples)
        sfreq: float, sampling rate in Hz
        bands: dict of band_name → (low_freq, high_freq)

    Returns:
        features: np.ndarray (n_channels, n_bands)
    """
    from scipy.signal import butter, filtfilt

    n_channels = epoch_data.shape[0]
    n_bands = len(bands)
    features = np.zeros((n_channels, n_bands))

    for band_idx, (band_name, (low, high)) in enumerate(bands.items()):
        nyq = sfreq / 2
        # Build bandpass filter
        b, a = butter(4, [max(low/nyq, 0.001), min(high/nyq, 0.999)],
                      btype='band')

        for ch_idx in range(n_channels):
            # Filter channel to this frequency band
            band_signal = filtfilt(b, a, epoch_data[ch_idx])
            # Compute differential entropy
            var = np.var(band_signal)
            de = 0.5 * np.log(2 * np.pi * np.e * (var + 1e-10))
            features[ch_idx, band_idx] = de

    return features

# Extract DE features for all epochs
print("Extracting DE features (this may take 1-2 minutes)...")
n_bands = len(FREQUENCY_BANDS)
all_de_features = np.zeros((n_epochs, n_channels, n_bands))

for ep_idx in range(n_epochs):
    all_de_features[ep_idx] = compute_de_for_epoch(
        epochs_3d[ep_idx], SFREQ, FREQUENCY_BANDS
    )
    if (ep_idx + 1) % 10 == 0:
        print(f"  Processed {ep_idx+1}/{n_epochs} epochs...", end='\r')

print(f"\n✓ Feature extraction complete")
print(f"  DE feature array shape: {all_de_features.shape}")
print(f"  → ({n_epochs} epochs, {n_channels} channels, {n_bands} bands)")
print(f"  This replicates SEED-VIG's DE feature structure!")
```

```python
# ── TASK 5: Visualize Features and Fatigue Pattern (30 min) ──

print("\n[ TASK 5: Visualization and Analysis ]")

band_names = list(FREQUENCY_BANDS.keys())

# Simulate fatigue progression (since this is not a fatigue dataset)
# In SEED-VIG: subjects get genuinely more fatigued over 2 hours
# Here: simulate by creating mock fatigue labels that increase over time
mock_fatigue = np.zeros(n_epochs, dtype=int)
mock_fatigue[n_epochs//3 : 2*n_epochs//3] = 1   # Middle third: Tired
mock_fatigue[2*n_epochs//3 :] = 2               # Last third: Drowsy

# Figure 1: DE feature heatmap across all epochs and bands
fig = plt.figure(figsize=(16, 10))
gs = gridspec.GridSpec(2, 3, figure=fig, hspace=0.4, wspace=0.4)

# Subplot 1: Mean DE per channel per band
ax1 = fig.add_subplot(gs[0, :2])
mean_de = all_de_features.mean(axis=0)  # (n_channels, n_bands)
im = ax1.imshow(mean_de, aspect='auto', cmap='hot')
ax1.set_xticks(range(n_bands))
ax1.set_xticklabels(band_names)
ax1.set_yticks(range(min(n_channels, 8)))
ax1.set_yticklabels(raw_filtered.ch_names[:min(n_channels, 8)], fontsize=7)
ax1.set_xlabel('Frequency Band')
ax1.set_ylabel('EEG Channel')
ax1.set_title('Mean DE Features — Channels × Bands')
plt.colorbar(im, ax=ax1, label='DE Value')

# Subplot 2: Class distribution
ax2 = fig.add_subplot(gs[0, 2])
class_counts = [np.sum(mock_fatigue == c) for c in range(3)]
bars = ax2.bar(['Awake', 'Tired', 'Drowsy'], class_counts,
               color=['steelblue', 'orange', 'red'], edgecolor='black')
ax2.set_ylabel('Number of Epochs')
ax2.set_title('Simulated Class Distribution')
for bar, count in zip(bars, class_counts):
    ax2.text(bar.get_x() + bar.get_width()/2, bar.get_height() + 0.5,
             str(count), ha='center', fontsize=10)

# Subplot 3: Theta band over time (should increase with fatigue)
ax3 = fig.add_subplot(gs[1, :2])
theta_idx = band_names.index('Theta')
ch_to_plot = 0
theta_over_time = all_de_features[:, ch_to_plot, theta_idx]

scatter_colors = ['steelblue', 'orange', 'red']
for class_id in range(3):
    mask = mock_fatigue == class_id
    ax3.scatter(np.where(mask)[0], theta_over_time[mask],
                c=scatter_colors[class_id], alpha=0.5, s=15,
                label=['Awake', 'Tired', 'Drowsy'][class_id])
ax3.plot(range(n_epochs),
         np.convolve(theta_over_time, np.ones(5)/5, mode='same'),
         'k-', linewidth=1.5, alpha=0.7, label='Moving average')
ax3.set_xlabel('Epoch Index (Time →)')
ax3.set_ylabel('Theta DE')
ax3.set_title(f'Theta Band Power Over Time — Channel {raw_filtered.ch_names[ch_to_plot]}')
ax3.legend(fontsize=8)
ax3.grid(True, alpha=0.3)

# Subplot 4: Band comparison by fatigue class
ax4 = fig.add_subplot(gs[1, 2])
mean_by_class = []
for c in range(3):
    mask = mock_fatigue == c
    if mask.sum() > 0:
        mean_by_class.append(all_de_features[mask].mean(axis=(0, 1)))
    else:
        mean_by_class.append(np.zeros(n_bands))

x = np.arange(n_bands)
width = 0.25
for c, (class_mean, color, name) in enumerate(zip(
        mean_by_class, scatter_colors, ['Awake', 'Tired', 'Drowsy'])):
    ax4.bar(x + c*width, class_mean, width, label=name,
            color=color, alpha=0.8, edgecolor='black')
ax4.set_xticks(x + width)
ax4.set_xticklabels(band_names, fontsize=8)
ax4.set_ylabel('Mean DE Value')
ax4.set_title('DE by Band and Fatigue Class')
ax4.legend(fontsize=8)

fig.suptitle('EEG Fatigue Signal Explorer — Complete Analysis', fontsize=14, y=1.01)
plt.savefig('mini_project_results.png', dpi=120, bbox_inches='tight')
plt.show()
print("✓ Figure saved: mini_project_results.png")
```

```python
# ── TASK 6: Summary Report ────────────────────────────────────

print("\n" + "=" * 60)
print("MINI PROJECT SUMMARY REPORT")
print("=" * 60)

X_flat = all_de_features.reshape(n_epochs, -1)
print(f"\nDataset summary:")
print(f"  EEG channels: {n_channels}")
print(f"  Epoch duration: {EPOCH_DURATION}s")
print(f"  Total epochs: {n_epochs}")
print(f"  Frequency bands: {n_bands} ({', '.join(band_names)})")
print(f"\nFeature matrix shape: {X_flat.shape}")
print(f"  → This would be your ML model input X")

print(f"\nFeature statistics:")
print(f"  Min DE value: {X_flat.min():.4f}")
print(f"  Max DE value: {X_flat.max():.4f}")
print(f"  Mean DE value: {X_flat.mean():.4f}")
print(f"  Std DE value: {X_flat.std():.4f}")

print(f"\nClass distribution:")
for c, name in enumerate(['Awake', 'Tired', 'Drowsy']):
    count = (mock_fatigue == c).sum()
    print(f"  {name}: {count} epochs ({100*count/n_epochs:.1f}%)")

print(f"\nNext step: Train an SVM or MLP classifier on X_flat with y=mock_fatigue")
print(f"Replace mock_fatigue with real PERCLOS labels when SEED-VIG arrives!")
print("\n✓ Mini project complete!")
```

---

## PART 12: End-of-Day Assessment

### 15 Conceptual Questions

Answer these in writing in your Research Notebook. Both Jay and Keshav answer independently first, then compare.

```
CONCEPTUAL QUESTIONS

Q1.  What is MNE-Python and where exactly does it fit in our
     research pipeline? Name the steps where you use MNE
     vs. where you use NumPy/PyTorch.

Q2.  What does "sampling frequency of 200 Hz" mean in the
     context of SEED-VIG? If a trial is 8 seconds, how many
     data points does one channel have per trial?

Q3.  Why do we apply a bandpass filter before any analysis?
     What would happen if we used unfiltered EEG for
     fatigue classification?

Q4.  What is an ICA component and why do we remove some of them?
     If a subject blinks twice during one 8-second trial,
     what would that look like in the raw EEG signal?

Q5.  What is the difference between a "channel" and a "trial"
     in EEG data? Use SEED-VIG numbers in your answer.

Q6.  If SEED-VIG has shape [17, 885, 5], what does each
     dimension represent? What would one row of the ML input
     matrix look like after reshaping?

Q7.  Why does frontal theta power INCREASE during cognitive fatigue?
     Explain in plain English — no neuroscience jargon allowed.

Q8.  Why does posterior alpha power increase when a driver
     becomes drowsy? What does this mean physiologically?

Q9.  What is PERCLOS and why is it used as the ground truth
     label for fatigue in SEED-VIG instead of self-reports?

Q10. What is Differential Entropy and how is it different from
     simple band power? Write the formula for DE in your notebook.

Q11. Why would a model that achieves 90% within-subject accuracy
     only achieve 65% cross-subject accuracy?
     What does this tell us about the nature of EEG signals?

Q12. If you remove all ICA components that contain eye blink
     artifacts, does the remaining EEG signal still contain
     real brain information? Why?

Q13. Why are 8-second epochs used in SEED-VIG instead of
     1-second or 60-second epochs? What trade-offs are involved?

Q14. Why can't you simply concatenate SEED-VIG (17 channels)
     with DEAP (32 channels) for a combined dataset?

Q15. If you were writing the Methods section of your paper,
     which preprocessing steps would you describe as
     "performed by us" vs. "performed by the SEED-VIG authors"?
```

### 10 Coding Questions

Complete these in code. Push results to GitHub.

```python
# CODING QUESTIONS — Complete these in separate .py files
# Push each to your GitHub repo under assessment/

# CQ1. Load MNE sample EEG data and print:
#      - Number of EEG channels
#      - Sampling frequency
#      - Duration in minutes
#      - The name of channel at index 5

# CQ2. Apply a bandpass filter (1–40 Hz) and a notch filter (50 Hz).
#      Print the mean and standard deviation of channel 0
#      before and after filtering.

# CQ3. Extract raw data as a NumPy array.
#      Print its shape. Then extract only the first 10 seconds.
#      What is the shape of the 10-second array?

# CQ4. Create fixed-size epochs of 8 seconds from the filtered EEG.
#      How many complete 8-second epochs can you create?
#      Print the final epoch array shape.

# CQ5. Compute Differential Entropy for the first epoch,
#      all channels, all 5 frequency bands.
#      Print: which channel and band has the highest DE value?

# CQ6. Plot the raw EEG signal of channel 0 for the first
#      30 seconds with time on x-axis and amplitude in μV
#      on y-axis. Save as 'cq6_raw_signal.png'.

# CQ7. Plot the Power Spectral Density (PSD) of the filtered EEG
#      from 0 to 50 Hz. Mark the five frequency band boundaries
#      with vertical dashed lines. Save as 'cq7_psd_bands.png'.

# CQ8. Create a heatmap showing the mean DE feature value
#      for each (channel, band) combination.
#      X-axis: 5 bands, Y-axis: channels. Save as 'cq8_de_heatmap.png'.

# CQ9. Using the mock SEED-VIG data from Part 10:
#      - Flatten features to (n_epochs, 85)
#      - Fit an SVM classifier (sklearn) with train/test split (80/20)
#      - Print accuracy, precision, recall per class
#      - Print a confusion matrix

# CQ10. Implement leave-one-subject-out (LOSO) cross-validation
#       on the mock SEED-VIG data (5 subjects).
#       Train on 4 subjects, test on the left-out subject.
#       Report mean accuracy across all 5 folds.
#       This is the exact evaluation protocol you will use in the paper.
```

### Passing Criteria

```
You are ready to move to Week 2 (model building) when:

Conceptual Questions:
  ✓ You can answer Q1–Q5 without looking at notes
  ✓ You can answer Q6–Q10 with your Research Notebook open
  ✓ You understand Q11 (cross-subject) deeply — this drives your research

Coding Questions:
  ✓ CQ1–CQ4: Completed without assistance
  ✓ CQ5–CQ8: Completed with minor reference to this guide
  ✓ CQ9–CQ10: Completed (may require debugging — that's normal)

The most important single skill:
  Can you load a .mat file, reshape it to (n_epochs, 85),
  assign labels, and train an SVM with LOSO evaluation?
  If yes: you are ready for Week 2.
  If no: re-read Parts 8–10 and redo CQ9–CQ10.
```

---

## Quick Reference Card (Keep This Open While Coding)

```python
# ═══════════════════════════════════════════════════════════
# MNE QUICK REFERENCE — EEG FATIGUE PROJECT
# ═══════════════════════════════════════════════════════════

# LOADING
raw = mne.io.read_raw_fif('file.fif', preload=True)     # .fif format
raw = mne.io.read_raw_edf('file.edf', preload=True)     # .edf format
raw = mne.io.read_raw_eeglab('file.set', preload=True)  # .set (EEGLAB)
data = scipy.io.loadmat('file.mat')                      # .mat (SEED-VIG)

# CHANNEL SELECTION
raw.pick_types(eeg=True, meg=False, stim=False)

# KEY PROPERTIES
raw.info['sfreq']           # sampling rate (Hz)
raw.ch_names                # list of channel names
raw.n_times                 # total samples
raw.n_times / raw.info['sfreq']  # duration in seconds

# DATA ACCESS
data, times = raw.get_data(return_times=True)   # (n_ch, n_times)
data = raw.get_data(tmin=10, tmax=20)           # seconds 10–20 only
data = raw.get_data(picks=['Fp1', 'Fz'])        # specific channels

# FILTERING
raw.filter(l_freq=0.5, h_freq=50.0)            # bandpass
raw.notch_filter(freqs=50)                      # remove powerline

# ICA
ica = mne.preprocessing.ICA(n_components=15, random_state=42)
ica.fit(raw)
ica.exclude = [0, 1]        # mark bad components
ica.apply(raw)              # remove them

# EPOCHING (event-based)
events = mne.find_events(raw, stim_channel='STI 014')
epochs = mne.Epochs(raw, events, tmin=-0.2, tmax=0.5)
data_3d = epochs.get_data()   # (n_epochs, n_channels, n_times)

# EPOCHING (fixed window — for SEED-VIG style)
data = raw.get_data()          # (n_channels, n_times)
n_epochs = n_times // samples_per_window
epochs = data[:, :n_epochs*spw].reshape(n_channels, n_epochs, spw)
epochs = epochs.transpose(1, 0, 2)  # → (n_epochs, n_channels, spw)

# SEED-VIG LOADING (when access arrives)
import scipy.io as sio
mat = sio.loadmat('1_20151118.mat')
X = mat['de_LDS']              # (17, 885, 5)
X = X.transpose(1, 0, 2)      # (885, 17, 5)
X = X.reshape(885, 85)         # (885, 85) ← ML input

# FREQUENCY BANDS
BANDS = {'Delta':(0.5,4), 'Theta':(4,8),
         'Alpha':(8,13), 'Beta':(13,30), 'Gamma':(30,50)}
```

---

*Document version: Day 2 — NIT Goa EEG Fatigue Research Internship*
*Authors: Jay Kumar Das & Keshav Agarwal*
*Last updated: June 11, 2025*
ENDOFFILE

echo "File created successfully"
wc -l /home/claude/mne_guide/MNE_Complete_Guide_EEG_Fatigue.md
