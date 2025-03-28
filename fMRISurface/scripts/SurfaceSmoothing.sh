#!/bin/bash
set -e
echo -e "\n START: SurfaceSmoothing"

NameOffMRI="$1"
Subject="$2"
DownSampleFolder="$3"
LowResMesh="$4"
SmoothingFWHM="$5"

# $SmoothingFWHM / (2 * (2 * ln(2))**0.5)
# NOTE: 在统计和图像处理领域，Full Width at Half Maximum (FWHM) 和标准差 (σ) 之间有一个直接的数学关系。FWHM 表示分布的宽度，在其最大值的一半处测量。标准差 (σ) 是描述正态分布的散布程度的参数。
Sigma=$(echo "$SmoothingFWHM / ( 2 * ( sqrt ( 2 * l ( 2 ) ) ) )" | bc -l)

for Hemisphere in L R; do
  ${CARET7DIR}/wb_command -metric-smoothing \
    "$DownSampleFolder"/"$Subject"."$Hemisphere".midthickness."$LowResMesh"k_fs_LR.surf.gii \
    "$NameOffMRI"."$Hemisphere".atlasroi."$LowResMesh"k_fs_LR.func.gii \
    "$Sigma" \
    "$NameOffMRI"_s"$SmoothingFWHM".atlasroi."$Hemisphere"."$LowResMesh"k_fs_LR.func.gii \
    -roi "$DownSampleFolder"/"$Subject"."$Hemisphere".atlasroi."$LowResMesh"k_fs_LR.shape.gii
  #Basic Cleanup
  rm "$NameOffMRI"."$Hemisphere".atlasroi."$LowResMesh"k_fs_LR.func.gii
done

echo " END: SurfaceSmoothing"
