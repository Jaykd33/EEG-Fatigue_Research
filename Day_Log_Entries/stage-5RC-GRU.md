# Stage 5RC – Root Cause Verification of Subject Identity Leakage

## Objective
Stage 5A demonstrated that the latent representations learned by the GRU model contain almost perfect subject identity information. A simple linear probe was able to identify the subject from the learned representations with nearly **100% accuracy**, even though the GRU was trained only for fatigue classification.
Stage 5B attempted to eliminate this identity leakage using a Domain-Adversarial Neural Network (DANN) with a Gradient Reversal Layer (GRL). Despite testing multiple adversarial loss weights, the probe accuracy remained at **100%**, indicating that the adversarial training objective failed to suppress subject-specific information.

These findings naturally led to a much deeper research question:
> **Where does the subject identity actually originate?**
Is the identity information being learned by the neural network during training, or is it already present in the EEG features before the model is even introduced?
Stage 5RC was designed specifically to answer this question through a series of controlled experiments.
The objective was not to improve fatigue classification accuracy, but rather to identify the true origin of subject identity leakage within the complete processing pipeline.

# Motivation
At the end of Stage 5B, two possibilities still existed.
The first possibility was that the GRU itself was learning subject-specific patterns during training, causing the identity leakage observed in Stage 5A.
The second possibility was that the Differential Entropy (DE) features extracted from the SEED-VIG dataset already contained strong subject-specific information before any neural network processing.
Distinguishing between these two possibilities is extremely important.
If the identity originates inside the neural network, then better architectures or improved adversarial training methods could potentially solve the problem.
However, if the identity already exists within the input features themselves, then changing the neural network architecture alone is unlikely to eliminate the problem.
Stage 5RC was therefore designed to isolate each component of the pipeline and determine exactly where the subject identity originates.

# Experimental Design
Four independent experiments were conducted.
Each experiment removes one possible explanation for the observed identity leakage.
The same linear probe methodology from Stage 5A was used throughout to ensure a fair comparison.
The experiments were performed in the following order:
1. Random Noise
2. Raw DE Features
3. Untrained GRU
4. Trained DANN-GRU
Each experiment answers a different scientific question.

# Experiment 1 – Random Noise Validation

## Purpose
Before interpreting the probe results, it was necessary to verify that the probing methodology itself was reliable.
A probe classifier that achieves high accuracy even on completely random data would indicate a flawed evaluation protocol.
Therefore, random feature vectors with no relationship to the subjects were generated and used as input to the same probe classifier.

## Result
Probe Accuracy:
**≈ 7.5%**
Expected Chance Level:
**≈ 4.76%**

## Interpretation
The probe accuracy remains very close to random chance.
This confirms that the probe classifier is not artificially biased toward predicting subject identity.
It also demonstrates that the probing methodology cannot achieve high accuracy without meaningful information being present in the input features.
This experiment validates the reliability of every probe experiment performed throughout this project.

# Experiment 2 – Raw Differential Entropy Features
## Purpose
The next experiment investigates whether subject identity already exists before any neural network is introduced.
Instead of extracting latent representations from a trained model, the probe classifier is trained directly on the original Differential Entropy (DE-LDS) features from the SEED-VIG dataset.
No neural network is involved.
No encoder is used.
No training is performed.
Only the original feature vectors are provided to the probe.

## Result
Probe Accuracy:
**100%**

## Interpretation
This is one of the most important findings of the entire project.
The probe is able to perfectly identify every subject using only the original input features.
This means that the Differential Entropy features themselves already contain sufficient information to distinguish individual subjects.
In other words, subject identity exists before any neural network processing begins.
The neural network is therefore not creating subject identity from scratch.
Instead, it is receiving identity-rich input features from the dataset.

# Experiment 3 – Untrained GRU Encoder
## Purpose
Although the previous experiment showed that subject identity exists within the raw features, one important question still remained.
Does the GRU architecture itself amplify or create additional subject-specific information?
To answer this, the trained GRU model was replaced with a completely untrained GRU whose parameters remained randomly initialized.
The encoder therefore performed only a random transformation of the input features.
No fatigue training was performed.
No optimization was performed.
The resulting latent representations were then evaluated using the same linear probe.

## Result
Probe Accuracy:
**100%**

## Interpretation
This result demonstrates that the GRU does not need any training to preserve subject identity.
Even with completely random weights, the GRU outputs remain perfectly distinguishable between subjects.
This indicates that the architecture is simply propagating information that already exists within the input features.
The identity leakage observed in Stage 5A therefore cannot be attributed solely to the training process.
Instead, the encoder inherits subject-specific information directly from the input data.

# Experiment 4 – DANN Representations
## Purpose
The final experiment revisits the adversarial training introduced in Stage 5B.
If the Gradient Reversal Layer successfully removed subject-specific information, then the probe accuracy should decrease substantially.
This experiment evaluates whether adversarial learning was capable of suppressing identity information inherited from the input features.
## Result
Probe Accuracy:
**100%**
across every tested adversarial loss weight.
## Interpretation
The adversarial training objective was unable to reduce subject identity information.
Although the encoder was explicitly encouraged to confuse the subject classifier, the learned representations remained perfectly subject-identifiable.
This indicates that standard Domain-Adversarial Neural Networks are insufficient for removing identity information under the current experimental setting.

# Combined Experimental Evidence
Each experiment performed in Stage 5RC eliminates one possible explanation for the observed identity leakage.
The sequence of findings is summarized below.
| Experiment | Probe Accuracy | Interpretation |
|------------|---------------|----------------|
| Random Noise | ≈ 7.5% | Probe methodology is reliable and close to chance. |
| Raw DE Features | 100% | Subject identity already exists in the original input features. |
| Untrained GRU | 100% | Random GRU preserves identity without any learning. |
| DANN-GRU | 100% | Adversarial training does not remove inherited identity information. |
Viewed together, these experiments form a complete chain of evidence.

# Scientific Interpretation
The results suggest that subject identity leakage originates much earlier than initially expected.
The original Differential Entropy features already contain strong subject-specific information.
The GRU encoder does not generate this information.
Instead, it preserves and propagates the existing structure contained within the input features.
Since the encoder never creates the identity information, the Gradient Reversal Layer cannot effectively remove it afterwards.
The adversarial objective operates only on the learned representations.
However, those representations inherit highly discriminative subject information directly from the input features.
Consequently, standard representation-level adversarial learning is unable to produce subject-invariant representations under the current experimental setting.

# Overall Findings
Stage 5RC provides the final missing piece of evidence required to explain the poor cross-subject performance observed throughout this project.
The experiments demonstrate that:
- Subject identity leakage is not introduced by the neural network during training.
- Subject identity is already strongly encoded within the Differential Entropy features extracted from the SEED-VIG dataset.
- The GRU architecture naturally preserves this identity information even without learning.
- Standard Domain-Adversarial Neural Networks are unable to suppress information that already exists within the input feature space.
Together with the findings from Stage 5A and Stage 5B, these experiments provide a complete explanation for why cross-subject fatigue detection remains difficult.

# Complete Research Story
The project now presents a clear progression of evidence.

### Stage 1 – Baseline Models
Three independent architectures (MLP, BiLSTM and GRU) were trained using identical preprocessing and evaluation pipelines.
All models achieved approximately 83–84% within-subject accuracy but only 39–42% Leave-One-Subject-Out accuracy.
This demonstrated a severe cross-subject generalization gap.

### Stage 5A – Identity Leakage Analysis
A linear probe was trained on the learned latent representations.
The probe achieved nearly 100% subject identification accuracy.
This established that the learned representations strongly encode subject identity.

### Stage 5B – Adversarial Learning
A Domain-Adversarial Neural Network with a Gradient Reversal Layer was introduced to suppress subject identity.
Despite multiple adversarial configurations, probe accuracy remained at 100%.
This demonstrated that standard adversarial training was unable to eliminate the identity leakage.

### Stage 5RC – Root Cause Verification
Controlled experiments showed that:
- Raw Differential Entropy features are already perfectly subject-identifiable.
- Randomly initialized GRU encoders preserve this information without learning.
- Adversarial learning cannot remove information that already exists within the input features.
These findings identify the true origin of subject identity leakage within the current pipeline.

# Final Conclusion
Stage 5RC completes the experimental investigation of this project.
Rather than proposing another neural network architecture, the experiments explain why cross-subject EEG fatigue detection remains a challenging problem.
The evidence collected throughout the project consistently indicates that subject identity is strongly embedded within the Differential Entropy features extracted from the SEED-VIG dataset.
The neural network preserves this information during representation learning, while standard adversarial techniques fail to remove it.
Future work should therefore focus on reducing subject-specific variability before or during feature extraction rather than relying solely on representation-level adversarial learning.
Potential research directions include:
- Feature-level subject normalization
- Subject-invariant feature extraction
- Representation disentanglement techniques
- Contrastive domain adaptation
- Self-supervised pretraining for subject-independent EEG representations
The completion of Stage 5RC marks the end of the experimental phase of this research and provides a complete mechanistic explanation for the observed cross-subject generalization gap.
