# ReStNeuMap v0.3
**ReStNeuMap: a tool for automatic extraction of resting state fMRI networks 
(tested in neurosurgical practice)**

Based on:
1. Moretto M [1], Luciani BF [1], Zigiotto L [2], Saviola F [1], Tambalo S [1], Cabalo DG [1], Annichiarico L [2], Venturini M [2], Jovicich J [1], Sarubbo S [2]. Resting state functional networks in gliomas: validation with Direct Electric Stimulation of a new tool for planning brain resections. Neurosurgery, 2024.
DOI: 10.1227/neu.0000000000003012 
 
2. Zaca D [1], Jovicich J [1], Corsini F [2], Rozzanigo U [3], Chioffi F [2], Sarubbo S [2]. ReStNeuMap: a tool for automatic extraction of resting state fMRI networks in neurosurgical practice. Journal of Neurosurgery, 2018. 
DOI: 10.3171/2018.4.JNS18474.


[1] Center for Mind/Brain Sciences, University of Trento, Via delle Regole 101, 38123 Trento (Italy) </br>
[2] Division of Neurosurgery, Structural and Functional Connectivity Lab Project, S. Chiara Hospital, Trento APSS, 38122 Trento (Italy)
[3] Department of Radiology, Neuroradiology Unit, S. Chiara Hospital, Trento APSS, 38122 Trento (Italy)

## 


1. **OVERVIEW**</br>
	1.1. Credits</br>
	1.2. Disclaimer</br>
	1.3. Tool structure</br>

2. **INSTALLATION STEPS**</br>
	2.1. Requirements</br>
	2.2. Install</br>

3. **LICENSE**

4. **ACKNOWLEDGMENTS**


## 1. OVERVIEW

### 1.1 Credits

This is a new version of the ReStNeuMap tool, initially presented in “ReStNeuMap: a tool for automatic extraction of resting state fMRI networks in neurosurgical practice”, by Zacà et al. (2018).
 
An accompanying manuscript to this new release has been published in Neurosurgery. If you use our tool, please cite this work as: Moretto M, Luciani BF, Zigiotto L, et al. Resting State Functional Networks in Gliomas: Validation With Direct Electric Stimulation of a New Tool for Planning Brain Resections. Neurosurgery. Published online June 5, 2024. doi:10.1227/neu.0000000000003012
 
Our software uses and also provides functions from the following freely available tools:
- ICA-AROMA: https://github.com/maartenmennes/ICA-AROMA, implemented with Python 3.
- FMRIB Software Library (FSL), University of Oxford, U.K.
  Website: https://fsl.fmrib.ox.ac.uk/fsl/fslwiki/FSL 
  License: https://fsl.fmrib.ox.ac.uk/fsl/fslwiki/Licence
- Statistical Parametric Mapping (SPM 12), University of Cambridge, U.K.
  Website: https://www.fil.ion.ucl.ac.uk/spm/software/spm12/ 
  License: https://github.com/spm/spm12/blob/main/LICENCE.txt 

Please send any bug reports, questions, or feedback to jorge.jovicich@unitn.it.

### 1.2 Disclaimer
This software is made available to facilitate and promote use of resting-state fMRI data for research. No formal quality assurance checks were made on the software other than those described in the original publication (Moretto et al., Neurosurgery, 2024), and no formal support or maintenance is provided or implied.
The authors disclaim any and all liability for damages of any kind arising from the use of this software. Users assume full responsibility for its use at their own risk. This software is provided “as is” without any warranties, express or implied, including but not limited to warranties of merchantability or fitness for a particular purpose.

### 1.3 Tool Structure
This tool reads two input datasets (anatomical T1 MRI and resting state fMRI, both in dicom format) and computes the visual, motor and language resting state networks, as well as the Default Mode, frontoparietal and visuospatial networks, together with quality assurance metrics of the input data. For more details see Moretto et al., Neurosurgery, 2024. 
 
The package we distribute is composed by:
- ReStNeuMap_v2, a folder containing all ReStNeuMap scripts, including the ReStNeuMapNetworkTemplates folder which contains resting-state network templates. ICA-AROMA (Pruim RHR et al. 2015), implemented for Python3, is provided within the “packages” folder.
- Documentation in the form of this README file and a tutorial.


## 2. INSTALLATION
ReStNeuMap has been tested for the following Operating Systems:
- Linux, Ubuntu 16.04
- MacOS 10.13 'High Sierra'
- MacOS 11.5.2 'Big Sur'

### 2.1 Requirements
In addition, the current version runs with Python 3.6
ReStNeuMap needs: 
- At least 4GB free space
- Software to install in addition to the code and files we provide:
-- Matlab R2018a or R2018b (https://www.mathworks.com/products/matlab.html), with at least the following toolboxes:
--- Image Processing Toolbox
--- Statistics and Machine Learning Toolbox
-- SPM12: http://www.fil.ion.ucl.ac.uk/spm/software/spm12/
-- FSL 5.0.9 or 5.0.11: https://fsl.fmrib.ox.ac.uk/fsl/fslwiki
- Python packages necessary for ICA-AROMA denoising: 
--- future
--- matplotlib==2.2.0
--- numpy==1.14.0
--- pandas==0.23.0
--- seaborn==0.9.0


### 2.2. Installation steps
To install ReStNeuMap please follow the following steps:
1. Download the ReStNeuMap_v2 folder from the container (https://github.com/CIMeC-MRI-Lab/ReStNeuMap) 
2. Extract the downloaded .zip file, open matlab and add to your matlab path the ReStNeuMap_files folder with its subfolders. You can find the ReStNeuMap_files folder within the extracted ReStNeuMap_v2 folder. To do so, browse to the ReStNeuMap_files folder in matlab's 'Current Folder' panel, right click on the ReStNeuMap_files folder, and select Add to Path > Selected Folders and Subfolders.
3. Add with subfolders your spm12 directory to your matlab path as in the previous step.
4. For a guide on how to run ReStNeuMap, see the ReStNeuMap_tutorial.pdf tutorial file distributed with it.
5. Go to the ReStNeuMap_v2 folder; open the config_file.txt and change variable names accordingly, before running ReStNeuMap_v2 for the first time.

 
 ## 3. LICENSE
ReStNeuMap is a free Matlab-based neuroimaging analysis software distributed under an open-source license for non-commercial research purposes (GNU General Public License). Use of this software is governed by the following conditions:
Non-Commercial Use: This software is provided exclusively for educational, research, or personal purposes. Any direct or indirect commercial use is strictly prohibited without prior authorization from the authors. For commercial inquiries, please contact the authors directly.
For research use only: This software is provided "as is" without any express or implied warranties. The authors disclaim any responsibility for its use in diagnostic or clinical settings. Users must evaluate whether the software is suitable for their specific research needs and take all necessary precautions when using it.
Third-Party Components: This software incorporates functions from the following third-party programs, each subject to its respective license.
This software includes functions from:
- SPM12, distributed under the terms specified in SPM12's license.txt file.
- FSL, distributed under the terms of the FSL license.
- ICA-AROMA, distributed under the terms of the ICA-AROMA license.
Users are required to comply with the terms of these third-party software licenses when using this software.


## 4. ACKNOWLEDGMENTS
We would like to acknowledge Lisa Novello and Domenico Zacà for help in developing, documenting, and testing this software.
This work was supported by the Autonomous Province of Trento, Italy (Project: “NeuSurPlan and integrated approach to neurosurgery planning based on multimodal data"), the Fondazione Paolina Lucarelli Irion, Rovereto (Trento), Italy, and the Ministry of Education and Research (Department of Excellence Project, 2018-2022).
