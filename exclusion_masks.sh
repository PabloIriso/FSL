#!/bin/bash

DIR="/media/estela/HD_2/Pablo/Analysis"  #working directory

for group in Controls Patients; do
    echo $group
    for folder in $DIR/$group/*; do
        name=$(basename "$folder") 
        echo $name 

        mkdir "$DIR/$group/$name/Exclusion_masks" #directory where the exlcusion masks will be stored
        
        fslmaths "$DIR/$group/$name/CSF_mask/FA_C3.nii.gz" -thr 0.4 -bin "$DIR/$group/$name/CSF_mask/FA_C3.nii.gz" #binarize and threshold CSF

        for side in left right; do
            for cortical in caudate accumbens putamen; do # Executive Motivational Motor; do

                #substract the cortical region from the CSF:
                fslmaths "$DIR/$group/$name/CSF_mask/FA_C3.nii.gz" -sub "$DIR/$group/$name/Cortical_masks/$cortical/FA_image_${side}_normalized.nii.gz" -bin "$DIR/$group/$name/Exclusion_masks/csf_minus_${cortical}_${side}.nii.gz" #CSF mask minus cortical mask
                
                #addition of the midline:
                if [[ "$side" == "left" ]] #if we are computing the left side mask, we will need to add the right hemisphere mask so we can avoid tracts going into that direction
                then
                    
                    fslmaths "$DIR/$group/$name/Exclusion_masks/csf_minus_${cortical}_${side}.nii.gz" -add "$DIR/$group/$name/Middline_masks/right_hemisphere_FA.nii.gz" -bin "$DIR/$group/$name/Exclusion_masks/exclusion_mask_CSF_middline_${cortical}_${side}.nii.gz"  #addition of the right hemisphere mask

                else #on the other hand, if we are computing the right side mask, we will need to add the left hemisphere mask 
                   
                    fslmaths "$DIR/$group/$name/Exclusion_masks/csf_minus_${cortical}_${side}.nii.gz" -add "$DIR/$group/$name/Middline_masks/left_hemisphere_FA.nii.gz" -bin "$DIR/$group/$name/Exclusion_masks/exclusion_mask_CSF_middline_${cortical}_${side}.nii.gz" #addition of the left hemisphere mask

                fi                

            done;
        done;
    done;
done; 


#add to the exclusion mask the other cortical masks that we do not want to take into account

for group in Controls Patients; do
    echo $group
    for folder in $DIR/$group/*; do

        name=$(basename "$folder")  #obtain subject name
        echo $name #print subject name

        for side in left right; do

            fslmaths "$DIR/$group/$name/Exclusion_masks/exclusion_mask_CSF_middline_accumbens_${side}.nii.gz" -add "$DIR/$group/$name/Cortical_masks/putamen/FA_image_${side}_normalized.nii.gz" -add "$DIR/$group/$name/Cortical_masks/caudate/FA_image_${side}_normalized.nii.gz"  -bin "$DIR/$group/$name/Exclusion_masks/exclusion_mask_total_accumbens_${side}.nii.gz" #exclusion mask with caudate and putamen exclusions

            fslmaths "$DIR/$group/$name/Exclusion_masks/exclusion_mask_CSF_middline_caudate_${side}.nii.gz" -add "$DIR/$group/$name/Cortical_masks/putamen/FA_image_${side}_normalized.nii.gz" -add "$DIR/$group/$name/Cortical_masks/accumbens/FA_image_${side}_normalized.nii.gz"  -bin "$DIR/$group/$name/Exclusion_masks/exclusion_mask_total_caudate_${side}.nii.gz" #exclusion mask with putamen and accumbens exclusions

            fslmaths "$DIR/$group/$name/Exclusion_masks/exclusion_mask_CSF_middline_putamen_${side}.nii.gz" -add "$DIR/$group/$name/Cortical_masks/accumbens/FA_image_${side}_normalized.nii.gz" -add "$DIR/$group/$name/Cortical_masks/caudate/FA_image_${side}_normalized.nii.gz"  -bin "$DIR/$group/$name/Exclusion_masks/exclusion_mask_total_putamen_${side}.nii.gz" #exclusion mask with caudate and accumbens exclusions

        done;
    done;
done;
