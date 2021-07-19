#!/bin/bash

# Move dti from Irene to Pablo
DIR="/media/estela/HD_2/Irene/Analysis"
#cd "$DIR/Controls" || exit
#for folder in *; do
#    orig="$folder/difusion/Deterministico"
#    dest="/media/estela/HD_2/Pablo/Analysis/Controls/$orig"; 
#    mkdir -p $dest
#    cp "$orig/dti_fin_fa.nii" "$dest/" 
#done;


cd "$DIR/Patients" || exit
for folder in *; do
    orig1="$folder/difusion/Deterministico"
    dest1="/media/estela/HD_2/Pablo/Analysis/Patients/$orig1"; 
    mkdir -p $dest1
    cp "$orig1/dti_fin_fa.nii" "$dest1/" 
done;
