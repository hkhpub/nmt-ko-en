# -*- coding: utf-8 -*-
# Created by hkh at 2019-01-29
import argparse
import numpy as np

"""
# merge two files

python masking/merge_vocab.py \
--input1=$WMT_DIR/vocab.bpe32k \
--input2=$WMT_DIR/vocab.mask.bpe32k \
--output=$WMT_DIR/vocab.merge.bpe32k
"""

parser = argparse.ArgumentParser(description="")
parser.add_argument(
    '--input1',
    type=str, metavar='FILE', required=True, help='first input file')
parser.add_argument(
    '--input2',
    type=str, metavar='FILE', required=True, help='second input file'
)
parser.add_argument(
    '--output',
    type=str, metavar='FILE', required=True, help='first output file')

args = parser.parse_args()

input1_file = open(args.input1, "r")
input2_file = open(args.input2, "r")
merged = []
for (line1, line2) in zip(input1_file.readlines(), input2_file.readlines()):
  merged += [line1]
  merged += [line2]
merged = set(merged)

with open(args.output, "w") as f:
  f.writelines(merged)