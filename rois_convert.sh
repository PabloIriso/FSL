#!/bin/bash
# Convert our regions of interest, defined as .img format into nii.gz
DIR="/media/estela/HD_2/Pablo/Analysis"; cd "$DIR" || exit
for file in $DIR/ROIS/rs_roi/*.img; do
fslchfiletype NIFTI_GZ "$file"
done;

# Create new folders
cd "$DIR" || exit
for ele in accumbens putamen caudate; do

    if [ ! -d "$DIR/Cortical_masks" ]; then 
    mkdir $DIR/Cortical_masks 
    fi
    if [ ! -d "$DIR/Cortical_masks/$ele" ]; then 
    mkdir $DIR/Cortical_masks/$ele
    fi
done;  


# Move to new folder CorticalMasks
cd "$DIR" || exit
DIR="/media/estela/HD_2/Pablo/Analysis"; cd "$DIR" || exit
for file in $DIR/ROIS/rs_roi/*; do
    if [[ $file =~ accumbens ]]; then
        mv "$file" $DIR/Cortical_masks/accumbens
    elif [[ $file =~ putamen ]]; then
        mv "$file" $DIR/Cortical_masks/putamen
    elif [[ $file =~ caudate ]]; then
        mv "$file" $DIR/Cortical_masks/caudate
    fi
done;
