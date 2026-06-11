Day 1 Objectives Completed:
1. Understanding the basics of EEG. Strengthened fundamentals.
2. Understanding the Underlying Mechanism of how Signals are recorded
3. Understanding the different types of Brain waves determining the current mental state and cognitive fatigue.
4. Understanding the 10-20 System
5. Understanding the basics of the PERCLOS method. 


1. Domain Understanding
  A)  EEG Basics
Jay-
Electroencephalography is an electrophysiological method used to understand and study the electrical activity of a human brain. In this method, electrodes are placed on the scalp to gain insights from the electrical signals from the neocortex and allocortex (two parts of the brain’s cerebral cortex). 
Neocortex (‘New’ Cortex) constitutes about ~90% of cervical cortex and Allocortex (~10%). In simple terms Allocortex drives basic emotions, memories, sensing smell stuff. Whereas Neocortex is responsible for driving conscious complex thoughts and actions.

Underlying Mechanism: Note to remember that Neurons are electrically charged. When neurons send signals, they push ions out into the fluid. When millions of neurons sync and align with each other and push the ions together, they reach the top, towards the scalp of the brain where the metal electrodes (good conductors of electricity) attract and the ions get into it. Then the voltage difference between two electrodes is recorded and thus the data is recorded. 

The clearer Picture: The signal being sent to the scalp is called *Postsynaptic Dendritic Currents*.

Here is the step-by-step procedure of how the electrical signals are generated, why they reach the scalp instead of traveling down your arm, and how the EEG machine records them:

Because before we further dive into understanding the electrical signals received at electrodes, we need to have a clearer understanding of why these signals travel to the scalp (surface) of the brain. My simple doubt is to understand it, suppose I want to make a movement in my arm and for that the neurons in my brain obv send signals down towards my arm, but why would these signals go to the scalp and not towards the arm. Is it the electrodes attracting signals or what?


**Step 1: The Brain Creates Two Different Signals (Clearing your doubt)**
When your brain decides to move your hand, the neurons in your cortex actually generate two different types of electrical activity:
*   **The Command (Action Potential):** The actual message to move your hand is sent as an "action potential" down a long, wire-like fiber called an axon directly to your arm. This signal is incredibly fast and its electrical field decreases very rapidly, meaning it does not reach the scalp and **cannot** be recorded by an EEG. 
*   **The Preparation (Postsynaptic Potential):** Before sending the command, the neuron must process information in its receiving branches, called dendrites. This processing creates a different kind of electrical current that moves up and down the dendrites. **This is the signal the EEG actually records**. 

**Step 2: Pointing in the Right Direction**
In the outer layer of your brain (the cortex), the specific cells responsible for the EEG signal are called **pyramidal neurons**. These cells are specially organized so that their dendrites stretch upwards, pointing directly toward the surface of your skull. Because they are pointing up, the electrical fields they generate radiate upward toward the scalp, rather than downward toward your body.

**Step 3: Strength in Numbers (Summation)**
The electrical charge from just one of these pyramidal neurons is far too tiny to be detected on the outside of your head. For the signal to be strong enough, thousands or millions of these neurons must be lined up perfectly parallel to one another and process information at the exact same time (synchronously). When they fire together, their tiny individual electrical fields combine to form one massive signal. 

**Step 4: The Ripple Effect (Volume Conduction)**
As these millions of neurons process information, they pump charged particles (ions) into the fluid around them. Because ions with the same charge repel each other, they push their neighbors away, and those neighbors push the next ones. This creates a rippling wave of electrical charge that travels outward from the brain, pushing through the fluid, the brain's coverings, and the skull until it reaches the skin of your scalp. This process is known as **volume conduction**. Along the way, the bone and tissue act somewhat like resistors in an electrical circuit, which distorts and weakens the signal slightly.

**Step 5: The Electrodes Catch the Wave**
The EEG technician places metal electrodes on your scalp, usually using a special conductive gel to help the signal pass through your skin. When the rippling wave of ions reaches the surface of your head, it interacts with the metal in the electrodes. The wave of ions literally "pushes and pulls" the electrons inside the metal, transferring the brain's electrical activity directly into the wires of the EEG machine.

**Step 6: Recording the Data**
Inside the EEG machine, a voltmeter measures the exact difference in this "push and pull" voltage between two different electrodes. Because the signal is still very weak by the time it reaches the scalp (measured in microvolts), an amplifier boosts the signal up to 100,000 times so it can be easily read. Finally, a computer converts these voltage differences into numerical data over time, generating the wavy lines you see on an EEG screen.

Brain Waves & Patterns: Before we understand the different Brain wave patterns meaning different things for the operationality state of the brain, a doubt regarding why the processing signal is used to determine it and not the action potential signal. 
      Action potentials are the final commands that tell your muscles for eg to make a move. *Fatigue* itself is not a physical failure of the muscle, it’s heavily tied to the brain's overall state of alertness and mental processing. 

If you wanted to measure pure *muscle* fatigue, you would indeed need to look at the action potentials reaching the muscles. However, an EEG does not record these fast-moving action potentials. Instead, because an EEG measures the synchronized processing (the postsynaptic potentials) of millions of neurons, it is perfectly suited to capture **mental fatigue, drowsiness, and your overall level of consciousness**. 

In short, while action potentials determine if a specific muscle *can* contract, the postsynaptic potentials recorded by an EEG reveal the **overall operational state of the brain**. By monitoring the shift from fast, active processing waves (Beta) to slower, idling waves (Theta), an EEG can accurately identify when a person is experiencing mental fatigue or drowsiness.


Doubt: Do electrodes on the scalp capture the ions pushed towards the scalp or capture the brain waves from the neural signal activity?
The EEG electrodes on your scalp do not physically capture ions or catch a tangible "brain wave". Instead, as a rippling wave of charged ions reaches your scalp, their electrical force interacts with the metal electrodes by pushing and pulling the electrons inside them. The EEG machine's voltmeter simply measures this difference in "push and pull" voltage between two electrodes continuously over time. Finally, a computer plots these changing voltage measurements onto a visual graph, creating the wavy, up-and-down lines that we refer to as "brain waves".
10-20 System: It is the standardized method that maps out or tells where exactly to put those 19 recording electrodes on the scalp and 1 ground electrode. Now the voltage difference data that we get, is it only between any two particular electrodes or how is the data recorded?
        First pint to note: Each electrode is present at a different location on the scalp, thus recording the brain signals right below it. Thereby like this all the locations are covered on scalp.
Waveform–Channel. Every single channel represents the voltage difference between exactly two electrodes. 
However, the machine does not just look at two electrodes overall. Instead, it continuously compares pairs of electrodes across the entire 19-electrode array to generate multiple channels of data at the same time.

Now How are pairs chosen? There must be a methodology of choosing pairs. They are called Montages.
a) Refrence Montages b) Sequential Montage c) Average Reference Montage

Doubt: How this becomes a time-series numerical dataset? 
To turn these continuous voltage differences into the numbers we see in a dataset, the EEG machine uses an analog-to-digital converter. This converter takes a numerical snapshot of the voltage difference for every single paired channel hundreds of times every second. In clinical settings, this sampling rate is typically between 256 and 512 times per second (Hz).
Bringing it all together: When you look at a time-series EEG dataset, you are looking at multiple channels of voltage differences running in parallel over time. For example, if you are using a referential montage with 19 electrodes sampling at 256 Hz, your dataset will have 19 distinct columns (one for each active electrode compared to the reference), and every single second of recording will add 256 new rows of numerical voltage data to each column.
B) Cognitive Fatigue
**Cognitive fatigue**, or mental exhaustion, happens when your brain has been actively concentrating for a long time and struggles to maintain its high level of alertness. 

To understand how this works in relevance to our previous discussion, we have to look at the brain's "processing hum" (the **postsynaptic potentials**), rather than the final physical commands sent to your muscles (the **action potentials**). 

Here is what happens in the brain during cognitive fatigue:

*   **The Active, Alert Brain:** When you are actively thinking, problem-solving, or focusing, the pyramidal neurons in your cortex are processing information rapidly,. Because the neurons are working hard and firing fast, the EEG records rapid, low-amplitude voltage fluctuations known as **Beta waves (13–30 Hz)**,. 


*   **The Transition to Fatigue:** Just like a computer processor can't run at maximum speed forever without overheating, your brain's neuronal networks eventually tire from this intense level of active processing. As mental fatigue sets in, the neurons can no longer sustain the rapid, complex firing patterns of the Beta waves,.


*   **The "Idling" Brain:** As you transition from feeling focused to feeling drowsy or mentally drained, your neurons begin to fire more slowly and rhythmically. The EEG shows a distinct shift away from fast Beta waves and begins recording **Theta waves (4–7 Hz)**. In adults and teenagers, these slower Theta waves are a direct clinical indicator of idling, drowsiness, and an overall decrease in alertness,.

In short, cognitive fatigue is not your muscles failing to receive a command; it is your brain's overall processing center shifting from a high-speed, active state (**Beta waves**) down to a slower, resting or drowsy state (**Theta waves**),. Because an EEG is specifically designed to measure the synchronized processing of cortical neurons, it is the perfect tool for identifying exactly when this mental shift occurs.


C) PERCLOS
Perclos stands for Percentage of Eyes closed. It’s a computer vision based method to measure how much a person’s eyes are closed over a specified period of time and determines how tired or drowsy there is. 
     Unlike an EEG, which measures the invisible electrical "processing hum" inside the brain, PERCLOS relies on computer vision to track a physical, outward sign of fatigue—drooping eyelids. When the percentage gets too high, a monitoring system can alert the person that they are falling asleep.

How fatigue is calculated using PERCLOS? PERCLOS calculates fatigue by tracking the percentage of time a person's eyes are mostly or completely closed (usually 80% to 100% covering the pupil) over a specific time window, such as one minute.
