# -*- coding: utf-8 -*-
# Created by hkh at 2019-03-19
import argparse
import numpy as np
import math

parser = argparse.ArgumentParser(description="")
parser.add_argument(
    '--score',
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
parser.add_argument(
    '--score_out',
    type=str, metavar='FILE', required=True, help='filtered lines output file'
)
parser.add_argument(
    '--threshold',
    type=float, required=True, help='filtered lines output file'
)

args = parser.parse_args()

source_file = open(args.input1, "r")
target_file = open(args.input2, "r")

scores = []
with open(args.score, "r") as f:
  for score in f.readlines():
    scores += [0 if math.isnan(float(score)) else float(score)]
    # scores += [0 if math.isnan(float(score)) or float(score) > 0.5 else float(score)]

print(len(scores))
scores = np.asarray(scores)
# ids = np.asarray(scores).argsort()      # ascending order
ids = np.asarray(scores).argsort()[::-1]  # descending order
print(scores[ids[:100]])

sent_pairs = []
for i, (source, target) in enumerate(zip(source_file.readlines(), target_file.readlines())):
  sent_pairs += [(source, target)]
sent_pairs = np.asarray(sent_pairs)
# for pair in sent_pairs[ids[:100]]:
#   print(pair[0])
#   print(pair[1])

output1_file = open(args.output1, "w")
output2_file = open(args.output2, "w")
score_out_file = open(args.score_out, "w")

for score, pair in zip(scores[ids], sent_pairs[ids]):
  if score > args.threshold:
    output1_file.write(pair[0])
    output2_file.write(pair[1])
  score_out_file.write(str(score) + "\n")

