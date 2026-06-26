### Stage 0: Dataset audit — verify the data is what we think it is before building anything on top of it

Block1: 
<br>
Simply loading the dataset, checking number of .mat files <br>
Datasets: EEG_Features_5bands, perclos_labels

This block checks for all .mat files and stores them in a list mat_files. 
46 Rows (.md files)

Block2: <br>
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

