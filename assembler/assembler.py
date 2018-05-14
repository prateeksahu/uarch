import numpy as np

input_file  = "br_test.lst"

file_d      = open(input_file, "r")

code        = file_d.readlines()
byte_map    = [0 for i in range(32768)]

for i in range(0, 32768):
    byte_map[i] = "00"

for line in code:

    tabsp   = line.replace('\t', '')
    if(tabsp[:2]!="//"):

        remove_c    = tabsp.split("//")
        inst        = remove_c[0].split(":")
        if(inst[0][:2]=="0x") | (inst[0][:2]=="0X") | (inst[0][:1]=="x") | (inst[0][:2]=="X"):
            addr    = int((inst[0].strip())[2:], 16)
            bytes   = (inst[1].strip()).split(" ")

            for byte in bytes:
                byte_map[addr]  = byte
                addr            = addr + 1
                #print(byte)

chips   = np.chararray((8, 128, 4, 8), 2)
np.shape(chips)
#print(chips)
count = 0

for i in range(0, 8):
    for j in range(0, 128):
        for k in range(0, 4):
            for l in range(0, 8):
                chips[i][j][k][l] = byte_map[count]
                count = count + 1
f   = open("a", "w")
f.write(str(chips[0][0][0][0])[2:4])


memfile_str = "mem_map"
count       = 0
fc          = 0
f   = open("mem_map.mem", "w")

for i in range(8):
    for j in range(4):
        for k in range(8):

            fname = "mem_map" + str(fc) + ".mem"
            f   = open(fname, "w")
            for l in range(128):
                f.write(str(chips[i][l][j][k])[2:4]+"\n")

            print("$readmemh(\"./../mem_files/" + fname + "\", mem_sys.mem_inst.l[" + str(j) +"].bank.page[" +str(i) + "].chip[" + str(k) +  "].c.mem);")
            fc = fc + 1

    #f.write(elem + "\n")
    count = count + 1