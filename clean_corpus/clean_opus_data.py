# _*_ coding: utf8 _*_
import re
import numpy as np
np.random.seed(1)

DATA_PREFIX = '/home/hkh/data/opensub18-enko/corpus.org/open-subtitles'
OUT_DIR = "/home/hkh/data/opensub18-enko/corpus.org/"

ko_file = open((DATA_PREFIX+".ko"), "r")
en_file = open((DATA_PREFIX+".en"), "r")

# write file
out_ko = open((OUT_DIR+"/open-subtitles.clean.ko"), "w")
out_en = open((OUT_DIR+"/open-subtitles.clean.en"), "w")


def preprocess(string):
    string = re.sub(r'\-', "", string)
    string = re.sub(r'♪', "", string)
    string = re.sub(r'nbsp;', "", string)
    string = re.sub(r'\(.+\)', "", string)
    string = re.sub(r'[\"\']', "", string)
    return string


def grep_hanguls(string):
    hangul_len = 0
    for m in re.finditer(r'[가-힣\s]+', string):
        # 3 bytes for each korean character, so divide it by 3
        hangul_len += (m.end() - m.start())/3
    return hangul_len


def grep_non_hanguls(string):
    non_hangul_len = 0
    for m in re.finditer(r'[^가-힣\s]+', string):
        non_hangul_len += (m.end() - m.start())
    return non_hangul_len


filter_cnt = 0
for (en_line, ko_line) in zip(en_file.readlines(), ko_file.readlines()):
    en_line = preprocess(en_line.strip())
    ko_line = preprocess(ko_line.strip())
    if ko_line.find(en_line) >= 0:
        filter_cnt += 1
        continue

    if grep_hanguls(ko_line) < grep_non_hanguls(ko_line):
        filter_cnt += 1
        continue

    if ko_line.find("/") >= 0 or en_line.find("/") >= 0:
        filter_cnt += 1
        continue

    out_en.write(en_line+"\n")
    out_ko.write(ko_line+"\n")

print("filter_cnt: %d" % filter_cnt)