Stage 5B – Domain Adversarial Training (DANN-GRU):

Objective:
In Stage 5A, we established that the latent representations learned by the GRU model contain a very strong amount of subject-specific information. Although the model was trained only for fatigue classification, a simple linear probe was able to predict the subject identity with nearly **100% accuracy**, demonstrating severe **subject identity leakage**.

This finding led to an important question:
> Can we force the model to learn features that are useful for fatigue detection while simultaneously removing subject-specific information?
To investigate this, Stage 5B introduces a **Domain-Adversarial Neural Network (DANN)** using a **Gradient Reversal Layer (GRL)**. The expectation was that adversarial training would encourage the encoder to produce subject-invariant representations, thereby improving cross-subject generalization under the Leave-One-Subject-Out (LOSO) evaluation protocol.


What is DANN?
A Domain-Adversarial Neural Network is designed to solve problems where the model should ignore some unwanted information while learning the main task.
In our case, the two tasks are:
* Primary Task: Predict the fatigue level.
* Adversarial Task: Predict the subject identity.
The architecture consists of three components:

1. Shared GRU Encoder:
   * Learns a latent representation from the EEG sequence.

2. Fatigue Classification Head:
   * Predicts the fatigue class from the latent representation.

3. Subject Classification Head:

   * Attempts to predict which subject generated the EEG sequence.
Between the encoder and the subject classifier, a **Gradient Reversal Layer (GRL)** is inserted.
During forward propagation, the GRL behaves like an identity function and passes the features unchanged.
During backpropagation, however, it reverses the gradients from the subject classifier.
As a result:
* The subject classifier tries to maximise subject classification accuracy.
* The encoder receives the opposite gradient and therefore tries to make subject classification as difficult as possible.
If successful, the encoder should gradually remove subject-specific information while preserving fatigue-related information.

Experimental Setup:

The DANN implementation was integrated into the existing GRU pipeline without changing any other component of the project.
The following remained identical to the original GRU experiment:
* SEED-VIG dataset
* DE-LDS features
* Preprocessing pipeline
* LOSO evaluation protocol
* Label thresholds
* Optimizer
* Learning rate
* Evaluation metrics
* Validation strategy
Only the model architecture changed by adding the adversarial subject classification branch.
The model was evaluated using several values of the adversarial loss weight (α):
* α = 0.05
* α = 0.10
* α = 0.50
* α = 1.00
This ablation study was performed to determine whether stronger adversarial training could better suppress subject identity information.

Results:
The fatigue classification accuracy obtained for each adversarial weight is shown below.

| Alpha               | Fatigue Accuracy | Subject Probe Accuracy |
| ------------------- | ---------------- | ---------------------- |
| 0.00 (Original GRU) | 42.42%           | 99.99%                 |
| 0.05                | 41.71%           | 100.00%                |
| 0.10                | 40.58%           | 100.00%                |
| 0.50                | 40.86%           | 100.00%                |
| 1.00                | 46.05%           | 100.00%                |

The primary observation is immediately apparent.
Changing the adversarial loss weight had almost no effect on the amount of subject information contained in the learned representations.
Across every alpha value tested, the probe classifier still identified the subject with **100% accuracy**.

Interpretation of the Probe Results:
The probe experiment is the most important evaluation in Stage 5B.
The purpose of adversarial training was to remove subject-specific information from the latent representation.
If this had been successful, the probe accuracy should have decreased dramatically.
For 21 subjects, random guessing would achieve only approximately **4.76% accuracy**.
Instead, the probe achieved **100% accuracy**.
This means that the learned representations still contain enough information to perfectly identify every subject.
In other words, the encoder continues to preserve subject identity despite being explicitly trained not to.
Therefore, the Gradient Reversal Layer failed to produce subject-invariant representations.

Fatigue Classification Performance:
The fatigue classification accuracy also provides useful insights.
The original GRU achieved a LOSO accuracy of approximately **42.42%**.
The DANN models achieved accuracies between **40% and 46%**, depending on the adversarial weight.
Although α = 1.0 produced the highest observed accuracy (46.05%), the probe accuracy remained unchanged at 100%.
This means that the small increase in fatigue accuracy cannot be interpreted as successful identity removal.
Instead, it is more likely to represent normal variation between LOSO folds rather than a systematic improvement.
This conclusion is further supported by the subject-wise comparison.

Out of the 21 subjects:
* 10 subjects showed improved accuracy.
* 10 subjects showed reduced accuracy.
* 1 subject remained unchanged.
The improvements and degradations are almost perfectly balanced.
This suggests that DANN did not consistently improve cross-subject generalization.

Early Stopping Behaviour:
Another interesting observation is that every LOSO fold terminated after exactly **8 epochs**, regardless of the adversarial loss weight.
Normally, different subjects require different numbers of training epochs before convergence.
The fact that every fold stopped at exactly the same epoch suggests that training reached a plateau almost immediately.
The validation loss also remained within approximately **1.1–1.3** throughout training.
For a three-class classification problem, the entropy of a completely uniform prediction distribution is approximately **ln(3) ≈ 1.099**.
Therefore, the observed validation loss indicates that the model never moved far away from the uncertainty region before early stopping occurred.
This suggests that the adversarial objective may have made optimization significantly more difficult.
Although this observation alone does not prove why DANN failed, it indicates that the adversarial training objective was not effectively influencing the encoder.

Why Might DANN Have Failed?
The experiments clearly demonstrate that DANN did not remove subject identity.
However, the exact reason cannot be determined solely from these experiments.
Several plausible explanations exist.

1. Strong Subject Identity in EEG Features:
The DE-LDS features used in SEED-VIG may already contain stable subject-specific spectral characteristics.
If the input features themselves strongly encode subject identity, then removing this information at the representation level becomes extremely difficult.
The encoder simply preserves information that is already present in the input.

2. Temporal Structure of the Dataset:
Each training sample consists of an entire recording session containing **885 consecutive timesteps** from a single subject.
Consequently, every timestep within a sequence belongs to exactly the same subject.
The subject classifier therefore receives a very strong and highly consistent identity signal.
The Gradient Reversal Layer may not generate gradients strong enough to overcome this consistent information.

3. LOSO Evaluation:
Under LOSO evaluation, the adversarial subject classifier is trained using only the training subjects.
The held-out test subject is never observed during adversarial training.
As a result, the encoder is encouraged to confuse only the identities present in the training folds.
It is possible that this limits the ability of standard DANN to learn truly subject-independent representations.

4. Representation-Level Adversarial Training May Not Be Sufficient:
The Gradient Reversal Layer attempts to modify the learned representation.
However, if subject identity is already deeply embedded within the input feature space, then modifying only the latent representation may not be enough to remove it completely.
More advanced methods that explicitly disentangle subject and fatigue information may be required.


Key Findings from Stage 5B:
Stage 5B produced several important findings.
First, adding a Domain-Adversarial Neural Network did not reduce subject identity leakage.
Second, increasing the adversarial loss weight across multiple values had essentially no effect on the probe accuracy.
Third, fatigue classification performance remained similar to the original GRU model, indicating that adversarial training did not produce a consistent improvement in cross-subject generalization.
Finally, the experiments suggest that the identity leakage observed in Stage 5A is substantially more difficult to eliminate than initially expected.

Overall Conclusion:
The outcome of Stage 5B should not be viewed as a failed experiment.
Instead, it represents an important negative result.
The experiments demonstrate that standard Domain-Adversarial Neural Networks are insufficient for removing subject identity leakage in EEG fatigue detection under the current LOSO experimental setting.
Combined with the findings from Stage 5A, the results suggest that subject identity is deeply embedded within the learned representations and cannot be eliminated simply by adding an adversarial training objective.
This significantly improves our understanding of why cross-subject fatigue detection remains a difficult problem.

Research Story So Far:
At this stage, the research has established the following sequence of findings:
* Stage 1–4: Three different architectures (MLP, BiLSTM and GRU) achieved high within-subject accuracy (approximately 83–84%) but much lower LOSO accuracy (approximately 39–42%), demonstrating severe cross-subject generalization difficulty.
* Stage 5A: Linear probing revealed that all three architectures encode subject identity with nearly perfect accuracy, providing direct evidence of subject identity leakage.
* Stage 5B: Domain-Adversarial Neural Networks were introduced to suppress subject identity. Despite testing multiple adversarial strengths, the probe continued to achieve 100% accuracy, indicating that standard adversarial training failed to remove identity information.
Together, these findings establish that subject identity leakage is a major obstacle in EEG fatigue detection and that standard adversarial learning alone is insufficient to solve this problem.

Possible Future Work:
The results obtained in Stage 5B naturally suggest several future research directions:
* Investigate whether subject identity originates directly from the DE-LDS feature representation rather than from the neural network itself.
* Explore feature-level normalization techniques that explicitly reduce inter-subject variability before model training.
* Develop representation disentanglement methods that separately model fatigue-related and subject-related information.
* Evaluate more advanced domain adaptation techniques beyond standard DANN, such as Conditional DANN, Maximum Mean Discrepancy (MMD), adversarial contrastive learning, or invariant risk minimization.
* Study whether subject-independent EEG representations can be learned through self-supervised pretraining or personalized calibration strategies.
