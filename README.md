# Attention-Bias-Modification-R33-Clinical-Trial


Convert Raw MRI data into BIDS format using BIDS_Conversion_R33.sh

"BIDS_conversion_R33.sh" should be put in the usr/local/bin
Run BIDS_conversion_R33.sh from the terminal. 
The script uses pydeface.py, fieldmap_intendedfor.py, and BIDS_create_scan_tsv.py. These should also be in the usr/local/bin

NDA data upload scripts:

Run BIDS ap MRIQC 

Run BIDS ap fMRIprep

XCP engine was used to regress out motion confounds and scrub TRs with more than 0.25mm framewise discplacement, and create functional connectivity matrices (correlation) AAL, Glasser, Gordon, Harvord Oxford, Power, Schaefer altases. 
task approx 30 mines per subject (3 sessions) on TACC. 

xcp.dms is the job file for using XCP engine on TACC,  the actual design file is fc-6p_scrub.dsn
