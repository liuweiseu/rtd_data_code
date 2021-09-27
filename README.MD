rtd_data_code
=
What's in the repo?
-
Here are three folders in this repo:
* rtd_rw:<br>
  The m files in this folder complete some basic operations, such as opening the rtd data file, reading data and closing the rtd data file.
* folding:<br>
  The m files in this folder complete the folding work, which is based on the rtd_rw.
* rtd_data:<br>
  rtd data file is in thi folder.

How to use the code to process the rtd data file?
-
Two files are most important for the data processing:
* ./folding/RTDDataProcess.m:<br>
  This is the main m file for the data processing.<br>
  It open the data file,read the data from rtd data file, and then finish the folding work.
* ./folding/Pulsar_info.txt:<br>
  The periods of pulsars are recorded in this file.
 
 Therefore, you need to add the period of the pulsar first, and then run RTDDataProcess.m.<br>
 (Note: The estimated period of J0835-4510 on June 17th has already been recorded in the Pulsar_info.txt by default)
