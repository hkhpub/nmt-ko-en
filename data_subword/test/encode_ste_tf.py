import sys
import t2t_subword_text_tokenizer

## Usage: python encode_ste.py < train.txt > train.ste.txt

if len(sys.argv) != 2:
  raise RuntimeError("SubwordTextTokenizer vocab file's not found")
encoder = t2t_subword_text_tokenizer.SubwordTextEncoder(sys.argv[1])

for line in sys.stdin:
  print(line.strip())
  print(encoder.subtoken_ids_to_subtoken_string(encoder.encode(line.strip())))
  # print(encoder.subtoken_ids_to_tokens(encoder.encode(line.strip())))
  # print(len(line.strip().split(" ")), len(encoder.subtoken_ids_to_tokens(encoder.encode(line.strip()))))
  print()


