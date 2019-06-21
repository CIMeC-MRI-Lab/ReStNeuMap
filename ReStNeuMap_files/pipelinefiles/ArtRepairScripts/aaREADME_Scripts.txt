NOTE:  These scripts are old and not currently supported. 

The scripts are provided as an example of a batch method where a user who is not up to date on all the latest image processing methods can get reproducible results on problematic fMRI data from clinical subjects.

The Alphascript programs run the entire ArtRepair preprocessing pipeline. The pipeline includes the usual SPM functions of slice timing, realignment, and normalization. The pipeline includes artifact detection and repair for rapid scan-to-scan motion, for possible spontaneous deep breaths by a subject, and for possible electronic noise on image slices. The pipeline also includes adjustments for realignment effects (equivalent to adding motion regressors to the GLM), and accurate adjustments for slow large amplitude motions (2-5 mm). When the pipeline is used, there is no need to add realignment parameters or null covariates to the GLM design.


SPECIFIC NOTES

The main program for batch preprocessing is alphascript.m.

Option 1: Bad slice detection. 
     The default method is changed to detect and repair bad slices from the previous option to median filter all data. The bad slice detection method works well when noise events are sparse (less than 1 bad slice per volume), and this method does not perturb as much data. The median filter is designed for heavy noise, and affects all the data. Using >>art_despike is a good alternative for heavy noise.

Option 10: Spatial Smoothing (Group) is NOT recommended.
    One function of spatial smoothing is to form averages over different subjects for which the sulci may be located in different places on different individuals. The ArtRepair pipeline already includes 4 mm individual spatial smoothing, and additional smoothing from the reslice and interpolation operations. During the GLM, SPM will calculate a smoothness of the residuals (FWHM and resel size), and these values are typically 10-12 mm for the pipeline without using group smoothing. These smoothness values are similar to using typical processing methods, possibly because art_motionregress does a very good job of removing residual motion effects. 
    If group smoothing is also applied, the residuals become very spatially smooth (large FWHM) causing a loss of detection power at the FWE cluster level. Thus we recommend not using the group smoothing step.

Image file formats, .img or .nii?
  Alphascript and its subroutines were written in 2008 when the .img file format was commonly used. Some parts of the code may not work when .nii format images are used. While we are not maintaining this software, the fix is pretty simple. If you have experience with Matlab, just replace .img$ with .nii$ in all the routines and the scripts will probably work.

Comparison to the ArtRepair programs
  The subroutines of Alphascript, with names that have the prefix alpha, are frozen versions (from 2008) of the ArtRepair software, and may not exactly agree with current versions. 

