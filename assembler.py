

input_file  = "dcache_test.lst"

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
                print(byte)

memfile_str = "mem_map"
count       = 0
fc          = 0
f   = open("mem_map.mem", "w")

for elem in byte_map:
    if(count%128==0):
        fname = "mem_map" + str(fc) + ".mem"
        f   = open(fname, "w")
        print("$readmemh(\"./../mem_files/" + fname + "\", mem_sys.mem_inst.l[].mem);")
        fc = fc + 1

    f.write(elem + "\n")
    count = count + 1