#!/bin/bash
DIR="/media/estela/HD_2/Pablo/Analysis"
for group in Controls Patients; do
	cd $DIR/$group || exit
	for folder in *; do
        for cortical in "$folder/"*; do
            if [ $cortical = "$folder/Caudate_masks" ]; then
                mv $cortical $folder/caudate_masks
            fi
        done;
	done;
done;

