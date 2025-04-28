#/bin/bash

subjs_list=(SC_06018)
current_dir=$(pwd)
for index in ${!subjs_list[@]}; do
  subj=${subjs_list[index]}
  echo -e "\e[1;32m####################\e[0m" No.$((index + 1)): ${subj} "\e[1;32m####################\e[0m"

  # Presurfer
  # NOTE:
  # --brainsize: macaque 60, chimpanzee 150
  # --not2wdata: 1=No T2w Data, else=Have T2w Data
  ${HCPPIPEDIR}/PreFreeSurfer/PreFreeSurferPipelineNHP.sh \
    --path=${current_dir} \
    --subject=${subj} \
    --t1=${current_dir}/${subj}/unprocessed/T1w/T1w.nii.gz \
    --t2=${current_dir}/${subj}/unprocessed/T2w/T2w.nii.gz \
    --t1template=${HCPPIPEDIR_Templates}/MacaqueYerkes19_T1w_0.5mm_dedrift.nii.gz \
    --t1templatebrain=${HCPPIPEDIR_Templates}/MacaqueYerkes19_T1w_0.5mm_dedrift_brain.nii.gz \
    --t1template2mm=${HCPPIPEDIR_Templates}/MacaqueYerkes19_T1w_1.0mm_dedrift.nii.gz \
    --t2template=${HCPPIPEDIR_Templates}/MacaqueYerkes19_T2w_0.5mm_dedrift.nii.gz \
    --t2templatebrain=${HCPPIPEDIR_Templates}/MacaqueYerkes19_T2w_0.5mm_dedrift_brain.nii.gz \
    --t2template2mm=${HCPPIPEDIR_Templates}/MacaqueYerkes19_T2w_1.0mm_dedrift.nii.gz \
    --templatemask=${HCPPIPEDIR_Templates}/MacaqueYerkes19_T1w_0.5mm_brain_mask_dedrift.nii.gz \
    --template2mmmask=${HCPPIPEDIR_Templates}/MacaqueYerkes19_T1w_1.0mm_brain_mask_dedrift.nii.gz \
    --brainsize=60 \
    --fnirtconfig=${HCPPIPEDIR_Config}/T1_2_Yerkes19_1mm.cnf \
    --not2wdata=0

  # FreeSurfer
  # NOTE:
  # --t2
  # --t2wflag: None, T2w, FLAIR
  # --not2wdata: 1=No T2w Data, else=Have T2w Data
  # --runmode
  ${HCPPIPEDIR}/FreeSurfer/FreeSurferPipelineNHP.sh \
    --subject=${subj} \
    --subjectDIR=${current_dir}/${subj}/T1w \
    --t1=${current_dir}/${subj}/T1w/T1w_acpc_dc_restore.nii.gz \
    --t1brain=${current_dir}/${subj}/T1w/T1w_acpc_dc_restore_brain.nii.gz \
    --t2=${current_dir}/${subj}/T1w/T2w_acpc_dc_restore.nii.gz \
    --seed=1234 \
    --gcadir=${HCPPIPEDIR_Templates}/MacaqueYerkes19 \
    --rescaletrans=${HCPPIPEDIR_Templates}/fs_xfms/Macaque_rescale \
    --asegedit=NONE \
    --controlpoints=NONE \
    --wmedit=NONE \
    --t2wflag=T2w \
    --species=Macaque \
    --intensitycor=FAST \
    --brainmasking=HCP \
    --not2wdata=0 \
    --nslots=8 \
    --runmode=0

  # PostFreeSurfer
  # NOTE:
  # --grayordinatesres: macaque 1.25, chimpanzee 1.6
  # --lowresmesh: macaque 32@10, chimpanzee 32@20
  # --not2wdata: 1=No T2w Data, else=Have T2w Data
  ${HCPPIPEDIR}/PostFreeSurfer/PostFreeSurferPipeline.sh \
    --path=${current_dir} \
    --subject=${subj} \
    --surfatlasdir=${HCPPIPEDIR_Templates}/standard_mesh_atlases_macaque_dedrift \
    --grayordinatesdir=${HCPPIPEDIR_Templates}/standard_mesh_atlases_macaque_dedrift \
    --grayordinatesres=1.25 \
    --hiresmesh=164 \
    --lowresmesh=32@10 \
    --subcortgraylabels=${HCPPIPEDIR_Config}/FreeSurferSubcorticalLabelTableLut.txt \
    --freesurferlabels=${HCPPIPEDIR_Config}/FreeSurferAllLut.txt \
    --refmyelinmaps=${HCPPIPEDIR_Templates}/standard_mesh_atlases_macaque/MacaqueYerkes19.MyelinMap_BC.164k_fs_LR.dscalar.nii \
    --regname=MSMSulc \
    --printcom="" \
    --species=Macaque \
    --not2wdata=0

  # DiffPreproc
  # NOTE:
  # --echospacing
  # --dof
  # --rjxexchangedim23: 1=Need to change dim2 and dim3, 0=No need
  # --not2wdata: 1=No T2w Data, else=Have T2w Data
  # --runmode: 0=All, 1=PreEddyANDEddy, 2=PostEddy
  ${HCPPIPEDIR}/DiffusionPreprocessing/DiffPreprocPipelineNHP.sh \
    --path=${current_dir} \
    --subject=${subj} \
    --PEdir=2 \
    --posData=${current_dir}/${subj}/unprocessed/Diffusion/${subj}_POS2_zeropad.nii.gz \
    --negData=${current_dir}/${subj}/unprocessed/Diffusion/${subj}_NEG2_zeropad.nii.gz \
    --echospacing=0.44 \
    --gdcoeffs=NONE \
    --dof=12 \
    --combine-data-flag=2 \
    --rjxexchangedim23=1 \
    --not2wdata=0 \
    --runmode=0

done
