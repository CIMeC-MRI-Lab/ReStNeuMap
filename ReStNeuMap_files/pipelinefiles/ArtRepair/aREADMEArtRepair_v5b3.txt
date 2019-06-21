ART_REPAIR v5b3  (Sept. 2015)
    Supports SPM12, but this beta version has not been thoroughly tested with it.

COMPATIBILITIES
    SPM12, SPM8, SPM5, and backwards compatible to SPM2
    Compatible with 3D nifti files, or AnalyzeFormat.
    NOT compatible with 4D nifti files.
    
New features of v5b  (Mar 2015, Aug 2015)
    Supports SPM12
    art_groupoutlier will run in Matlab without Statistics toolbox
    art_motionstats,  summarizes motion and rapid motion characteristics for a subject
    art_motionstatsBatch,  same as above for a cohort of subjects
    v5b:  Fixed bugs in art_despike and art_groupcheck (from Mike Schmitgen)
    v5b1: Fixed bugs: Readme converted to .txt, Folder name changed, subfolder removed.
    v5b1: Fixed bug for .nii compatibility in art_motionregress
    v5b3: Fixed bugs for .nii compatibility in art_summary, art_groupcheck
    v5b3: Fixed bugs for .nii compatibility in art_percentscale
    
New features of v4.1 (November 2012)
    Upgrades to art_movie, with better display, larger capacity, more options
    Upgrades to art_slice, to improve performance, and visually flag bad slices 
   
     Detailed changes
     ----------------
     art_movie  (from Dorian Pustina)
        Can select mean image, or preceding image, as contrast reference
        Display is automatically sized for the montage window
        Size limit is expanded to handle many times more images
        Fixed bugs in text sizing
     art_slice  (from Dorian Pustina)
        Bad slices can be displayed in the contrast movie window
        Uses spatial interpolation from neighboring slices to repair slices,
           if the usual temporal interpolation would use a bad slice.
        Wait bar added to the user interface
    
   
New features of v4 (June 2009)
   It is named ArtRepair in the SPM toolbox window.
   New art_motionregress, an alternative to using motion regressors
   New art_despike,  removes spikes and slow-varying background voxelwise
   New art_rms,  calculates image of rms variations of set of images
   New art_plottimeseries,  plots timeseries for a voxel
   
CHANGES from v2.2 (2007) are:
   Same toolbox serves both SPM5 and SPM2.

   Assumes that each session is realigned and repaired separately.
      This approach is similar to SPM standard procedures,
      and clinical subjects commonly move between sessions.
      Previous version v2.2 assumed all sessions were realigned together.

   New art_groupcheck to help a user validate group results
   New art_groupoutlier program to identify outlier subjects
   New art_groupsummary program to find GQ scores for a group result
   New art_percentscale program to find percent scaling.
      Documentation is on the ArtRepair website.
      
   Updated art_global
       User must now realign and repair each session separately.
    
   Simplified art_redo. User must now repair and validate results manually.
       Previously, the repair and compare functions were embedded,
       which made the code brittle.
    
   Improved reliability of scaling in art_movie; now mean image is 1000.
    
   Fixed bug in art_summary in order to scale contrasts correctly
    
   Removed art_batch programs, and art_deweightSPM program
   
BUG FIXES from v3
   Add use deweight as default in art_redo
   Improve functionality across SPM versions with strcmp command.

     
Detailed changes
----------------

art_motionregress
   Estimates and removes interpolation artifacts before design estimation.
   Fractional amount removed is greater at edges, less in center of brain.
   Writes new images with prefix "m".
   Use on realigned, resliced images. 
   Must use before normalization, else large images use huge memory.

art_despike
   Clips spikes more extreme than a user-specified threshold, default=4%.
   Option for two different high-pass filters, or an HRF matched filter
   Despike and filter can be applied separately, or in combination.
   Writes new images with prefix "d".
   Must use before normalization, else large images use huge memory.

art_groupcheck
   Allows user to review group results for contrasts and ResMS by voxel.
   Allows user to review all contrasts for all subjects using a movie.
   Allows user to find outlier subjects.
   Scales contrasts into percent signal change for viewing.

art_groupsummary
   Calculates Global Quality scores for a group result
   
art_groupoutlier
   Compares Global Quality scores across subjects to find outlier subjects.
   Suggests good subgroups to use.
   
art_percentscale
   Calculates scale factors to convert results into percent signal change,
   as described in the document FMRIPercentSignalChange.
   
art_global
   User should realign and repair each session separately.
   Global intensity threshold varies more as motion threshold is changed.
   Global intensity threshold is linked to adaptive motion threshold.
   
art_activationmap3
   The colormap used in art_groupcheck to display the contrast images.
   
art_redo
   User must repair scans first, each session repaired separately.
   Program will apply deweighting, and estimate results for repaired files.
   Program will write a new SPM.mat file to a new results folder.
   User must compare results, before and after, with Global Quality.
   (The previously used embedded functionality in v2.2 was brittle.)
   
art_movie
   Fixed bug that caused movie frame to shift (from Volkmar Glauche).
   Image intensities are now scaled so that mean of image is 1000,
   which means that scale value of 160 is exactly 16% signal change.
   Previously scaling was based on peak intensity, so output values
   were not as reliable.

art_summary
   Scales Global Quality for contrasts by the sum of the positive terms of 
   the contrast vector c. Previously it was the RMS norm of c. 
 
   
NOTES for v2.2  (Aug. 2007)
spm_ArtRepair2 or spm_ArtRepair5
   Menu opens in SPM Interactive Window
   with same menu format as many other Toolbox programs..
   This change makes menu compatible with Matlab 6.5.1.
   (Old style menu is available as:  >> old_ArtRepair5)

art_global
   Also marks scan BEFORE large movement for repair.
      Before it only marked the scan after.

   Allows RepairType = 2 to not add margin in automatic mode
   (planning for compatibility with motion regressors).

   Add "Clip" button to mark all movements larger than 3 mm.

   Fixed logic bug for case when user applies his own mask.
 
art_redo
   Changed logic to redo an i.i.d. design as an i.i.d design.
   Previously, i.i.d. became AR(0.2) from an interaction bug with SPM.

   Automatically scales for peak of design regressor, and 
   norm of the contrast vector.


