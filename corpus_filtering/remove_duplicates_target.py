# -*- coding: utf-8 -*-
# Created by hkh at 2019-03-19
import argparse
import numpy as np
import math
import hashlib


parser = argparse.ArgumentParser(description="")
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

sent_pairs = dict()
targets = []
for i, (source, target) in enumerate(zip(source_file.readlines(), target_file.readlines())):
  sent_pairs[target] = (source, target)
  if (i+1) % 1000 == 0:
    print(".", end="", flush=True)
  if (i+1) % 10000 == 0:
    print(i+1, end="", flush=True)

output1_file = open(args.output1, "w")
output2_file = open(args.output2, "w")

for _, pair in sent_pairs.items():
  output1_file.write(pair[0])
  output2_file.write(pair[1])

