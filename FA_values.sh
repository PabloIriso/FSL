#This script takes a fdt_paths file obtained from Probtrackx and normalizes it by streamlines in order to apply a probability threshold. Afterwards, it obtains the FA, radial diffusivity and mean diffusivity values multiplying the normalized image by the reference image and computing the mean.


DIR="/media/estela/HD_2/Pablo/Analysis"  #working directory

for group in Controls Patients; do
    echo $group
    for folder in $DIR/Tractography_${group}/*; do
        name=$(basename "$folder")
        echo $name
        for exclusion in Exclusion No_exclusion; do
            for region in accumbens caudate putamen; do
                for side in left right; do

                    Column_name="Initial_${exclusion}_${region}_${side}" 
                    if [[ "$name" == "C01_1" ]]
                    then
                        Header="Subject ${Column_name}_FA ${Column_name}_MD ${Column_name}_RD" #header of the file where we will store the results
                        echo "$Header" > $DIR/${Column_name}.csv #print the header in the file 
                    fi

                        for seed in seed1 seed2; do
                            current_dir="$DIR/Tractography_${group}/$name/$exclusion/$region/$side/$seed" #directory in which we are working in
                                    
                            waytotal="$current_dir/waytotal" #file where the waytotal values are stored
                            streamlines=$(cat "$waytotal") #reads the values of the waytotal file 

                            #normalize by waytotal 
                            fslmaths $current_dir/fdt_paths.nii.gz -div $streamlines $current_dir/fdt_paths_norm.nii.gz                                                        
                        done;                              

                    current_dir="$DIR/Tractography_${group}/$name/$exclusion/$region/${side}" #directory in which we are working in
                        
                    fslmaths $current_dir/seed1/fdt_paths_norm.nii.gz -add $current_dir/seed2/fdt_paths_norm.nii.gz -div 2 $current_dir/mean_image #compute the mean image with both seeds
                 

                    fslmaths $current_dir/mean_image -thrP 95 -bin $current_dir/mean_image_bin.nii.gz #apply a threshold of 95% and binarize


                    fslmaths $current_dir/mean_image_bin.nii.gz -mul /media/estela/HD_2/subjects/$name/dmri/dtifit_FA.nii.gz $current_dir/multiplication_dtiFA_mask #multiply by the FA reference image

                    #fslmaths /media/estela/HD_2/subjects/$name/dmri/dtifit_L1.nii.gz -add /media/estela/HD_2/subjects/$name/dmri/dtifit_L2.nii.gz -add /media/estela/HD_2/subjects/$name/dmri/dtifit_L3.nii.gz -div 3 /media/estela/HD_2/subjects/$name/dmri/ditfit_MD #obtain the Mean Diffusivity (MD) reference image
                    #fslmaths /media/estela/HD_2/subjects/$name/dmri/dtifit_L2.nii.gz -add /media/estela/HD_2/subjects/$name/dmri/dtifit_L3.nii.gz -div 2 /media/estela/HD_2/subjects/$name/dmri/ditfit_RD #obtain the Radial Diffusivity (RD) reference image

                    fslmaths $current_dir/mean_image_bin.nii.gz -mul /media/estela/HD_2/subjects/$name/dmri/ditfit_MD $current_dir/multiplication_dtiMD_mask #multiply by the MD reference image

                    fslmaths $current_dir/mean_image_bin.nii.gz -mul /media/estela/HD_2/subjects/$name/dmri/ditfit_RD $current_dir/multiplication_dtiRD_mask #multiply by the RD reference image

                    #obtain the FA mean
                    FA_mean=$(fslstats $current_dir/multiplication_dtiFA_mask.nii.gz -M) #store the mean in a variable

                    #obtain the MD:

                    MD=$(fslstats $current_dir/multiplication_dtiMD_mask.nii.gz -M) #store the mean in a variable

                    #obtain the RD:

                    RD=$(fslstats $current_dir/multiplication_dtiRD_mask.nii.gz -M) #store the mean in a variable


                    echo ${name} $FA_mean $MD $RD >> $DIR/${Column_name}.csv #print the the cortical region and side of brain and the FA mean, MD and RD in the final results file

                done;
            done;
        done; 
    done;
done;
