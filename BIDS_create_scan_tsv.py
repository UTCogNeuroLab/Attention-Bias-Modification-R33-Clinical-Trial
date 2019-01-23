#!/usr/bin/env python
import json
import glob
import io
import sys
import os
import pandas as pd
from datetime import datetime
import calendar
try:
    to_unicode = unicode
except NameError:
    to_unicode = str

subj_base_path = sys.argv[1]
content_date = sys.argv[2]
content_time = sys.argv[3]
session_num = sys.argv[4]
ID = subj_base_path.split('/')[-1]

time = content_time.split('.')[0]
td = time + content_date
acq_time = datetime.strptime(td, '%H%M%S%Y%m%d').isoformat()

sess_01_file_list = []
sess_02_file_list = []
sess_03_file_list = []
for file in glob.glob(os.path.join(subj_base_path, "*", "sub-*.nii.gz")) + glob.glob(os.path.join(subj_base_path, session_num, "*", "sub-*_ses-*.nii.gz")):
    if 'ses-01' in file:
      sess_01_file_list.append(file)
    if 'ses-02' in file:
      sess_02_file_list.append(file)
    if 'ses-03' in file:
      sess_03_file_list.append(file)

##sess 1
if 'ses-01' in file:
    try:
        df_1 = pd.DataFrame(columns=['filename', 'acq_time'])
        sess_1_list = []
        for file in sess_01_file_list:
            sess_1_list.append(os.path.dirname(file).split('/')[-1] + '/' + os.path.basename(file))

        df_1['filename'] = sess_1_list
        df_1['acq_time'] = str(acq_time)
    except:
        pass

##sess 2
if 'ses-02' in file:
    try:
        df_2 = pd.DataFrame(columns=['filename', 'acq_time'])
        sess_2_list = []
        for file in sess_02_file_list:
            sess_2_list.append(os.path.dirname(file).split('/')[-1] + '/' + os.path.basename(file))

        df_2['filename'] = sess_2_list
        df_2['acq_time'] = str(acq_time)
    except:
        pass

##sess 3
if 'ses-03' in file:
    try:
        df_3 = pd.DataFrame(columns=['filename', 'acq_time'])
        sess_3_list = []
        for file in sess_03_file_list:
            sess_3_list.append(os.path.dirname(file).split('/')[-1] + '/' + os.path.basename(file))

        df_3['filename'] = sess_3_list
        df_3['acq_time'] = str(acq_time)
    except:
        pass

if 'ses-01' in file:
    try:
        df_1.to_csv(subj_base_path + '/ses-01/' + str(ID) + '_ses-01_scans.tsv', sep="\t", index=False)
    except:
        pass
if 'ses-02' in file:
    try:
        df_2.to_csv(subj_base_path + '/ses-02/' + str(ID) + '_ses-02_scans.tsv', sep="\t", index=False)
    except:
        pass
if 'ses-03' in file:
    try:
        df_3.to_csv(subj_base_path + '/ses-03/' + str(ID) + '_ses-03_scans.tsv', sep="\t", index=False)
    except:
        pass
