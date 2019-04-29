file_path = "/home/hkh/data/Korean_POS_lap.nnlm.c10.neg30.w3.h100.wc1e-4.i5.a0.025.bin.txt"
# file_path = "/home/hkh/data/head2000.txt"
output_file = "/home/hkh/data/out_tmp.txt"

ofile = open(output_file, "w")
cnt = 0
with open(file_path, "r", encoding="euc-kr") as f:
    # for line in f.readlines():
    #     print(line)

    line = None
    while True:
        try:
            line = f.readline()
        except:
            print(line.split()[0], cnt)
            cnt += 1
        if not line:
            print(line)
            break
        # print(line)
