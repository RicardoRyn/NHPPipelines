let subjs_list = [SC_06018]

let current_dir = (pwd)

$subjs_list | par-each -t 1 {|subj|
  print $"(ansi green_bold)###################### 正在处理：($subj) ######################(ansi reset)"

  # Presurfer
  # NOTE:
  # --brainsize: macaque 60, chimpanzee 150
  # --not2wdata: 1=No T2w Data, else=Have T2w Data
  (
    bash $"($env.HCPPIPEDIR)/PreFreeSurfer/PreFreeSurferPipelineNHP.sh"
      --path=$"($current_dir)"
      --subject=$"($subj)"
      --t1=$"($current_dir)/($subj)/unprocessed/T1w/T1w.nii.gz"
      --t2=$"($current_dir)/($subj)/unprocessed/T2w/T2w.nii.gz"
      --t1template=$"($env.HCPPIPEDIR_Templates)/MacaqueYerkes19_T1w_0.5mm_dedrift.nii.gz"
      --t1templatebrain=$"($env.HCPPIPEDIR_Templates)/MacaqueYerkes19_T1w_0.5mm_dedrift_brain.nii.gz"
      --t1template2mm=$"($env.HCPPIPEDIR_Templates)/MacaqueYerkes19_T1w_1.0mm_dedrift.nii.gz"
      --t2template=$"($env.HCPPIPEDIR_Templates)/MacaqueYerkes19_T2w_0.5mm_dedrift.nii.gz"
      --t2templatebrain=$"($env.HCPPIPEDIR_Templates)/MacaqueYerkes19_T2w_0.5mm_dedrift_brain.nii.gz"
      --t2template2mm=$"($env.HCPPIPEDIR_Templates)/MacaqueYerkes19_T2w_1.0mm_dedrift.nii.gz"
      --templatemask=$"($env.HCPPIPEDIR_Templates)/MacaqueYerkes19_T1w_0.5mm_brain_mask_dedrift.nii.gz"
      --template2mmmask=$"($env.HCPPIPEDIR_Templates)/MacaqueYerkes19_T1w_1.0mm_brain_mask_dedrift.nii.gz"
      --brainsize=60
      --fnirtconfig=$"($env.HCPPIPEDIR_Config)/T1_2_Yerkes19_1mm.cnf"
      --not2wdata=0
  )

  # FreeSurfer
  # NOTE:
  # --t2
  # --t2wflag
  # --runmode
  (
    bash $"($env.HCPPIPEDIR)/FreeSurfer/FreeSurferPipelineNHP.sh"
      --subject=$"($subj)"
      --subjectDIR=$"($current_dir)/($subj)/T1w"
      --t1=$"($current_dir)/($subj)/T1w/T1w_acpc_dc_restore.nii.gz"
      --t1brain=$"($current_dir)/($subj)/T1w/T1w_acpc_dc_restore_brain.nii.gz"
      --t2=$"($current_dir)/($subj)/T1w/T2w_acpc_dc_restore.nii.gz"
      --seed=1234
      --gcadir=$"($env.HCPPIPEDIR_Templates)/MacaqueYerkes19"
      --rescaletrans=$"($env.HCPPIPEDIR_Templates)/fs_xfms/Macaque_rescale"
      --asegedit=NONE
      --controlpoints=NONE
      --wmedit=NONE
      --t2wflag=T2w
      --species=Macaque
      --intensitycor=FAST
      --brainmasking=HCP
      --not2wdata=0
      --nslots=8
      --runmode=0
  )

  # PostFreeSurfer
  # NOTE:
  # --grayordinatesres: macaque 1.25, chimpanzee 1.6
  # --lowresmesh: macaque 32@10, chimpanzee 32@20
  # --not2wdata: 1=No T2w Data, else=Have T2w Data
  (
    bash $"($env.HCPPIPEDIR)/PostFreeSurfer/PostFreeSurferPipeline.sh"
      --path=$"($current_dir)"
      --subject=$"($subj)"
      --surfatlasdir=$"($env.HCPPIPEDIR_Templates)/standard_mesh_atlases_macaque_dedrift"
      --grayordinatesdir=$"($env.HCPPIPEDIR_Templates)/standard_mesh_atlases_macaque_dedrift"
      --grayordinatesres=1.25
      --hiresmesh=164
      --lowresmesh=32@10
      --subcortgraylabels=$"($env.HCPPIPEDIR_Config)/FreeSurferSubcorticalLabelTableLut.txt"
      --freesurferlabels=$"($env.HCPPIPEDIR_Config)/FreeSurferAllLut.txt"
      --refmyelinmaps=$"($env.HCPPIPEDIR_Templates)/standard_mesh_atlases_macaque/MacaqueYerkes19.MyelinMap_BC.164k_fs_LR.dscalar.nii"
      --regname=MSMSulc
      --printcom=$"''"
      --species=Macaque
      --not2wdata=0
  )

  # DiffPreproc
  # NOTE:
  # --echospacing
  # --dof
  # --rjxexchangedim23: 1=Need to change dim2 and dim3, 0=No need
  # --not2wdata: 1=No T2w Data, else=Have T2w Data
  (
    bash $"($env.HCPPIPEDIR)/DiffusionPreprocessing/DiffPreprocPipelineNHP.sh"
      --path=$"($current_dir)"
      --subject=$"($subj)"
      --PEdir=2
      --posData=$"($current_dir)/($subj)/unprocessed/Diffusion/($subj)_1_AP_zeropad.nii.gz@($current_dir)/($subj)/unprocessed/Diffusion/($subj)_2_AP_zeropad.nii.gz"
      --negData=$"($current_dir)/($subj)/unprocessed/Diffusion/($subj)_1_PA_zeropad.nii.gz@($current_dir)/($subj)/unprocessed/Diffusion/($subj)_2_PA_zeropad.nii.gz"
      --echospacing=0.47
      --gdcoeffs=NONE
      --dof=12
      --combine-data-flag=2
      --rjxexchangedim23=0
      --not2wdata=0
      --runmode=0
  )

}
