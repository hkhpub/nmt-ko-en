# -*- coding: utf-8 -*-
# Created by hkh at 2019-03-29
import argparse

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
    type=str, metavar='FILE', required=True, help='filtered lines output file'
)
parser.add_argument(
    '--output2',
    type=str, metavar='FILE', required=True, help='filtered lines output file'
)
parser.add_argument(
    '--mean_len',
    type=int, required=True, help='filtered lines output file'
)
parser.add_argument(
    '--target_size',
    type=int, required=True, help='filtered lines output file'
)
args = parser.parse_args()

target_size = args.target_size
source_file = open(args.input1, "r")
target_file = open(args.input2, "r")
source_output_file = open(args.output1, "w")
target_output_file = open(args.output2, "w")

len_dict = dict()
for i, (source, target) in enumerate(zip(source_file.readlines(), target_file.readlines())):
  # source is english
  seq_len = len(source.strip().split(" "))
  if seq_len not in len_dict:
    len_dict[seq_len] = []
  len_dict[seq_len] += [(source, target)]

print(len_dict.keys())

mean_len = args.mean_len
for i in range(mean_len):
  min_len = mean_len - (i+1)
  max_len = mean_len + i
  # counting
  total = 0
  for k, v in len_dict.items():
    if min_len <= k <= max_len:
      total += len(v)
  if total > target_size:
    break

print(total)
print(min_len, max_len)

for k, v in len_dict.items():
  if min_len <= k <= max_len:
    for source, target in v:
      source_output_file.write(source)
      target_output_file.write(target)

print("Done!")