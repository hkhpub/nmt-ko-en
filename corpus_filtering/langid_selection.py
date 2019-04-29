# -*- coding: utf-8 -*-
# Created by hkh at 2019-03-19
import argparse
import numpy as np
import math

parser = argparse.ArgumentParser(description="")
parser.add_argument(
    '--filtered',
    type=str, metavar='FILE', required=True, help='first input file (predicted)')
parser.add_argument(
    '--input1',
    type=str, metavar='FILE', required=True, help='first input file (predicted)')
parser.add_argument(
    '--input2',
    type=str, metavar='FILE', required=True, help='second input file (paired)'
)
parser.add_argument(
    '--output1',
    type=str, metavar='FILE', required=True, help='first output file (predicted)')
parser.add_argument(
    '--output2',
    type=str, metavar='FILE', required=True, help='second output file (paired)')
# parser.add_argument(
#     '--output',
#     type=str, metavar='FILE', required=True, help='filtered lines output file'
# )

args = parser.parse_args()

source_file = open(args.input1, "r")
target_file = open(args.input2, "r")

with open(args.filtered, "r") as f:
  lines = [line.strip() for line in f.readlines()]

output1_file = open(args.output1, "w")
output2_file = open(args.output2, "w")

scores = []
with open(args.filtered, "r") as f:
  for score in f.readlines():
    scores += [0 if math.isnan(float(score)) else float(score)]

# print(len(scores))
# scores = np.asarray(scores)
# ids = np.asarray(scores).argsort()[::-1]  # descending order

sent_pairs = []
for i, (source, target) in enumerate(zip(source_file.readlines(), target_file.readlines())):
  if int(scores[i]) == 1:
    output1_file.write(source)
    output2_file.write(target)
