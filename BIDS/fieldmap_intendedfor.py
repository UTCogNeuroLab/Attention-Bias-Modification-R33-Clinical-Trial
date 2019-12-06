#!/usr/bin/env python
import json
import glob
import io
import sys
import os
try:
    to_unicode = unicode
except NameError:
    to_unicode = str

in_json = sys.argv[1]

fmap_mag_json = json.load(open(in_json))

func_base_path = os.path.dirname(in_json).split('/fmap')[0] + '/func/*.nii.gz'

func_base_paths_short_list = []
for file in glob.glob(func_base_path):
	rel_path = 'ses' + file.split('/ses')[1]
	func_base_paths_short_list.append(rel_path)

fmap_mag_json["IntendedFor"] = func_base_paths_short_list

with io.open(in_json, 'w', encoding='utf8') as outfile:
    str_ = json.dumps(fmap_mag_json,
                      indent=4, sort_keys=True,
                      separators=(',', ': '), ensure_ascii=False)
    outfile.write(to_unicode(str_))
