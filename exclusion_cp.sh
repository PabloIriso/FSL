#!/bin/bash

## We want to mv the inputs for exlcusions_masks script from Irene files:

# - /CSF_mask/FA_C3.nii.gz
DIR="/media/estela/HD_2/Irene/Analysis"
for group in Controls Patients; do
    cd "$DIR/$group" || exit
    for folder in *; do
        orig="$folder/CSF_mask"
        dest="/media/estela/HD_2/Pablo/Analysis/$group/$orig"; 
        mkdir -p $dest
        cp "$orig/FA_C3.nii.gz" "$dest/" 
    done;
done;



# Midline masks
# for the left - /Middline_masks/right_hemisphere_FA.nii.gz
# for the right - /Middline_masks/left_hemisphere_FA.nii.gz
DIR="/media/estela/HD_2/Irene/Analysis"
for group in Controls Patients; do
    for side in left right; do 
        cd "$DIR/$group" || exit
        for folder in *; do
            orig="$folder/Middline_masks"
            dest="/media/estela/HD_2/Pablo/Analysis/$group/$orig"; 
            mkdir -p $dest
            cp "$orig/${side}_hemisphere_FA.nii.gz" "$dest/" 
        done;  
    done;
done;
