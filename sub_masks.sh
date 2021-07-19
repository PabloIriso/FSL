
DIR="/media/estela/HD_2/Pablo/Analysis/Controls/C01_1" #directory where the group data is
cd $DIR #enter to the directory in which we have the data
name="C01_1" #obtain the folder name (subject name)
        
        mkdir Runfirstall

        mkdir Caudate_masks #create directory where the caudate masks will be stored
        mkdir Caudate_masks/FA_transformation #create directory where the output of the transformation of caudate masks to FA space will be stored

        mkdir putamen_masks #create directory where the putamen masks will be stored
        mkdir putamen_masks/FA_transformation #create directory where the output of the transformation of putamen masks to FA space will be stored

        mkdir accumbens_masks #create directory where the accumbens masks will be stored
        mkdir accumbens_masks/FA_transformation #create directory where the output of the transformation of accumbens masks to FA space will be stored
        
        #RUN_FIRST_ALL analysis: in this step we perform segmentation of all the subcortical structures
        run_first_all -i T1/o* -o $DIR/Runfirstall #input file contains the original T1-weighted structural image

        #Obtention of right and left caudate using the corresponding intensity values of the images of substructures obtained
        fslmaths $DIR/Runfirstall/Runfirstall_all_fast_firstseg.nii.gz -thr 50 -uthr 50 $DIR/Caudate_masks/right_caudate.nii.gz #obtain the right caudate and save it to directory
        fslmaths $DIR/Runfirstall/Runfirstall_all_fast_firstseg.nii.gz -thr 11 -uthr 11 $DIR/Caudate_masks/left_caudate.nii.gz #obtain the left caudate and save it to directory

        #Obtention of right and left putamen
        fslmaths $DIR/Runfirstall/Runfirstall_all_fast_firstseg.nii.gz -thr 12 -uthr 12 $DIR/putamen_masks/left_putamen.nii.gz #obtain the left putamen and save it to directory
        fslmaths $DIR/Runfirstall/Runfirstall_all_fast_firstseg.nii.gz -thr 51 -uthr 51 $DIR/putamen_masks/right_putamen.nii.gz #obtain the right putamen and save it to directory

        #Obtention of the right and left accumbens
        fslmaths $DIR/Runfirstall/Runfirstall_all_fast_firstseg.nii.gz -thr 26 -uthr 26 $DIR/accumbens_masks/left_accumbens.nii.gz #obtain the left accumbens and save it to directory
        fslmaths $DIR/Runfirstall/Runfirstall_all_fast_firstseg.nii.gz -thr 58 -uthr 58 $DIR/accumbens_masks/right_accumbens.nii.gz #obtain the right accumbens and save it to directory
    

        #BET: in this step we perform the separation of the brain from the skull
        /usr/share/fsl/5.0/bin/bet $DIR/T1/o*.nii $DIR/T1/o_brain -R -f 0.5 -g 0 -c 104 139 138 #the input file is the original T1-weighted structural image and we will store it as "o_brain". We are using robust brain center estimation, a fractional intensity threshold of 0.5 and 104 X, 139 Y, 138 Z as voxels for centre of initial brain surface sphere (determined using Matlab SPM).
        done;
