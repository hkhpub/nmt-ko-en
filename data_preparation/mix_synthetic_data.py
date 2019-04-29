import tensorflow as tf
import random

SYNTHETIC_SRC = "/home/hkh/data/wmt16_en_data/synthetic.train.1m.tok.clean.ko"
SYNTHETIC_TGT = "/home/hkh/data/wmt16_en_data/train.1m.tok.clean.en"

PARALLEL_SRC = "/home/hkh/data/opensub18-enko/morph.data.tok/train.tok.clean.ko"
PARALLEL_TGT = "/home/hkh/data/opensub18-enko/morph.data.tok/train.tok.clean.en"

MIX_SRC = "/home/hkh/data/opensub18-enko/mix.1to%.1f"
MIX_TGT = "/home/hkh/data/opensub18-enko/mix.1to%.1f"

DATA_RATIO = 0.5

MIX_SRC = MIX_SRC % DATA_RATIO
MIX_TGT = MIX_TGT % DATA_RATIO

if not tf.gfile.Exists(MIX_SRC):
    tf.gfile.MakeDirs(MIX_SRC)

if not tf.gfile.Exists(MIX_TGT):
    tf.gfile.MakeDirs(MIX_TGT)

mix_src_file = MIX_SRC+"/"+"train.ko"
mix_tgt_file = MIX_TGT+"/"+"train.en"

syns_srcf = open(SYNTHETIC_SRC, "r")
syns_tgtf = open(SYNTHETIC_TGT, "r")

para_srcf = open(PARALLEL_SRC, "r")
para_tgtf = open(PARALLEL_TGT, "r")

syns_src_lines = syns_srcf.readlines()
syns_tgt_lines = syns_tgtf.readlines()

para_src_lines = para_srcf.readlines()
para_tgt_lines = para_tgtf.readlines()

# syns_len = min(len(syns_src_lines), DATA_RATIO*len(para_src_lines))
syns_len = int(len(syns_src_lines) * DATA_RATIO)
mix_srcf = open(mix_src_file, "w")
mix_tgtf = open(mix_tgt_file, "w")

mix_lines = []
for syns_src, syns_tgt in zip(syns_src_lines[:syns_len], syns_tgt_lines[:syns_len]):
    mix_lines += [(syns_src, syns_tgt)]

for para_src, para_tgt in zip(para_src_lines, para_tgt_lines):
    mix_lines += [(para_src, para_tgt)]

random.shuffle(mix_lines)
for (src_line, tgt_line) in mix_lines:
    mix_srcf.write(src_line)
    mix_tgtf.write(tgt_line)

mix_srcf.flush()
mix_tgtf.flush()
mix_srcf.close()
mix_tgtf.close()
