#!/bin/bash
# Convert .img to .nii.gz
DIR="/media/estela/HD_2/Pablo/Analysis" 
for group in Controls Patients; do
    for ele in accumbens putamen caudate; do
        for folder in $DIR/$group/*; do  ## Create folders
 
            name=$(basename "$folder") 

            if [ ! -d "$DIR/$group/$name/Cortical_masks" ]; then 
            mkdir $DIR/$group/$name/Cortical_masks 
            fi
            if [ ! -d "$DIR/$group/$name/Cortical_masks/$ele" ]; then 
            mkdir $DIR/$group/$name/Cortical_masks/$ele
            fi

              
            ## FILES
            ref_FA_MNI_1mm='/media/estela/HD_2/Pablo/Proves/FMRIB58_FA_1mm.nii' #reference image FA space 1mm
            param_FA='/media/estela/HD_2/Pablo/Proves/FA_2_FMRIB58_1mm.cnf'  #parameters of FA 1mm
            
            ## Files to normalize. 
            Input_right_mask="$DIR/Cortical_masks/$ele/R_${ele}_rsfmri001.nii.gz" #output of the right region in FA space
            Input_left_mask="$DIR/Cortical_masks/$ele/L_${ele}_rsfmri001.nii.gz" #output of the left region in FA space

            FA_image_right_normalized="$DIR/$group/$name/Cortical_masks/$ele/FA_image_right_normalized" #output of the right region in FA space
            FA_image_left_normalized="$DIR/$group/$name/Cortical_masks/$ele/FA_image_left_normalized" #output of the left region in FA space

            reference_image="$DIR/$group/$name/difusion/Deterministico/dti_fin_fa.nii"            #reference_image="$DIR/$group/$name/dti/dti_fin_fa.nii"   #reference image dti

            aff_transf_fa="$DIR/$group/$name/Cortical_masks/$ele/aff_trans_fa" #affine trasformation FA space
            nl_transf_fa="$DIR/$group/$name/Cortical_masks/$ele/nl_trans_fa" #non linear transformation FA space
            linear_transformed_fa="$DIR/$group/$name/Cortical_masks/$ele/linear_transformed_fa" #linear transformed FA image brain
            
            transf_from_MNI_to_fa_right="$DIR/$group/$name/Cortical_masks/$ele/transf_from_MNI_to_fa_right.nii.gz" #transformation to go from MNI to FA right region
            transf_from_MNI_to_fa_left="$DIR/$group/$name/Cortical_masks/$ele/transf_from_MNI_to_fa_left.nii.gz" #transformation to go from MNI to FA left region


    
            ## TRANSFORMATION
            echo "Normalización FA"

            echo "Linear FA"
            #Linear transformation
            flirt -ref ${ref_FA_MNI_1mm} -in ${reference_image} -omat ${aff_transf_fa} -o ${linear_transformed_fa}
            
            echo "nO LINEAR t1"
            #No linear transformation 
            fnirt --in=${reference_image} --aff=${aff_transf_fa} --cout=${nl_transf_fa} --config=${param_FA} --warpres=8,8,8
          
            echo "inverse warp"
            invwarp -r ${reference_image} -w ${nl_transf_fa} -o ${transf_from_MNI_to_fa_right} #reverse the non-linear mapping of the right region
            invwarp -r ${reference_image} -w ${nl_transf_fa} -o ${transf_from_MNI_to_fa_left} #reverse the non-linear mapping of the left region

            echo "apply warp" 
            applywarp -r ${reference_image}  -i ${Input_right_mask} -w ${transf_from_MNI_to_fa_right} -o ${FA_image_right_normalized} #map the computed transformation to the right image (in MNI) 
            applywarp -r ${reference_image}  -i ${Input_left_mask} -w ${transf_from_MNI_to_fa_left} -o ${FA_image_left_normalized} #map the computed transformation to the left image (in MNI) 
            ## El input en applywarp es la roi, en este caso --i ${FA_image_right_normalized}

            echo "binarization"        
            fslmaths ${FA_image_right_normalized} -bin ${FA_image_right_normalized} #binarize intensity of right side FA image
            fslmaths ${FA_image_left_normalized} -bin ${FA_image_left_normalized} #binarize instensity of left side FA image image
      
        done;
    done;
done;
