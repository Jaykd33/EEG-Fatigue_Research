# EEG-Based Cognitive Fatigue Detection

Research repository for investigating **EEG-based cognitive fatigue detection and cross-subject generalisation** during my research internship at **NIT Goa**.

The project explores whether EEG-based fatigue classification models that perform well under subject-dependent evaluation can reliably generalise to **previously unseen subjects**, with particular focus on **subject identity leakage in EEG representations**.

---

## Research Objective

The primary research questions investigated in this work are:

- How large is the gap between within-subject and cross-subject performance?
- Is the generalisation gap dependent on model architecture?
- Does the learned representation contain subject identity information?
- Is subject identity introduced during model training, or is it already present in the input EEG features?
- Can domain-adversarial training reduce subject identity information?
- How is subject identity associated with cross-subject fatigue classification performance?

The research uses the **SEED-VIG** dataset and evaluates models using **Leave-One-Subject-Out (LOSO)** evaluation.

---

## Dataset

### SEED-VIG

The experiments use the **SEED-VIG EEG fatigue dataset**, collected during a simulated monotonous driving task.

The dataset provides pre-extracted **Differential Entropy (DE)** features from EEG signals.

### Feature Representation

- **17 EEG channels**
- **5 frequency bands:** Delta, Theta, Alpha, Beta, Gamma
- **85-dimensional feature vector** (17 channels × 5 frequency bands)
- DE features with **LDS (Linear Dynamical System) smoothing**
- 8-second non-overlapping windows

### Fatigue Labels

Fatigue states are derived from **PERCLOS (Percentage of Eye Closure)**:

| Class | PERCLOS |
|---|---|
| Awake | `< 0.35` |
| Tired | `0.35 – < 0.70` |
| Drowsy | `≥ 0.70` |

---

## Experimental Approach

### 1. Baseline Fatigue Classification

Three neural architectures were investigated:

- **MLP**
- **BiLSTM**
- **GRU**

The models were evaluated under within-subject and Leave-One-Subject-Out (LOSO) evaluation.

### 2. Cross-Subject Generalisation

LOSO evaluation was used to simulate deployment on an unseen subject.

```text
Subjects except Sᵢ
        │
        ▼
     Training
        │
        ▼
     Trained Model
        │
        ▼
      Subject Sᵢ
        │
        ▼
       Test
```

### 3. Subject Identity Probing

A linear probing approach was used to determine whether subject identity could be recovered from model representations:

```text
EEG Representation → Subject Identity
```

Probing was performed on raw DE-LDS features, randomly initialized model representations, and trained model representations.

### 4. Representation Analysis

Analysis included subject identity probing, t-SNE visualisation, representation geometry, subject-wise analysis, probe confidence, silhouette score, and cosine similarity.

### 5. Distribution Shift Analysis

**Maximum Mean Discrepancy (MMD)** was investigated as another possible explanation for cross-subject performance differences.

### 6. Label Distribution Analysis

Subject-wise fatigue label distributions were examined using **label entropy**.

### 7. Domain-Adversarial Training

A **Domain-Adversarial Neural Network (DANN)** with a **Gradient Reversal Layer (GRL)** was implemented to investigate whether subject identity could be suppressed at the representation level.

```text
                 EEG Features
                      │
                      ▼
               Shared Backbone
                      │
              64-D Representation
                 /          \\
                /            \\
               ▼              ▼
      Fatigue Classifier      GRL
               │               │
               ▼               ▼
        Fatigue Loss    Subject Discriminator
                               │
                               ▼
                         Subject Identity
```

---

## Key Findings

### Cross-subject performance degradation

| Model | Within-Subject | LOSO | Generalisation Gap |
|---|---:|---:|---:|
| MLP | 83.4% | 41.2% | 42.2 pp |
| BiLSTM | 83.7% | 39.4% | 44.3 pp |
| GRU | 84.1% | 41.8% | 42.3 pp |

The consistency across MLP, BiLSTM and GRU suggests that the observed generalisation problem is not simply a property of one particular architecture.

### Subject identity leakage

Subject identity was highly recoverable from the representations. The raw DE-LDS features themselves contained highly discriminative subject information, while MLP and GRU learned representations also achieved near-perfect subject identification.

This provides evidence that subject-specific information is already strongly encoded in the **input representation**, rather than being created exclusively by model training.

### DANN analysis

Domain-adversarial training did not consistently suppress subject identity. An improvement in LOSO accuracy was observed for the MLP at the strongest tested adversarial weight, but this improvement was not accompanied by corresponding suppression of subject identity.

---

## Research Workflow

```text
SEED-VIG Dataset
       │
       ▼
DE-LDS EEG Features
       │
       ▼
Baseline Fatigue Models
       │
       ├── MLP
       ├── BiLSTM
       └── GRU
       │
       ▼
Within-Subject vs LOSO Evaluation
       │
       ▼
Cross-Subject Generalisation Gap
       │
       ▼
Subject Identity Probing
       │
       ├── Raw Features
       ├── Random Representations
       └── Trained Representations
       │
       ▼
Representation Analysis
       │
       ├── t-SNE
       ├── MMD
       ├── Silhouette
       ├── Cosine Similarity
       └── Label Entropy
       │
       ▼
DANN + Gradient Reversal
       │
       ▼
Identity Suppression Analysis
```

---

## Evaluation

The primary evaluation protocol is **Leave-One-Subject-Out (LOSO)**.

The experiments use:

- Accuracy
- Balanced Accuracy
- Generalisation Gap
- Subject Identity Probe Accuracy
- Probe Confidence
- Silhouette Score
- Cosine Similarity
- MMD
- Spearman Correlation
- Permutation Testing
- Bootstrap Confidence Intervals

LOSO is important because the objective is to evaluate performance on **subjects not observed during training**.

---

## Repository Contents

This repository documents the research process, including:

- Experiment notebooks
- Model implementations
- Data processing and feature analysis
- LOSO evaluation experiments
- Subject identity probing
- Representation analysis
- MMD and label-distribution analysis
- DANN/GRL experiments
- Visualisations and result generation
- Daily research logs
- Research documentation and notes

The repository is maintained as a **research record**, allowing the progression of the work and experimental decisions to be followed from baseline fatigue classification to the investigation of cross-subject generalisation and subject identity leakage.

---

## Technology Stack

- **Python**
- **PyTorch**
- **scikit-learn**
- **NumPy**
- **Pandas**
- **Matplotlib**
- **Seaborn**
- **Jupyter Notebook**
- **Kaggle Notebooks**

---

## Research Documentation

The repository also contains daily research logs documenting experiments performed, problems encountered, approaches investigated, model changes, evaluation results, research observations, and decisions made during the internship.

These records provide a chronological view of how the research question evolved from fatigue classification toward investigating **cross-subject generalisation and subject identity leakage**.

---

## Research Outcome

The central outcome of this research is the identification and investigation of **subject identity information as an important factor in cross-subject EEG fatigue detection**.

The experiments indicate that:

1. High within-subject accuracy does not necessarily translate to strong cross-subject generalisation.
2. The generalisation gap appears consistently across different model architectures.
3. Subject identity can be strongly decoded from EEG representations.
4. Subject identity is already highly present in the DE-LDS input feature space.
5. Representation-level adversarial training does not consistently remove this identity information.
6. Identity-aware evaluation and input-level representation strategies deserve further investigation for subject-independent EEG fatigue detection.

---

## Future Directions

Potential directions include:

- Input-level subject-invariant normalisation
- More effective domain alignment techniques
- Subject-independent representation learning
- Improved cross-subject EEG feature representations
- Identity-aware evaluation protocols
- Investigation of additional EEG datasets
- Testing the diagnostic approach across other EEG-based cognitive-state tasks

---

## Research Context

**Research Internship:** National Institute of Technology Goa (NIT Goa)  
**Research Domain:** EEG-based Cognitive Fatigue Detection  
**Primary Dataset:** SEED-VIG  
**Primary Evaluation:** Leave-One-Subject-Out (LOSO)  
**Core Research Theme:** Cross-Subject Generalisation and Subject Identity Leakage

---

## Authors

**Jay Kumar Das** — Research Intern / Student Researcher  
**Keshav Agarwal** — Research Collaborator  
**Mentor:** Dr. Y. C. A. Padmanabha Reddy

---

> This repository is primarily intended to document the research process, experiments, findings, and supporting material developed during the research internship.
