# Tractography_Huntington_Disease

The goal of probabilistic tractography is to obtain a connectivity index along a white matter pathway that reflects fibre organization and is sensitive to pathological abnormalities contributing to disability. Here, we present the bash scripts used to implement FSL (https://fsl.fmrib.ox.ac.uk/fsl/fslwiki/FSL) functions to obtain the white matter tracts associated with Hungtinton-Disease. In this manner, the first script we used was:

*rois_convert.sh --> Convert our regions of interest, defined as .img format into nii.gz*

In order to get our 

**BEDPOSTX** stands for *Bayesian Estimation of Diffusion Parameters Obtained using Sampling Techniques*. The X stands for modelling Crossing Fibres. bedpostx runs Markov Chain Monte Carlo sampling to build up distributions on diffusion parameters at each voxel. It creates all the files necessary for running probabilistic tractography.  

A whole range of tools is available to guide the tractography. The most powerful of these is to select the seed region, which defines where the streamlines originate. In addition to this we can set termination masks to stop the streamlines, and waypoint/exclusion masks to filter out those streamlines not relevant for our analysis:  

*exclusion_masks.sh* --> *We can set termination masks to stop the streamlines, and waypoint/exclusion masks to filter out those streamlines not relevant for our analysis (e.g., filter out the streamlines not part of our white matter tract of interest). Pathways will be discarded if they enter the exclusion mask. For example, an exclusion mask of the midline will remove pathways that cross into the other hemisphere.*  


After bedpostx has been applied it is possible to run tractography analyses using **probtrackx2**. Briefly, probtrackx2 produces sample streamlines, by starting from some seed and then iterate between (1) drawing an orientation from the voxel-wise bedpostX distributions, (2) taking a step in this direction, and (3) checking for any termination criteria. These sample streamlines can then be used to build up a histogram of how many streamlines visited each voxel or the number of streamlines connecting specific brain regions. This streamline distribution can be thought of as the posterior distribution on the streamline location or the connectivity distribution.  

*probtrackx_accumbens.sh* -->  

*probtrackx_caudate.sh* -->   

*probtrackx_putamen.sh* -->  


*FA_values.sh -->  This script takes a fdt_paths file obtained from Probtrackx and normalizes it by streamlines in order to apply a probability threshold. Afterwards, it obtains the FA, radial diffusivity and mean diffusivity values multiplying the normalized image by the reference image and computing the mean.*  


https://fsl.fmrib.ox.ac.uk/fsl/fslwiki/FDT/UserGuide



 
  
subcortical_masks.sh -->   
sub_masks_test.sh -->  

Other useful scripts, that where used to copy and paste files we needed from different directories:  
*bed_cp.sh*   
*dti_cp.sh*  
*exclusion_cp.sh*  
*rename_masks.sh*  

exclusion_cp <- Copia los archivos necesarios para la obtencion de las exlcusion masks desde los ficheros de Irene /CSF y Middline)
Exlcusion_masks <- Crea las mascaras de exclusion.



