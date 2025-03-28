#!/bin/bash

subjs_list=(subj_01)

current_dir=$(pwd)
for index in ${!subjs_list[@]}; do
  subj=${subjs_list[index]}
  echo -e "\e[1;32m####################\e[0m" No.$((index + 1)): ${subj} "\e[1;32m####################\e[0m"

  # Presurfer
  # NOTE:
  # --brainsize: macaque 60, chimpanzee 150
  # --not2wdata: 1=No T2w Data, else=Have T2w Data
  bash ${HCPPIPEDIR}/PreFreeSurfer/PreFreeSurferPipelineNHP.sh \
    --path=${current_dir} \
    --subject=${subj} \
    --t1=${current_dir}/${subj}/unprocessed/T1w/T1w.nii.gz \
    --t1template=${HCPPIPEDIR_Templates}/ChimpYerkes29_T1w_0.8mm.nii.gz \
    --t1templatebrain=${HCPPIPEDIR_Templates}/ChimpYerkes29_T1w_0.8mm_brain.nii.gz \
    --t1template2mm=${HCPPIPEDIR_Templates}/ChimpYerkes29_T1w_1.6mm.nii.gz \
    --templatemask=${HCPPIPEDIR_Templates}/ChimpYerkes29_T1w_0.8mm_brain_mask.nii.gz \
    --template2mmmask=${HCPPIPEDIR_Templates}/ChimpYerkes29_T1w_1.6mm_brain_mask.nii.gz \
    --brainsize=150 \
    --fnirtconfig=${HCPPIPEDIR_Config}/T1_2_MNI_NHP.cnf \
    --not2wdata=1
  # --t2=${current_dir}/${subj}/unprocessed/T2w/T2w.nii.gz
  # --t2template=${HCPPIPEDIR_Templates}/MacaqueYerkes19_T2w_0.5mm_dedrift.nii.gz
  # --t2templatebrain=${HCPPIPEDIR_Templates}/MacaqueYerkes19_T2w_0.5mm_dedrift_brain.nii.gz
  # --t2template2mm=${HCPPIPEDIR_Templates}/MacaqueYerkes19_T2w_1.0mm_dedrift.nii.gz

  # FreeSurfer
  # NOTE:
  # --t2
  # --t2wflag: None, T2w, FLAIR
  # --not2wdata: 1=No T2w Data, else=Have T2w Data
  # --runmode
  bash ${HCPPIPEDIR}/FreeSurfer/FreeSurferPipelineNHP.sh \
    --subject=${subj} \
    --subjectDIR=${current_dir}/${subj}/T1w \
    --t1=${current_dir}/${subj}/T1w/T1w_acpc_dc_restore.nii.gz \
    --t1brain=${current_dir}/${subj}/T1w/T1w_acpc_dc_restore_brain.nii.gz \
    --t2=${current_dir}/${subj}/T1w/T2w_acpc_dc_restore.nii.gz \
    --t2wflag=None \
    --seed=1234 \
    --gcadir=${HCPPIPEDIR_Templates}/ChimpYerkes29 \
    --rescaletrans=${HCPPIPEDIR_Templates}/fs_xfms/Chimp_rescale \
    --asegedit=NONE \
    --controlpoints=NONE \
    --wmedit=NONE \
    --species=Chimpanzee \
    --intensitycor=FAST \
    --brainmasking=HCP \
    --not2wdata=1 \
    --nslots=8 \
    --runmode=0

  # PostFreeSurfer"
  # NOTE:
  # --grayordinatesres: macaque 1.25, chimpanzee 1.6
  # --lowresmesh: macaque 32@10, chimpanzee 32@20
  # --not2wdata: 1=No T2w Data, else=Have T2w Data
  bash ${HCPPIPEDIR}/PostFreeSurfer/PostFreeSurferPipeline.sh \
    --path=${current_dir} \
    --subject=${subj} \
    --surfatlasdir=${HCPPIPEDIR_Templates}/standard_mesh_atlases_chimp \
    --grayordinatesdir=${HCPPIPEDIR_Templates}/standard_mesh_atlases_chimp \
    --grayordinatesres=1.6 \
    --hiresmesh=164 \
    --lowresmesh=32@20 \
    --subcortgraylabels=${HCPPIPEDIR_Config}/FreeSurferSubcorticalLabelTableLut.txt \
    --freesurferlabels=${HCPPIPEDIR_Config}/FreeSurferAllLut.txt \
    --refmyelinmaps=${HCPPIPEDIR_Templates}/standard_mesh_atlases_chimp/ChimpYerkes29.MyelinMap_BC.164k_fs_LR.dscalar.nii \
    --regname=MSMSulc \
    --printcom="" \
    --species=Chimpanzee \
    --not2wdata=1

  # DiffPreproc
  # NOTE:
  # --echospacing
  # --dof
  # --rjxexchangedim23: 1=Need to change dim2 and dim3, 0=No need
  # --not2wdata: 1=No T2w Data, else=Have T2w Data
  # --runmode: 0=All, 1=PreEddyANDEddy, 2=PostEddy
  bash ${HCPPIPEDIR}/DiffusionPreprocessing/DiffPreprocPipelineNHP.sh \
    --path=${current_dir} \
    --subject=${subj} \
    --PEdir=2 \
    --posData=${current_dir}/${subj}/unprocessed/Diffusion/${subj}_POS2_zeropad.nii.gz \
    --negData=${current_dir}/${subj}/unprocessed/Diffusion/${subj}_NEG2_zeropad.nii.gz \
    --echospacing=0.44 \
    --gdcoeffs=NONE \
    --dof=6 \
    --combine-data-flag=2 \
    --rjxexchangedim23=0 \
    --not2wdata=1 \
    --runmode=2

done
