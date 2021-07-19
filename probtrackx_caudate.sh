#!/bin/bash
DIR="/media/estela/HD_2/Pablo/Analysis"  #working directory

for group in Controls Patients; do
    echo $group
    for folder in $DIR/$group/*; do
        name=$(basename "$folder")  
        echo $name 
        for side in left right; do
            for cortical in caudate accumbens putamen; do # Executive Motivational Motor; do
                for exclusion in Exclusion No_exclusion; do

                    mkdir "$DIR/Tractography_${group}/$name" #folder that will contain probtrackx output
                    mkdir "$DIR/Tractography_${group}/$name/$exclusion"
                    mkdir "$DIR/Tractography_${group}/$name/$exclusion/caudate"
                    mkdir "$DIR/Tractography_${group}/$name/$exclusion/caudate/$side"  #folder that will contain probtrackx output of each side of the brain

                    bedpost_dir="$DIR/Bedpost_${group}/$name/dmri.bedpostX" #directory where the bedpostX output is stored

                    if [[ "$exclusion" == "Exclusion" ]] # run the analysis adding the two cortical masks not used as seed as exclusion masks

                    then 

# -x,--seed Seed volume or list (ascii text file) of volumes and/or surfaces - cortical mask of interest
# -s,--samples	Basename for samples files - e.g. 'merged'
# -m,--mask	Bet binary mask file in diffusion space

# --dir		Directory to put the final volumes in - code makes this directory - default='logdir'
# --stop		Stop tracking at locations given by this mask file
# --avoid		Reject pathways passing through locations given by this mask

                        echo "Total exclusion probtrakx"
                        /usr/share/fsl/5.0/bin/probtrackx2 -x $DIR/$group/$name/Cortical_masks/caudate/FA_image_${side}_normalized.nii.gz -l --onewaycondition -c 0.2 -S 2000 --steplength=0.5 -P 5000 --fibthresh=0.01 --distthresh=0.0 --sampvox=0.0 --avoid="$DIR/$group/$name/Exclusion_masks/exclusion_mask_total_caudate_${side}.nii.gz" --forcedir --opd -s $bedpost_dir/merged -m $bedpost_dir/nodif_brain_mask --dir=$DIR/Tractography_${group}/$name/$exclusion/caudate/$side/seed1 --stop=$DIR/$group/$name/caudate_masks/FA_transformation/smoothed_${side}_caudate.nii.gz 


                        /usr/share/fsl/5.0/bin/probtrackx2 -x $DIR/$group/$name/caudate_masks/FA_transformation/smoothed_${side}_caudate.nii.gz -l --onewaycondition -c 0.2 -S 2000 --steplength=0.5 -P 5000 --fibthresh=0.01 --distthresh=0.0 --sampvox=0.0 --avoid="$DIR/$group/$name/Exclusion_masks/exclusion_mask_total_caudate_${side}.nii.gz" --forcedir --opd -s $bedpost_dir/merged -m $bedpost_dir/nodif_brain_mask --dir=$DIR/Tractography_${group}/$name/$exclusion/caudate/$side/seed2 --waypoints=$DIR/$group/$name/Cortical_masks/caudate/FA_image_${side}_normalized.nii.gz --waycond=AND

                    else # run the analysis without adding the two cortical masks not used as seed as exclusion masks
                        echo "CSF_midline exclusion probtrakx"
                        /usr/share/fsl/5.0/bin/probtrackx2 -x $DIR/$group/$name/Cortical_masks/caudate/FA_image_${side}_normalized.nii.gz -l --onewaycondition -c 0.2 -S 2000 --steplength=0.5 -P 5000 --fibthresh=0.01 --distthresh=0.0 --sampvox=0.0 --avoid="$DIR/$group/$name/Exclusion_masks/exclusion_mask_CSF_middline_caudate_${side}.nii.gz" --forcedir --opd -s $bedpost_dir/merged -m $bedpost_dir/nodif_brain_mask --dir=$DIR/Tractography_${group}/$name/$exclusion/caudate/$side/seed1 --stop=$DIR/$group/$name/caudate_masks/FA_transformation/smoothed_${side}_caudate.nii.gz 


                        /usr/share/fsl/5.0/bin/probtrackx2 -x $DIR/$group/$name/caudate_masks/FA_transformation/smoothed_${side}_caudate.nii.gz -l --onewaycondition -c 0.2 -S 2000 --steplength=0.5 -P 5000 --fibthresh=0.01 --distthresh=0.0 --sampvox=0.0 --avoid="$DIR/$group/$name/Exclusion_masks/exclusion_mask_CSF_middline_caudate_${side}.nii.gz" --forcedir --opd -s $bedpost_dir/merged -m $bedpost_dir/nodif_brain_mask --dir=$DIR/Tractography_${group}/$name/$exclusion/caudate/$side/seed2 --waypoints=$DIR/$group/$name/Cortical_masks/caudate/FA_image_${side}_normalized.nii.gz --waycond=AND

                                                

                    fi

                    done;
            done;

        done;
    done; 
done;
