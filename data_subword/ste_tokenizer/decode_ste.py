import sys
import subword_text_tokenizer

## Usage: python encode_ste.py < train.ste.txt > train.txt

if len(sys.argv) != 2:
  raise RuntimeError("SubwordTextTokenizer vocab file's not found")
encoder = subword_text_tokenizer.SubwordTextTokenizer(sys.argv[1])

for line in sys.stdin:
  print(encoder.decode(line.strip().split(" ")))

