# FSL

https://fsl.fmrib.ox.ac.uk/fsl/fslwiki/FDT/UserGuide

**executive - caudate  
motivational - accumbens  
motor - putamen**  

exclusion_masks.sh -->  
FA_values.sh -->   
probtrackx_accumbens.sh -->  
probtrackx_caudate.sh -->   
probtrackx_putamen.sh -->  
rename_masks.sh -->   
rois_convert.sh -->  
subcortical_masks.sh -->   
sub_masks_test.sh -->  
test.sh -->  
test1.sh -->  

Other useful scripts:  
bed_cp.sh -->  
dti_cp.sh -->  
exclusion_cp.sh -->  


exclusion_cp <- Copia los archivos necesarios para la obtencion de las exlcusion masks desde los ficheros de Irene /CSF y Middline)
Exlcusion_masks <- Crea las mascaras de exclusion.

bed_cp <- Copia los archivos necesarios para la obtencion de los tractos
(Algunos individuos no tienen mascara Bed).

probtrack_${cortical} <- Crea los tractos
