#!/bin/bash


# Move files for probtrackx
## Move bedpostx
## - bedpost_dir="$DIR/Bedpost_${group}/$name/dmri.bedpostX

DIR="/media/estela/HD_2/Irene/Analysis"
for group in Controls Patients; do 
    cd "$DIR/Bedpost_${group}" || exit
    for folder in *; do
        orig="/$folder/dmri.bedpostX"
        dest="/media/estela/HD_2/Pablo/Analysis/Bedpost_${group}/$orig"; 
        mkdir -p "$dest"
        cp $DIR/Bedpost_${group}/$orig/nodif_brain_mask.* $dest/
        cp $DIR/Bedpost_${group}/$orig/merged* $dest/
    done;
done;

## Move tractography
### This one is created previously

## Move cortical masks
# $DIR/$group/$name/putamen_masks/FA_transformation/smoothed_${side}_putamen.nii.g

DIR="/media/estela/HD_2/Irene/Analysis"
for group in Controls Patients; do
    for side in left right; do
        for cortical in accumbens putamen Caudate; do
            cd "$DIR/$group" || exit
            for folder in *; do
                orig="$folder/${cortical}_masks/FA_transformation"
                dest="/media/estela/HD_2/Pablo/Analysis/$group/$orig"; 
                mkdir -p $dest
                cp "$orig/smoothed_${side}_${cortical}.nii.gz" "$dest/" 
            done;
        done;
    done;
done;

# La carpeta general caudate está en mayúsculas (Caudate), mientras que los archivos smoothed están en minúsculas, por lo que no consigue localizarlos. Creamos un nuevo script que copia únicamente las máscaras smoothed_caudate a sus correspondientes carpetas, que se han creado satisfactoriamente en el script anterior. 

DIR="/media/estela/HD_2/Irene/Analysis"
for group in Controls Patients; do
    for side in left right; do
        cd "$DIR/$group" || exit
        for folder in *; do
            orig="$folder/Caudate_masks/FA_transformation"
            dest="/media/estela/HD_2/Pablo/Analysis/$group/$orig"; 
            cp "$orig/smoothed_${side}_caudate.nii.gz" "$dest/" 
        done;
    done;
done;
