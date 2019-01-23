#!/bin/bash
#set -x
##BIDS conversion script for R33 neuroimaging data
##@derek pisner

#export WORKING_DIR=/Volumes/schnyer/R33ABM
export WORKING_DIR=/Users/PSYC-klr3342/Documents/R33_RAW
export SOURCE_DIR="$WORKING_DIR"/RAW
#export BIDS_DIR="$WORKING_DIR"/BIDS
export BIDS_DIR="$WORKING_DIR"/testBIDS
export DERIVATIVES_DIR="$WORKING_DIR"/derivatives
export PYDEFACEPATH="/Users/PSYC-klr3342/Applications/pydeface/scripts"
source ~/.bashrc
#export PYDEFACEPATH="/Users/PSYC-dap3463/pydeface/scripts"

##Choose Participant
echo -en '\n'
echo "Which participant?"
read PARTIC

##Choose Visit
echo -en '\n'
echo "Which visit? (1=Baseline, 2=Mid-training, 3=Post-training)"
read VISIT

# ## Batch version
# PARTIC=$1
# VISIT=$2
#
# echo $PARTIC
# echo $VISIT

##Set visit directory
if [[ $VISIT == 1 ]]; then
    VISIT_DIR='ses-01'
elif [[ $VISIT == 2 ]]; then
    VISIT_DIR='ses-02'
elif [[ $VISIT == 3 ]]; then
    VISIT_DIR='ses-03'
fi

##Find raw dicom directories
ANAT_RAW=`find $SOURCE_DIR/"$PARTIC"_"$VISIT" -maxdepth 1 -iname '*MPRAGE*' -not -iname '*SBREF*' -print | sort -r | tail -1`
FMAP_RAW=`find $SOURCE_DIR/"$PARTIC"_"$VISIT" -maxdepth 1 \( -iname '*FIELD_MAPPING*' -o -iname '*Field_mapping*' \) -print | sort -r | tail -1`
DWI_SHELL1_AP_RAW=`find $SOURCE_DIR/"$PARTIC"_"$VISIT" -maxdepth 1 \( -iname '*UCSF_71AP*' \) -not -iname '*SBREF*' -print | sort -r | tail -1`
DWI_SHELL1_PA_RAW=`find $SOURCE_DIR/"$PARTIC"_"$VISIT" -maxdepth 1 \( -iname '*UCSF_71PA*' \) -not -iname '*SBREF*' -print | sort -r | tail -1`
DWI_SHELL2_AP_RAW=`find $SOURCE_DIR/"$PARTIC"_"$VISIT" -maxdepth 1 \( -iname '*UCSF_72AP*' \) -not -iname '*SBREF*' -print | sort -r | tail -1`
DWI_SHELL2_PA_RAW=`find $SOURCE_DIR/"$PARTIC"_"$VISIT" -maxdepth 1 \( -iname '*UCSF_72PA*' \) -not -iname '*SBREF*' -print | sort -r | tail -1`
DWI_SHELL3_AP_RAW=`find $SOURCE_DIR/"$PARTIC"_"$VISIT" -maxdepth 1 \( -iname '*UCSF_73AP*' \) -not -iname '*SBREF*' -print | sort -r | tail -1`
DWI_SHELL3_PA_RAW=`find $SOURCE_DIR/"$PARTIC"_"$VISIT" -maxdepth 1 \( -iname '*UCSF_73PA*' \) -not -iname '*SBREF*' -print | sort -r | tail -1`
FUNC_REST1_RAW=`find $SOURCE_DIR/"$PARTIC"_"$VISIT" -maxdepth 1 \( -iname '*RESTINGSTATE*' -o -iname '*restingstate*' \) -not -iname '*SBREF*' -print | sort -r | tail -1`
FUNC_SART1_RAW=`find $SOURCE_DIR/"$PARTIC"_"$VISIT" -maxdepth 1 \( -iname '*TASK1*' -o -iname '*Task1*' \) -not -iname '*SBREF*' -print | sort | tail -1`
FUNC_SART2_RAW=`find $SOURCE_DIR/"$PARTIC"_"$VISIT" -maxdepth 1 \( -iname '*TASK2*' -o -iname '*Task2*' \) -not -iname '*SBREF*' -print | sort | tail -1`
FUNC_SART3_RAW=`find $SOURCE_DIR/"$PARTIC"_"$VISIT" -maxdepth 1 \( -iname '*TASK3*' -o -iname '*Task3*' \) -not -iname '*SBREF*' -print | sort | tail -1`
FUNC_SART4_RAW=`find $SOURCE_DIR/"$PARTIC"_"$VISIT" -maxdepth 1 \( -iname '*TASK4*' -o -iname '*Task4*' \) -not -iname '*SBREF*' -print | sort | tail -1`

##Create BIDS filenames
ANAT_FILE="sub-"$PARTIC""_"$VISIT_DIR"_acq-MPRAGE_T1w
FMAP_MAG_FILE="sub-"$PARTIC""_"$VISIT_DIR"_magnitude
FMAP_PHASE_FILE="sub-"$PARTIC""_"$VISIT_DIR"_phasediff
FUNC_REST1_FILE="sub-"$PARTIC""_"$VISIT_DIR"_task-REST_run-01_bold
FUNC_SART1_FILE="sub-"$PARTIC""_"$VISIT_DIR"_task-SART1_run-01_bold
FUNC_SART2_FILE="sub-"$PARTIC""_"$VISIT_DIR"_task-SART2_run-01_bold
FUNC_SART3_FILE="sub-"$PARTIC""_"$VISIT_DIR"_task-SART3_run-01_bold
FUNC_SART4_FILE="sub-"$PARTIC""_"$VISIT_DIR"_task-SART4_run-01_bold
DWI_SHELL1_AP_FILE="sub-"$PARTIC""_"$VISIT_DIR"_acq-71AP_dwi
DWI_SHELL1_PA_FILE="sub-"$PARTIC""_"$VISIT_DIR"_acq-71PA_dwi
DWI_SHELL2_AP_FILE="sub-"$PARTIC""_"$VISIT_DIR"_acq-72AP_dwi
DWI_SHELL2_PA_FILE="sub-"$PARTIC""_"$VISIT_DIR"_acq-72PA_dwi
DWI_SHELL3_AP_FILE="sub-"$PARTIC""_"$VISIT_DIR"_acq-73AP_dwi
DWI_SHELL3_PA_FILE="sub-"$PARTIC""_"$VISIT_DIR"_acq-73PA_dwi


##Create log fiel to handle missingness
touch "$WORKING_DIR"/missingness_log_"$PARTIC"_"$VISIT".txt 2>/dev/null

##Create BIDS formatted directories
#Anatomical
if [ ! -d "$BIDS_DIR"/"sub-"$PARTIC""/"$VISIT_DIR"/anat ] && [ ! -z "$ANAT_RAW" ]; then
    mkdir -p "$BIDS_DIR"/"sub-"$PARTIC""/"$VISIT_DIR"/anat
elif [ -z "$ANAT_RAW" ]; then
    echo -en "Anatomical acquisition is missing for "$PARTIC"!\n" >> "$WORKING_DIR"/missingness_log_"$PARTIC"_"$VISIT".txt
fi

#Diffusion
if [ ! -d "$BIDS_DIR"/"sub-"$PARTIC""/"$VISIT_DIR"/dwi ] && [[ ( "$DWI_SHELL1_AP_RAW" != '' && "$DWI_SHELL1_PA_RAW" != '' ) || ( "$DWI_SHELL2_AP_RAW" != '' && "$DWI_SHELL2_PA_RAW" != '' ) || ( "$DWI_SHELL3_AP_RAW" != '' && "$DWI_SHELL3_PA_RAW" != '' ) ]]; then
    mkdir -p "$BIDS_DIR"/"sub-"$PARTIC""/"$VISIT_DIR"/dwi
fi

#Fieldmaps
if [ ! -d "$BIDS_DIR"/"sub-"$PARTIC""/"$VISIT_DIR"/fmap ] && [ ! -z "$FMAP_RAW" ] && [ ! -z "$FMAP_RAW" ]; then
    mkdir -p "$BIDS_DIR"/"sub-"$PARTIC""/"$VISIT_DIR"/fmap
elif [ -z "$FMAP_RAW" ]; then
    echo -en "Fieldmap acquisition is missing for "$PARTIC"!\n" >> "$WORKING_DIR"/missingness_log_"$PARTIC"_"$VISIT".txt
fi

#Functional
if [ ! -d "$BIDS_DIR"/"sub-"$PARTIC""/"$VISIT_DIR"/func ]; then
    mkdir -p "$BIDS_DIR"/"sub-"$PARTIC""/"$VISIT_DIR"/func
fi

##Alert for missing Rest
if [ -z "$FUNC_REST1_FILE" ]; then
    echo -en "Functional acquisition REST 1 is missing for "$PARTIC"!\n" >> "$WORKING_DIR"/missingness_log_"$PARTIC"_"$VISIT".txt
fi

##Alert for missing SART
if [ -z "$FUNC_SART1_FILE" ]; then
    echo -en "Functional acquisition SART 1 is missing for "$PARTIC"!\n" >> "$WORKING_DIR"/missingness_log_"$PARTIC"_"$VISIT".txt
fi
if [ -z "$FUNC_SART2_FILE" ]; then
    echo -en "Functional acquisition SART 2 is missing for "$PARTIC"!\n" >> "$WORKING_DIR"/missingness_log_"$PARTIC"_"$VISIT".txt
fi
if [ -z "$FUNC_SART3_FILE" ]; then
    echo -en "Functional acquisition SART 3 is missing for "$PARTIC"!\n" >> "$WORKING_DIR"/missingness_log_"$PARTIC"_"$VISIT".txt
fi
if [ -z "$FUNC_SART4_FILE" ]; then
    echo -en "Functional acquisition SART 4 is missing for "$PARTIC"!\n" >> "$WORKING_DIR"/missingness_log_"$PARTIC"_"$VISIT".txt
fi

##Alert for missing dwi
if [ -z "$DWI_SHELL1_AP_RAW" ]; then
    echo -en "Diffusion acquisition AP SHELL 1 is missing for "$PARTIC"!\n" >> "$WORKING_DIR"/missingness_log_"$PARTIC"_"$VISIT".txt
fi
if [ -z "$DWI_SHELL1_PA_RAW" ]; then
    echo -en "Diffusion acquisition PA SHELL 1 is missing for "$PARTIC"!\n" >> "$WORKING_DIR"/missingness_log_"$PARTIC"_"$VISIT".txt
fi
if [ -z "$DWI_SHELL2_AP_RAW" ]; then
    echo -en "Diffusion acquisition AP SHELL 2 is missing for "$PARTIC"!\n" >> "$WORKING_DIR"/missingness_log_"$PARTIC"_"$VISIT".txt
fi
if [ -z "$DWI_SHELL2_PA_RAW" ]; then
    echo -en "Diffusion acquisition PA SHELL 2 is missing for "$PARTIC"!\n" >> "$WORKING_DIR"/missingness_log_"$PARTIC"_"$VISIT".txt
fi

if [ -z "$ANAT_RAW" ] && [ -z "$FMAP_RAW" ] && [ -z "$FUNC_REST1_RAW" ] && [ -z "$FUNC_SART1_RAW"  ] &&  [ -z "$FUNC_SART2_RAW" ] && [ -z "$FUNC_SART3_RAW" ] && [ -z "$FUNC_SART4_RAW" ]; then
    echo -en "ALL ACQUISITIONS MISSING FOR "$PARTIC"! Exiting...\n" >> "$WORKING_DIR"/missingness_log_"$PARTIC"_"$VISIT".txt
    exit 0
fi

##Convert dicoms to nifti
##Convert DWI Shell 1 AP dicoms
if [ ! -z "$DWI_SHELL1_AP_RAW" ]; then
    echo -en "\n\n\nConverting diffusion acquisition AP SHELL 1 for "$PARTIC"...\n\n\n"
    dcm2niix -o ""$BIDS_DIR"/"sub-"$PARTIC""/"$VISIT_DIR"/dwi" -f "$DWI_SHELL1_AP_FILE" -z y -b y -ba y -1 "$DWI_SHELL1_AP_RAW"
    sed -i 's/\"ProtocolName\"\: \"CMRR_DTI_UCSF_71AP\"/\"ProtocolName\"\: \"CMRR_DTI_UCSF_71AP\"\,\n\t\"NDA_ExperimentID\"\: \"900"/g' "$BIDS_DIR"/"sub-"$PARTIC""/"$VISIT_DIR"/dwi/"$DWI_SHELL1_AP_FILE".json
fi

##Convert DWI Shell 1 PA dicoms
if [ ! -z "$DWI_SHELL1_PA_RAW" ]; then
    echo -en "\n\n\nConverting diffusion acquisition PA SHELL 1 for "$PARTIC"...\n\n\n"
    dcm2niix -o ""$BIDS_DIR"/"sub-"$PARTIC""/"$VISIT_DIR"/dwi" -f "$DWI_SHELL1_PA_FILE" -z y -b y -ba y -1 "$DWI_SHELL1_PA_RAW"
    sed -i 's/\"ProtocolName\"\: \"CMRR_DTI_UCSF_71PA\"/\"ProtocolName\"\: \"CMRR_DTI_UCSF_71PA\"\,\n\t\"NDA_ExperimentID\"\: \"900"/g' "$BIDS_DIR"/"sub-"$PARTIC""/"$VISIT_DIR"/dwi/"$DWI_SHELL1_PA_FILE".json
fi

##Convert DWI Shell 2 AP dicoms
if [ ! -z "$DWI_SHELL2_AP_RAW" ]; then
    echo -en "\n\n\nConverting diffusion acquisition AP SHELL 2 for "$PARTIC"...\n\n\n"
    dcm2niix -o ""$BIDS_DIR"/"sub-"$PARTIC""/"$VISIT_DIR"/dwi" -f "$DWI_SHELL2_AP_FILE" -z y -b y -ba y -1 "$DWI_SHELL2_AP_RAW"
    sed -i 's/\"ProtocolName\"\: \"CMRR_DTI_UCSF_72AP\"/\"ProtocolName\"\: \"CMRR_DTI_UCSF_72AP\"\,\n\t\"NDA_ExperimentID\"\: \"900"/g' "$BIDS_DIR"/"sub-"$PARTIC""/"$VISIT_DIR"/dwi/"$DWI_SHELL2_AP_FILE".json
fi

##Convert DWI Shell 2 PA dicoms
if [ ! -z "$DWI_SHELL2_PA_RAW" ]; then
    echo -en "\n\n\nConverting diffusion acquisition PA SHELL 2 for "$PARTIC"...\n\n\n"
    dcm2niix -o ""$BIDS_DIR"/"sub-"$PARTIC""/"$VISIT_DIR"/dwi" -f "$DWI_SHELL2_PA_FILE" -z y -b y -ba y -1 "$DWI_SHELL2_PA_RAW"
    sed -i 's/\"ProtocolName\"\: \"CMRR_DTI_UCSF_72PA\"/\"ProtocolName\"\: \"CMRR_DTI_UCSF_72PA\"\,\n\t\"NDA_ExperimentID\"\: \"900"/g' "$BIDS_DIR"/"sub-"$PARTIC""/"$VISIT_DIR"/dwi/"$DWI_SHELL2_PA_FILE".json
fi

##Convert ANAT dicoms
if [ ! -z "$ANAT_RAW" ]; then
    echo -en "\n\n\nConverting anatomical for "$PARTIC"...\n\n\n"
    dcm2niix -o ""$BIDS_DIR"/"sub-"$PARTIC""/"$VISIT_DIR"/anat" -f "$ANAT_FILE" -z y -b y -ba y -1 "$ANAT_RAW"

    ##Correct json file
    cd "$BIDS_DIR"/"sub-"$PARTIC""/"$VISIT_DIR"/anat
    echo -en "\n\n\nDefacing anatomical for "$PARTIC"...\n\n\n"
    python3 "$PYDEFACEPATH"/pydeface.py "$ANAT_FILE".nii.gz
    ANAT_FILE_prefix=`echo $ANAT_FILE.nii.gz | cut -f1 -d .`
    rm "$ANAT_FILE".nii.gz 2>/dev/null
    mv "$ANAT_FILE_prefix"_defaced.nii.gz "$ANAT_FILE".nii.gz 2>/dev/null
    sed -i 's/\"ProtocolName\"\: \"SAG_MPRAGE\"/\"ProtocolName\"\: \"SAG_MPRAGE\"\,\n\t\"NDA_ExperimentID\"\: \"885"/g' "$ANAT_FILE".json

fi

##Convert FMAP dicoms
if [ ! -z "$FMAP_RAW" ]; then
    echo -en "\n\n\nConverting fieldmap for "$PARTIC"...\n\n\n"
    FMAP_FILE="fieldmap"
    dcm2niix -o ""$BIDS_DIR"/"sub-"$PARTIC""/"$VISIT_DIR"/fmap/" -f "$FMAP_FILE" -z y -b y -ba y -1 "$FMAP_RAW"
    wait

    ##Fix weird naming
    mv "$BIDS_DIR"/"sub-"$PARTIC""/"$VISIT_DIR"/fmap/"$FMAP_FILE".nii.gz "$BIDS_DIR"/"sub-"$PARTIC""/"$VISIT_DIR"/fmap/"$FMAP_MAG_FILE"1.nii.gz 2>/dev/null
    mv "$BIDS_DIR"/"sub-"$PARTIC""/"$VISIT_DIR"/fmap/"$FMAP_FILE".json "$BIDS_DIR"/"sub-"$PARTIC""/"$VISIT_DIR"/fmap/"$FMAP_MAG_FILE"1.json 2>/dev/null
    mv "$BIDS_DIR"/"sub-"$PARTIC""/"$VISIT_DIR"/fmap/"$FMAP_FILE"_e1.nii.gz "$BIDS_DIR"/"sub-"$PARTIC""/"$VISIT_DIR"/fmap/"$FMAP_MAG_FILE"1.nii.gz 2>/dev/null
    mv "$BIDS_DIR"/"sub-"$PARTIC""/"$VISIT_DIR"/fmap/"$FMAP_FILE"_e1.json "$BIDS_DIR"/"sub-"$PARTIC""/"$VISIT_DIR"/fmap/"$FMAP_MAG_FILE"1.json 2>/dev/null
    mv "$BIDS_DIR"/"sub-"$PARTIC""/"$VISIT_DIR"/fmap/"$FMAP_FILE"_e2.nii.gz "$BIDS_DIR"/"sub-"$PARTIC""/"$VISIT_DIR"/fmap/"$FMAP_PHASE_FILE".nii.gz 2>/dev/null
    mv "$BIDS_DIR"/"sub-"$PARTIC""/"$VISIT_DIR"/fmap/"$FMAP_FILE"_e2.json "$BIDS_DIR"/"sub-"$PARTIC""/"$VISIT_DIR"/fmap/"$FMAP_PHASE_FILE".json 2>/dev/null
    mv "$BIDS_DIR"/"sub-"$PARTIC""/"$VISIT_DIR"/fmap/"$FMAP_FILE"_e2a.nii.gz "$BIDS_DIR"/"sub-"$PARTIC""/"$VISIT_DIR"/fmap/"$FMAP_MAG_FILE"2.nii.gz 2>/dev/null
    mv "$BIDS_DIR"/"sub-"$PARTIC""/"$VISIT_DIR"/fmap/"$FMAP_FILE"_e2a.json "$BIDS_DIR"/"sub-"$PARTIC""/"$VISIT_DIR"/fmap/"$FMAP_MAG_FILE"2.json 2>/dev/null
    wait

    ##Add echo times to fieldmap json's
    sed -i 's/\"EchoTime\"\: '0.00765'/\"EchoTime1\"\: '0.00519'\,\n\t"EchoTime2\"\: '0.00765'/g' "$BIDS_DIR"/"sub-"$PARTIC""/"$VISIT_DIR"/fmap/"$FMAP_PHASE_FILE".json
    sed -i 's/\"EchoTime2\"\: '0.00765'/\"EchoTime2\"\: '0.00765'\,\n\t\"DwellTime\"\: '4.57875e-05'/g' "$BIDS_DIR"/"sub-"$PARTIC""/"$VISIT_DIR"/fmap/"$FMAP_PHASE_FILE".json
    sed -i 's/\"DwellTime\"\: '4.57875e-05'/\"DwellTime\"\: '4.57875e-05'\,\n\t\"deltaEchoTime\"\: '2.46'/g' "$BIDS_DIR"/"sub-"$PARTIC""/"$VISIT_DIR"/fmap/"$FMAP_PHASE_FILE".json
    sed -i 's/\"PhaseEncodingLines\": '84'/\"PhaseEncodingLines\": '84'\,\n\t\"NDA_ExperimentID\"\: '885'/g' "$BIDS_DIR"/"sub-"$PARTIC""/"$VISIT_DIR"/fmap/"$FMAP_PHASE_FILE".json
    sed -i 's/\"PhaseEncodingLines\": '84'/\"PhaseEncodingLines\": '84'\,\n\t\t\"NDA_ExperimentID\"\: '885'/g' "$BIDS_DIR"/"sub-"$PARTIC""/"$VISIT_DIR"/fmap/"$FMAP_MAG_FILE"1.json
    sed -i 's/\"PhaseEncodingLines\": '84'/\"PhaseEncodingLines\": '84'\,\n\t\t\"NDA_ExperimentID\"\: '885'/g' "$BIDS_DIR"/"sub-"$PARTIC""/"$VISIT_DIR"/fmap/"$FMAP_MAG_FILE"2.json
    wait
fi

##Convert FUNC Rest1 dicoms
if [ ! -z "$FUNC_REST1_RAW" ]; then
    echo -en "\n\n\nConverting functional REST 1 for "$PARTIC"...\n\n\n"
    dcm2niix -o ""$BIDS_DIR"/"sub-"$PARTIC""/"$VISIT_DIR"/func" -f "$FUNC_REST1_FILE" -z y -b y -ba y -1 "$FUNC_REST1_RAW"
    cd "$BIDS_DIR"/"sub-"$PARTIC""/"$VISIT_DIR"/func
    sed -i 's/\"ProtocolName\"\: \"fMRI_32Chan_2X2_restingstate\"/\"ProtocolName\"\: \"fMRI_32Chan_2X2_restingstate\"\,\n\t\"TaskName\"\: \"REST1\"\,\n\t\"NDA_ExperimentID\"\: \"886"/g' "$FUNC_REST1_FILE".json
fi

##Convert FUNC Rest2 dicoms
if [ ! -z "$FUNC_REST2_RAW" ]; then
    echo -en "\n\n\nConverting functional REST 2 for "$PARTIC"...\n\n\n"
    dcm2niix -o ""$BIDS_DIR"/"sub-"$PARTIC""/"$VISIT_DIR"/func" -f "$FUNC_REST2_FILE" -z y -b y -ba y -1 "$FUNC_REST2_RAW"
    cd "$BIDS_DIR"/"sub-"$PARTIC""/"$VISIT_DIR"/func
    sed -i 's/\"ProtocolName\"\: \"fMRI_32Chan_2X2_restingstate\"/\"ProtocolName\"\: \"fMRI_32Chan_2X2_restingstate\"\,\n\t\"TaskName\"\: \"REST2\"\,\n\t\"NDA_ExperimentID\"\: \"886"/g' "$FUNC_REST2_FILE".json
fi

##Convert FUNC Task1 dicoms
if [ ! -z "$FUNC_SART1_RAW" ]; then
    echo -en "\n\n\nConverting functional SART 1 for "$PARTIC"...\n\n\n"
    dcm2niix -o ""$BIDS_DIR"/"sub-"$PARTIC""/"$VISIT_DIR"/func" -f "$FUNC_SART1_FILE" -z y -b y -ba y -1 "$FUNC_SART1_RAW"
    cd "$BIDS_DIR"/"sub-"$PARTIC""/"$VISIT_DIR"/func
    sed -i 's/\"ProtocolName\"\: \"fMRI_32Chan_2X2_Task1\"/\"ProtocolName\"\: \"fMRI_32Chan_2X2_Task1\"\,\n\t\"TaskName\"\: \"SART1\"\,\n\t\"NDA_ExperimentID\"\: \"885"/g' "$FUNC_SART1_FILE".json
fi

##Convert FUNC Task2 dicoms
if [ ! -z "$FUNC_SART2_RAW" ]; then
    echo -en "\n\n\nConverting functional SART 2 for "$PARTIC"...\n\n\n"
    dcm2niix -o ""$BIDS_DIR"/"sub-"$PARTIC""/"$VISIT_DIR"/func" -f "$FUNC_SART2_FILE" -z y -b y -ba y -1 "$FUNC_SART2_RAW"
    cd "$BIDS_DIR"/"sub-"$PARTIC""/"$VISIT_DIR"/func
    sed -i 's/\"ProtocolName\"\: \"fMRI_32Chan_2X2_Task2\"/\"ProtocolName\"\: \"fMRI_32Chan_2X2_Task2\"\,\n\t\"TaskName\"\: \"SART2\"\,\n\t\"NDA_ExperimentID\"\: \"885"/g' "$FUNC_SART2_FILE".json
fi

##Convert FUNC Task3 dicoms
if [ ! -z "$FUNC_SART3_RAW" ]; then
    echo -en "\n\n\nConverting functional SART 3 for "$PARTIC"...\n\n\n"
    dcm2niix -o ""$BIDS_DIR"/"sub-"$PARTIC""/"$VISIT_DIR"/func" -f "$FUNC_SART3_FILE" -z y -b y -ba y -1 "$FUNC_SART3_RAW"
    cd "$BIDS_DIR"/"sub-"$PARTIC""/"$VISIT_DIR"/func
    sed -i 's/\"ProtocolName\"\: \"fMRI_32Chan_2X2_Task3\"/\"ProtocolName\"\: \"fMRI_32Chan_2X2_Task3\"\,\n\t\"TaskName\"\: \"SART3\"\,\n\t\"NDA_ExperimentID\"\: \"885"/g' "$FUNC_SART3_FILE".json
fi

##Convert FUNC Task4 dicoms
if [ ! -z "$FUNC_SART4_RAW" ]; then
    echo -en "\n\n\nConverting functional SART 4 for "$PARTIC"...\n\n\n"
    dcm2niix -o ""$BIDS_DIR"/"sub-"$PARTIC""/"$VISIT_DIR"/func" -f "$FUNC_SART4_FILE" -z y -b y -ba y -1 "$FUNC_SART4_RAW"
    cd "$BIDS_DIR"/"sub-"$PARTIC""/"$VISIT_DIR"/func
    sed -i 's/\"ProtocolName\"\: \"fMRI_32Chan_2X2_Task4\"/\"ProtocolName\"\: \"fMRI_32Chan_2X2_Task4\"\,\n\t\"TaskName\"\: \"SART4\"\,\n\t\"NDA_ExperimentID\"\: \"885"/g' "$FUNC_SART4_FILE".json
fi
wait

##Create _scans.tsv files needed for BIDS2NDA
export FREESURFER_HOME=/Applications/freesurfer
source $FREESURFER_HOME/SetUpFreeSurfer.sh
sample_dcm=`find "$ANAT_RAW" \( -iname "*.dcm" -o -iname "*.ima" -o -iname "*.IMA" -o -iname "*.DCM" \) | sort | tail -1`
content_date=`mri_probedicom --i "$sample_dcm" --t 0008 0023`
content_time=`mri_probedicom --i "$sample_dcm" --t 0008 0033`

python3 /usr/local/bin/BIDS_create_scan_tsv.py ""$BIDS_DIR"/"sub-"$PARTIC""" "$content_date" "$content_time" "$VISIT_DIR"

#if [ ! -z "$FMAP_RAW" ] && [ ! -f ""$BIDS_DIR"/"sub-"$PARTIC""/"$VISIT_DIR"/fmap/"$FMAP_MAG_FILE"1.json" ] && [ ! -f ""$BIDS_DIR"/"sub-"$PARTIC""/"$VISIT_DIR"/fmap/"$FMAP_MAG_FILE"2.json" ] && [ ! -f ""$BIDS_DIR"/"sub-"$PARTIC""/"$VISIT_DIR"/fmap/"$FMAP_PHASE_FILE".json" ]; then
    ##Add intendedfor to magnitude1 and magnitude2
    python3 /usr/local/bin/fieldmap_intendedfor.py ""$BIDS_DIR"/"sub-"$PARTIC""/"$VISIT_DIR"/fmap/"$FMAP_MAG_FILE"1.json"
    python3 /usr/local/bin/fieldmap_intendedfor.py ""$BIDS_DIR"/"sub-"$PARTIC""/"$VISIT_DIR"/fmap/"$FMAP_MAG_FILE"2.json"
    python3 /usr/local/bin/fieldmap_intendedfor.py ""$BIDS_DIR"/"sub-"$PARTIC""/"$VISIT_DIR"/fmap/"$FMAP_PHASE_FILE".json"
#fi
